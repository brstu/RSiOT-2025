package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"github.com/redis/go-redis/v9"
)

func getenv(key, def string) string {
	v := os.Getenv(key)
	if v == "" {
		return def
	}
	return v
}

func main() {
	port := getenv("PORT", "8083")
	redisAddr := getenv("REDIS_ADDR", "redis:6379")
	redisPassword := getenv("REDIS_PASSWORD", "")
	redisDBStr := getenv("REDIS_DB", "0")
	shutdownTimeoutStr := getenv("SHUTDOWN_TIMEOUT", "10s")

	redisDB, err := strconv.Atoi(redisDBStr)
	if err != nil {
		log.Fatalf("bad REDIS_DB: %v", err)
	}
	shutdownTimeout, err := time.ParseDuration(shutdownTimeoutStr)
	if err != nil {
		log.Fatalf("bad SHUTDOWN_TIMEOUT: %v", err)
	}

	rdb := redis.NewClient(&redis.Options{
		Addr:     redisAddr,
		Password: redisPassword,
		DB:       redisDB,
	})

	mux := http.NewServeMux()

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		ctx, cancel := context.WithTimeout(r.Context(), 2*time.Second)
		defer cancel()

		val, err := rdb.Incr(ctx, "requests_total").Result()
		if err != nil {
			http.Error(w, "redis error: "+err.Error(), http.StatusServiceUnavailable)
			return
		}
		w.Header().Set("Content-Type", "text/plain; charset=utf-8")
		fmt.Fprintf(w, "OK. requests_total=%d\n", val)
	})

	// health endpoint: /ready
	mux.HandleFunc("/ready", func(w http.ResponseWriter, r *http.Request) {
		ctx, cancel := context.WithTimeout(r.Context(), 1*time.Second)
		defer cancel()

		if err := rdb.Ping(ctx).Err(); err != nil {
			http.Error(w, "redis not ready: "+err.Error(), http.StatusServiceUnavailable)
			return
		}
		w.Header().Set("Content-Type", "text/plain; charset=utf-8")
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("ready\n"))
	})

	server := &http.Server{
		Addr:              ":" + port,
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
	}

	go func() {
		log.Printf("listening on :%s (redis=%s)", port, redisAddr)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("listen error: %v", err)
		}
	}()

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, syscall.SIGTERM, syscall.SIGINT)
	<-stop

	log.Printf("shutdown started (timeout=%s)...", shutdownTimeout)
	ctx, cancel := context.WithTimeout(context.Background(), shutdownTimeout)
	defer cancel()

	_ = rdb.Close()

	if err := server.Shutdown(ctx); err != nil {
		log.Printf("shutdown error: %v", err)
	} else {
		log.Printf("shutdown complete")
	}
}

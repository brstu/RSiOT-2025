package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"sync/atomic"
	"syscall"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"github.com/redis/go-redis/v9"
)

const metricsPrefix = "app03_"

var (
	readyFlag       atomic.Bool
	shuttingDown    atomic.Bool
	activeInFlight  atomic.Int64
	startTime       = time.Now()

	httpRequestsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: metricsPrefix + "http_requests_total",
			Help: "Total number of HTTP requests",
		},
		[]string{"method", "status"},
	)

	httpRequestDuration = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    metricsPrefix + "http_request_duration_seconds",
			Help:    "HTTP request latency (seconds)",
			Buckets: []float64{0.005, 0.01, 0.025, 0.05, 0.1, 0.2, 0.3, 0.5, 1, 2.5, 5, 10},
		},
		[]string{"method"},
	)

	activeConnections = prometheus.NewGauge(
		prometheus.GaugeOpts{
			Name: metricsPrefix + "active_connections",
			Help: "In-flight requests (gauge)",
		},
	)

	uptimeSeconds = prometheus.NewGaugeFunc(
		prometheus.GaugeOpts{
			Name: metricsPrefix + "uptime_seconds",
			Help: "Service uptime in seconds",
		},
		func() float64 { return time.Since(startTime).Seconds() },
	)
)

func init() {
	prometheus.MustRegister(httpRequestsTotal)
	prometheus.MustRegister(httpRequestDuration)
	prometheus.MustRegister(activeConnections)
	prometheus.MustRegister(uptimeSeconds)
}

type statusRecorder struct {
	http.ResponseWriter
	status int
}

func (r *statusRecorder) WriteHeader(code int) {
	r.status = code
	r.ResponseWriter.WriteHeader(code)
}

func metricsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
		if req.URL.Path == "/metrics" {
			next.ServeHTTP(w, req)
			return
		}

		rec := &statusRecorder{ResponseWriter: w, status: 200}

		start := time.Now()
		activeInFlight.Add(1)
		activeConnections.Set(float64(activeInFlight.Load()))
		defer func() {
			activeInFlight.Add(-1)
			activeConnections.Set(float64(activeInFlight.Load()))
		}()

		next.ServeHTTP(rec, req)

		dur := time.Since(start).Seconds()
		httpRequestsTotal.WithLabelValues(req.Method, strconv.Itoa(rec.status)).Inc()
		httpRequestDuration.WithLabelValues(req.Method).Observe(dur)
	})
}

func json(w http.ResponseWriter, code int, body string) {
	w.Header().Set("content-type", "application/json; charset=utf-8")
	w.WriteHeader(code)
	_, _ = w.Write([]byte(body))
}

func main() {
	port := getenv("PORT", "8083")
	redisAddr := getenv("REDIS_ADDR", "redis:6379")
	redisDB := getenvInt("REDIS_DB", 0)
	shutdownTimeout := getenvDuration("SHUTDOWN_TIMEOUT", 10*time.Second)

	rdb := redis.NewClient(&redis.Options{
		Addr: redisAddr,
		DB:   redisDB,
	})

	mux := http.NewServeMux()

	// основной эндпоинт: hello + counter (redis)
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		ctx, cancel := context.WithTimeout(r.Context(), 2*time.Second)
		defer cancel()

		val, err := rdb.Incr(ctx, "web03_counter").Result()
		if err != nil {
			json(w, 500, fmt.Sprintf(`{"ok":false,"error":"redis_incr_failed","details":%q}`, err.Error()))
			return
		}
		json(w, 200, fmt.Sprintf(`{"ok":true,"message":"hello","counter":%d}`, val))
	})

	// для симуляции 5xx (чтобы проверить алерт 5xx>1%)
	mux.HandleFunc("/error", func(w http.ResponseWriter, r *http.Request) {
		json(w, 500, `{"ok":false,"error":"simulated_500"}`)
	})

	// для симуляции задержек (чтобы p95 > 200ms)
	mux.HandleFunc("/sleep", func(w http.ResponseWriter, r *http.Request) {
		ms := getenvQueryInt(r, "ms", 250)
		time.Sleep(time.Duration(ms) * time.Millisecond)
		json(w, 200, fmt.Sprintf(`{"ok":true,"slept_ms":%d}`, ms))
	})

	// readiness: не отдаём Ready во время shutdown и если Redis недоступен
	mux.HandleFunc("/ready", func(w http.ResponseWriter, r *http.Request) {
		if shuttingDown.Load() || !readyFlag.Load() {
			json(w, 503, `{"ok":false,"ready":false}`)
			return
		}
		ctx, cancel := context.WithTimeout(r.Context(), 1*time.Second)
		defer cancel()
		if err := rdb.Ping(ctx).Err(); err != nil {
			json(w, 503, fmt.Sprintf(`{"ok":false,"ready":false,"redis":%q}`, err.Error()))
			return
		}
		json(w, 200, `{"ok":true,"ready":true}`)
	})

	// liveness: процесс жив
	mux.HandleFunc("/live", func(w http.ResponseWriter, r *http.Request) {
		json(w, 200, `{"ok":true,"live":true}`)
	})

	// metrics
	mux.Handle("/metrics", promhttp.Handler())

	handler := metricsMiddleware(mux)

	srv := &http.Server{
		Addr:              "0.0.0.0:" + port,
		Handler:           handler,
		ReadHeaderTimeout: 5 * time.Second,
	}

	readyFlag.Store(true)
	log.Printf("server_started port=%s redis=%s db=%d", port, redisAddr, redisDB)

	// graceful shutdown
	errCh := make(chan error, 1)
	go func() {
		errCh <- srv.ListenAndServe()
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGTERM, syscall.SIGINT)

	select {
	case sig := <-quit:
		shuttingDown.Store(true)
		readyFlag.Store(false)
		log.Printf("shutdown_started signal=%s", sig.String())

		ctx, cancel := context.WithTimeout(context.Background(), shutdownTimeout)
		defer cancel()
		if err := srv.Shutdown(ctx); err != nil {
			log.Printf("shutdown_error err=%v", err)
			os.Exit(1)
		}
		_ = rdb.Close()
		log.Printf("shutdown_completed")
	case err := <-errCh:
		// http.ErrServerClosed — норма при Shutdown()
		if err != nil && err != http.ErrServerClosed {
			log.Printf("server_error err=%v", err)
			os.Exit(1)
		}
	}
}

func getenv(k, def string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return def
}

func getenvInt(k string, def int) int {
	v := os.Getenv(k)
	if v == "" {
		return def
	}
	n, err := strconv.Atoi(v)
	if err != nil {
		return def
	}
	return n
}

func getenvDuration(k string, def time.Duration) time.Duration {
	v := os.Getenv(k)
	if v == "" {
		return def
	}
	d, err := time.ParseDuration(v)
	if err != nil {
		return def
	}
	return d
}

func getenvQueryInt(r *http.Request, key string, def int) int {
	q := r.URL.Query().Get(key)
	if q == "" {
		return def
	}
	n, err := strconv.Atoi(q)
	if err != nil {
		return def
	}
	return n
}

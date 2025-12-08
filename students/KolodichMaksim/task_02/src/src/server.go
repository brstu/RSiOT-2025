package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/redis/go-redis/v9"
)

func readinessCheck(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "OK\n")
	log.Println("/ready — сервис готов")
}

func healthCheck(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "READY\n")
	log.Println("/healthz — сервис жив")
}

func establishRedisConnection() *redis.Client {
	redisHost := os.Getenv("REDIS_HOST")
	redisPort := os.Getenv("REDIS_PORT")
	if redisPort == "" {
		redisPort = "6379"
	}
	redisPass := os.Getenv("REDIS_PASSWORD")

	// Если REDIS_HOST не задан — работаем без Redis (разрешено в ЛР02)
	if redisHost == "" {
		log.Println("REDIS_HOST не задан — продолжаем работу БЕЗ Redis (нормально для ЛР02)")
		return nil
	}

	fullAddr := fmt.Sprintf("%s:%s", redisHost, redisPort)
	client := redis.NewClient(&redis.Options{
		Addr:     fullAddr,
		Password: redisPass,
		DB:       0,
	})

	ctx, cancel := context.WithTimeout(context.Background(), 4*time.Second)
	defer cancel()

	if err := client.Ping(ctx).Err(); err != nil {
		log.Printf("Не удалось подключиться к Redis (%s: %v — продолжаем без Redis", fullAddr, err)
		return nil
	}

	log.Printf("Redis успешно подключён: %s", fullAddr)
	return client
}

func main() {
	// === Обязательное логирование по требованиям ЛР ===
	stuID := os.Getenv("STU_ID")
	if stuID == "" {
		stuID = "220013"
	}
	stuGroup := os.Getenv("STU_GROUP")
	if stuGroup == "" {
		stuGroup = "as-63"
	}
	stuVariant := os.Getenv("STU_VARIANT")
	if stuVariant == "" {
		stuVariant = "09"
	}

	log.Printf("=== LAUNCH LAB02 === STU_ID=%s | STU_GROUP=%s | STU_VARIANT=%s", stuID, stuGroup, stuVariant)

	// === Redis: пытаемся, но не падаем ===
	redisClient := establishRedisConnection()
	if redisClient != nil {
		defer redisClient.Close()
		log.Println("Redis клиент готов к работе")
	} else {
		log.Println("Работаем без Redis — всё в порядке для ЛР02")
	}

	// === HTTP сервер ===
	http.HandleFunc("/ready", readinessCheck)
	http.HandleFunc("/healthz", healthCheck)
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "ЛР02 вариант 09 | %s | группа %s\n", stuID, stuGroup)
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8071"
	}

	srv := &http.Server{Addr: ":" + port}

	// Graceful shutdown
	go func() {
		sig := make(chan os.Signal, 1)
		signal.Notify(sig, syscall.SIGINT, syscall.SIGTERM)
		<-sig
		log.Println("Получен сигнал завершения — graceful shutdown...")
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		srv.Shutdown(ctx)
	}()

	log.Printf("Сервер успешно запущен на порту %s", port)
	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Printf("Сервер завершился с ошибкой: %v", err)
	}
	log.Println("Сервер остановлен")
}

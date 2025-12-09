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
)

var (
	stuID      = os.Getenv("STU_ID")
	stuGroup   = os.Getenv("STU_GROUP")
	stuVariant = os.Getenv("STU_VARIANT")
	appPort    = os.Getenv("APP_PORT")
)

func main() {
	// Логирование запуска с метаданными
	log.Printf("Starting HTTP server...")
	log.Printf("Student ID: %s", stuID)
	log.Printf("Group: %s", stuGroup)
	log.Printf("Variant: %s", stuVariant)
	log.Printf("Port: %s", appPort)

	if appPort == "" {
		appPort = "8043"
	}

	// Настройка HTTP handlers
	http.HandleFunc("/", handleRoot)
	http.HandleFunc("/ready", handleReady)
	http.HandleFunc("/live", handleLive)

	// Создание сервера с таймаутами
	server := &http.Server{
		Addr:         ":" + appPort,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Graceful shutdown
	go func() {
		sigChan := make(chan os.Signal, 1)
		signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)
		<-sigChan

		log.Println("Shutdown signal received, shutting down gracefully...")

		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()

		if err := server.Shutdown(ctx); err != nil {
			log.Printf("Error during shutdown: %v", err)
		}
	}()

	log.Printf("Server listening on port %s", appPort)
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("Server error: %v", err)
	}

	log.Println("Server stopped gracefully")
}

func handleRoot(w http.ResponseWriter, r *http.Request) {
	log.Printf("Request: %s %s from %s", r.Method, r.URL.Path, r.RemoteAddr)
	
	response := fmt.Sprintf(`<!DOCTYPE html>
<html>
<head>
    <title>Lab 02 - Variant 23</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
        .info { background: #f0f0f0; padding: 15px; border-radius: 5px; }
        .meta { color: #666; }
    </style>
</head>
<body>
    <h1>Kubernetes Lab 02 - HTTP Service</h1>
    <div class="info">
        <h2>Student Information</h2>
        <p><strong>Name:</strong> Ярмола Александр Олегович</p>
        <p><strong>Group:</strong> %s</p>
        <p><strong>Student ID:</strong> %s</p>
        <p><strong>Variant:</strong> %s</p>
        <p><strong>GitHub:</strong> alexsandro007</p>
    </div>
    <div class="meta">
        <h3>Service Endpoints:</h3>
        <ul>
            <li><a href="/">/</a> - Main page</li>
            <li><a href="/ready">/ready</a> - Readiness probe</li>
            <li><a href="/live">/live</a> - Liveness probe</li>
        </ul>
    </div>
</body>
</html>`, stuGroup, stuID, stuVariant)

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.WriteHeader(http.StatusOK)
	fmt.Fprint(w, response)
}

func handleReady(w http.ResponseWriter, r *http.Request) {
	// Readiness check - проверяет, готов ли pod принимать трафик
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, `{"status":"ready","timestamp":"%s"}`, time.Now().Format(time.RFC3339))
}

func handleLive(w http.ResponseWriter, r *http.Request) {
	// Liveness check - проверяет, жив ли pod
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, `{"status":"alive","timestamp":"%s"}`, time.Now().Format(time.RFC3339))
}

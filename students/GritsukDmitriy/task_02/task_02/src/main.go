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

func main() {
	// Получаем переменные окружения
	studentID := os.Getenv("STU_ID")
	studentGroup := os.Getenv("STU_GROUP")
	studentVariant := os.Getenv("STU_VARIANT")
	studentFullName := os.Getenv("STU_FULLNAME")
	port := os.Getenv("PORT")
	if port == "" {
		port = "8083"
	}

	// Логируем информацию при старте
	log.Printf("Starting server...")
	log.Printf("Student ID: %s", studentID)
	log.Printf("Group: %s", studentGroup)
	log.Printf("Variant: %s", studentVariant)
	log.Printf("Full Name: %s", studentFullName)
	log.Printf("Server starting on port %s", port)

	// Настраиваем HTTP-обработчики
	mux := http.NewServeMux()
	
	// Главная страница
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html")
		fmt.Fprintf(w, `<h1>Web03 Application</h1>
			<p><strong>Student ID:</strong> %s</p>
			<p><strong>Group:</strong> %s</p>
			<p><strong>Variant:</strong> %s</p>
			<p><strong>Full Name:</strong> %s</p>
			<p><strong>Pod:</strong> %s</p>
			<ul>
				<li><a href="/health">Health Check</a></li>
				<li><a href="/ready">Readiness Check</a></li>
				<li><a href="/live">Liveness Check</a></li>
			</ul>`,
			studentID, studentGroup, studentVariant, studentFullName, os.Getenv("HOSTNAME"))
	})

	// Health endpoint
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprint(w, "OK")
	})

	// Readiness probe
	mux.HandleFunc("/ready", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprint(w, "READY")
	})

	// Liveness probe
	mux.HandleFunc("/live", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprint(w, "ALIVE")
	})

	// Graceful shutdown
	server := &http.Server{
		Addr:    ":" + port,
		Handler: mux,
	}

	// Запуск сервера в горутине
	go func() {
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server error: %v", err)
		}
	}()

	// Ожидание сигналов завершения
	stop := make(chan os.Signal, 1)
	signal.Notify(stop, syscall.SIGINT, syscall.SIGTERM)
	<-stop

	log.Println("Shutting down server...")
	
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	
	if err := server.Shutdown(ctx); err != nil {
		log.Fatal("Server forced to shutdown:", err)
	}
	
	log.Println("Server stopped gracefully")
}
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

type Config struct {
	Port       string
	StudentID  string
	Group      string
	Variant    string
	AppName    string
	Namespace  string
}

type HealthResponse struct {
	Status    string    `json:"status"`
	Timestamp time.Time `json:"timestamp"`
	Service   string    `json:"service"`
}

type InfoResponse struct {
	StudentID  string `json:"student_id"`
	Group      string `json:"group"`
	Variant    string `json:"variant"`
	AppName    string `json:"app_name"`
	Namespace  string `json:"namespace"`
	Message    string `json:"message"`
}

var config Config
var startTime time.Time
var isReady bool

func main() {
	// Загрузка конфигурации из переменных окружения
	config = Config{
		Port:      getEnv("APP_PORT", "7991"),
		StudentID: getEnv("STU_ID", "220053"),
		Group:     getEnv("STU_GROUP", "АС-64"),
		Variant:   getEnv("STU_VARIANT", "41"),
		AppName:   getEnv("APP_NAME", "web41"),
		Namespace: getEnv("APP_NAMESPACE", "app41"),
	}

	startTime = time.Now()

	// Логирование запуска приложения
	log.Printf("=== ЗАПУСК ПРИЛОЖЕНИЯ ===")
	log.Printf("Студент: %s, Группа: %s, Вариант: %s", config.StudentID, config.Group, config.Variant)
	log.Printf("Приложение: %s, Namespace: %s", config.AppName, config.Namespace)
	log.Printf("Порт: %s", config.Port)
	log.Printf("Время запуска: %s", startTime.Format(time.RFC3339))

	// Настройка HTTP-сервера
	mux := http.NewServeMux()
	mux.HandleFunc("/", handleRoot)
	mux.HandleFunc("/health", handleHealth)
	mux.HandleFunc("/ready", handleReady)
	mux.HandleFunc("/info", handleInfo)

	server := &http.Server{
		Addr:         ":" + config.Port,
		Handler:      logMiddleware(mux),
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Канал для обработки сигналов
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	// Запуск сервера в горутине
	go func() {
		log.Printf("Сервер запущен на порту %s", config.Port)
		
		// Симуляция инициализации (для readiness probe)
		time.Sleep(2 * time.Second)
		isReady = true
		log.Println("Приложение готово к обработке запросов")
		
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Ошибка запуска сервера: %v", err)
		}
	}()

	// Ожидание сигнала завершения
	<-quit
	log.Println("=== ПОЛУЧЕН СИГНАЛ ЗАВЕРШЕНИЯ ===")

	// Graceful shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	log.Println("Начинается корректное завершение работы сервера...")
	if err := server.Shutdown(ctx); err != nil {
		log.Printf("Ошибка при завершении работы сервера: %v", err)
	}

	uptime := time.Since(startTime)
	log.Printf("Сервер остановлен корректно. Время работы: %s", uptime)
	log.Println("=== ЗАВЕРШЕНИЕ РАБОТЫ ===")
}

func handleRoot(w http.ResponseWriter, r *http.Request) {
	response := fmt.Sprintf(`
<!DOCTYPE html>
<html>
<head>
    <title>%s - Вариант %s</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
        h1 { color: #2c3e50; }
        .info { background: #ecf0f1; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .label { font-weight: bold; color: #34495e; }
    </style>
</head>
<body>
    <h1>Лабораторная работа №02</h1>
    <div class="info">
        <p><span class="label">Студент:</span> Смердина Анастасия Валентиновна</p>
        <p><span class="label">Группа:</span> %s</p>
        <p><span class="label">StudentID:</span> %s</p>
        <p><span class="label">Вариант:</span> %s</p>
        <p><span class="label">Приложение:</span> %s</p>
        <p><span class="label">Namespace:</span> %s</p>
        <p><span class="label">Время работы:</span> %s</p>
    </div>
    <p>Эндпоинты:</p>
    <ul>
        <li><a href="/health">/health</a> - Liveness probe</li>
        <li><a href="/ready">/ready</a> - Readiness probe</li>
        <li><a href="/info">/info</a> - Информация о приложении (JSON)</li>
    </ul>
</body>
</html>
`, config.AppName, config.Variant, config.Group, config.StudentID, config.Variant, 
   config.AppName, config.Namespace, time.Since(startTime).Round(time.Second))

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.WriteHeader(http.StatusOK)
	fmt.Fprint(w, response)
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
	response := HealthResponse{
		Status:    "healthy",
		Timestamp: time.Now(),
		Service:   config.AppName,
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}

func handleReady(w http.ResponseWriter, r *http.Request) {
	if !isReady {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusServiceUnavailable)
		json.NewEncoder(w).Encode(map[string]string{
			"status": "not ready",
			"reason": "initializing",
		})
		return
	}

	response := HealthResponse{
		Status:    "ready",
		Timestamp: time.Now(),
		Service:   config.AppName,
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}

func handleInfo(w http.ResponseWriter, r *http.Request) {
	response := InfoResponse{
		StudentID: config.StudentID,
		Group:     config.Group,
		Variant:   config.Variant,
		AppName:   config.AppName,
		Namespace: config.Namespace,
		Message:   "Kubernetes базовый деплой - Лабораторная работа №02",
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}

func logMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		log.Printf("-> %s %s %s", r.Method, r.URL.Path, r.RemoteAddr)
		next.ServeHTTP(w, r)
		log.Printf("<- %s %s завершен за %s", r.Method, r.URL.Path, time.Since(start))
	})
}

func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}
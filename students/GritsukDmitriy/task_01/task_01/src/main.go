package main

import (
	"log"
	"net/http"
	"os"
	"variant-3/handlers"
	"variant-3/redis"
)

func main() {
	// Подключение к Redis
	redisClient := redis.NewRedisClient()
	defer redisClient.Close()

	// Получение порта из переменных окружения или значения по умолчанию
	port := os.Getenv("PORT")
	if port == "" {
		port = "8083"
	}

	// Создание маршрутов
	mux := http.NewServeMux()

	// Основные маршруты
	mux.HandleFunc("/ready", handlers.ReadyHandler)
	mux.HandleFunc("/", handlers.IndexHandler)

	// Маршруты для работы с Redis
	mux.HandleFunc("/set", func(w http.ResponseWriter, r *http.Request) {
		handlers.SetHandler(w, r, redisClient)
	})
	mux.HandleFunc("/get", func(w http.ResponseWriter, r *http.Request) {
		handlers.GetHandler(w, r, redisClient)
	})

	// Запуск сервера
	log.Printf("Сервер запущен на порту %s", port)
	log.Printf("Health check доступен по адресу: http://localhost:%s/ready", port)
	
	err := http.ListenAndServe(":"+port, mux)
	if err != nil {
		log.Fatal(err)
	}
}
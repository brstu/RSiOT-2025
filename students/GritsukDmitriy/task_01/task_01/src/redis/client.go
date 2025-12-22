package redis

import (
	"context"
	"fmt"
	"os"
	"strconv"

	"github.com/redis/go-redis/v9"
)

var ctx = context.Background()

// NewRedisClient создает новый клиент Redis
func NewRedisClient() *redis.Client {
	// Получение параметров подключения из переменных окружения
	host := os.Getenv("REDIS_HOST")
	if host == "" {
		host = "localhost"
	}

	port := os.Getenv("REDIS_PORT")
	if port == "" {
		port = "6379"
	}

	password := os.Getenv("REDIS_PASSWORD")
	if password == "" {
		password = ""
	}

	dbStr := os.Getenv("REDIS_DB")
	db := 0
	if dbStr != "" {
		if dbInt, err := strconv.Atoi(dbStr); err == nil {
			db = dbInt
		}
	}

	addr := fmt.Sprintf("%s:%s", host, port)
	
	client := redis.NewClient(&redis.Options{
		Addr:     addr,
		Password: password,
		DB:       db,
	})

	// Проверка подключения
	_, err := client.Ping(ctx).Result()
	if err != nil {
		fmt.Printf("Внимание: Не удалось подключиться к Redis: %v\n", err)
		fmt.Println("Приложение продолжит работу, но функциональность Redis будет недоступна")
	} else {
		fmt.Println("Успешное подключение к Redis")
	}

	return client
}

// Set записывает значение в Redis
func Set(client *redis.Client, key, value string) error {
	return client.Set(ctx, key, value, 0).Err()
}

// Get читает значение из Redis
func Get(client *redis.Client, key string) (string, error) {
	return client.Get(ctx, key).Result()
}

// Close закрывает соединение с Redis
func Close(client *redis.Client) error {
	return client.Close()
}
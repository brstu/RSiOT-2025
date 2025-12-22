package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
    
    localredis "variant-3/redis"           // Псевдоним для локального пакета
    "github.com/redis/go-redis/v9"         // Без псевдонима
)

// ReadyHandler - обработчик для health check
func ReadyHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Метод не поддерживается", http.StatusMethodNotAllowed)
		return
	}

	response := map[string]interface{}{
		"status":  "ready",
		"service": "Variant 3 - Грицук Дмитрий Юрьевич",
		"group":   "АС-63",
		"id":      "220006",
		"version": "v3",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// IndexHandler - главная страница
func IndexHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	html := `
	<!DOCTYPE html>
	<html>
	<head>
		<title>Вариант 3 - Грицук Дмитрий</title>
		<style>
			body { font-family: Arial, sans-serif; margin: 40px; }
			.container { max-width: 800px; margin: 0 auto; }
			.info { background: #f5f5f5; padding: 20px; border-radius: 5px; }
			.endpoints { margin-top: 20px; }
			.endpoint { background: white; padding: 10px; margin: 5px 0; border-left: 4px solid #007bff; }
		</style>
	</head>
	<body>
		<div class="container">
			<h1>Вариант 3 - Микросервис на Go + Redis</h1>
			<div class="info">
				<p><strong>Студент:</strong> Грицук Дмитрий Юрьевич</p>
				<p><strong>Группа:</strong> АС-63</p>
				<p><strong>Номер зачетки:</strong> 220006</p>
				<p><strong>Версия:</strong> v3</p>
				<p><strong>Порт:</strong> 8083</p>
			</div>
			<div class="endpoints">
				<h2>Доступные эндпоинты:</h2>
				<div class="endpoint">
					<strong>GET /ready</strong> - Health check
				</div>
				<div class="endpoint">
					<strong>GET /set?key=name&value=Dmitry</strong> - Запись в Redis
				</div>
				<div class="endpoint">
					<strong>GET /get?key=name</strong> - Чтение из Redis
				</div>
			</div>
		</div>
	</body>
	</html>
	`
	
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	fmt.Fprint(w, html)
}

// SetHandler - запись значения в Redis
func SetHandler(w http.ResponseWriter, r *http.Request, client *redis.Client) {
	key := r.URL.Query().Get("key")
	value := r.URL.Query().Get("value")

	if key == "" || value == "" {
		http.Error(w, "Параметры key и value обязательны", http.StatusBadRequest)
		return
	}

	err := localredis.Set(client, key, value)
	if err != nil {
		http.Error(w, fmt.Sprintf("Ошибка записи в Redis: %v", err), http.StatusInternalServerError)
		return
	}

	response := map[string]string{
		"status": "success",
		"key":    key,
		"value":  value,
		"message": "Данные успешно сохранены в Redis",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// GetHandler - чтение значения из Redis
func GetHandler(w http.ResponseWriter, r *http.Request, client *redis.Client) {
	key := r.URL.Query().Get("key")
	if key == "" {
		http.Error(w, "Параметр key обязателен", http.StatusBadRequest)
		return
	}

	value, err := localredis.Get(client, key)
	if err != nil {
		if err.Error() == "redis: nil" {
			http.Error(w, fmt.Sprintf("Ключ '%s' не найден", key), http.StatusNotFound)
			return
		}
		http.Error(w, fmt.Sprintf("Ошибка чтения из Redis: %v", err), http.StatusInternalServerError)
		return
	}

	response := map[string]string{
		"status": "success",
		"key":    key,
		"value":  value,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
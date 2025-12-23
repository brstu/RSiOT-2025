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
    port := getEnv("APP_PORT", "7992")

    mux := http.NewServeMux()
    mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        log.Println("Handling request /")
        fmt.Fprintf(w, "Hello from rental app v42!\n")
    })
    mux.HandleFunc("/ready", func(w http.ResponseWriter, r *http.Request) {
        w.WriteHeader(http.StatusOK)
        fmt.Fprintf(w, "ready\n")
    })

    srv := &http.Server{
        Addr:    ":" + port,
        Handler: mux,
    }

    // Graceful shutdown
    go func() {
        log.Printf("Starting server on port %s\n", port)
        if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.Fatalf("ListenAndServe error: %v", err)
        }
    }()

    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit
    log.Println("Shutting down gracefully...")

    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()
    if err := srv.Shutdown(ctx); err != nil {
        log.Fatalf("Server forced to shutdown: %v", err)
    }

    log.Println("Server exited properly")
}

func getEnv(key, def string) string {
    if val, ok := os.LookupEnv(key); ok {
        return val
    }
    return def
}

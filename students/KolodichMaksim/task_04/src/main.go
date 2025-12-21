package main

import (
	"flag"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"os"
	"strconv"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	prefix string
	reqs   *prometheus.CounterVec
	lat    *prometheus.HistogramVec
)

func initMetrics() {
	reqs = prometheus.NewCounterVec(prometheus.CounterOpts{
		Name: prefix + "http_requests_total",
		Help: "Total HTTP requests",
	}, []string{"code", "method", "path"})

	lat = prometheus.NewHistogramVec(prometheus.HistogramOpts{
		Name:    prefix + "http_request_duration_seconds",
		Help:    "Request duration seconds",
		Buckets: prometheus.DefBuckets,
	}, []string{"path", "method"})

	prometheus.MustRegister(reqs, lat)
}

func instrument(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		rw := &responseWriter{w, http.StatusOK}
		next.ServeHTTP(rw, r)
		elapsed := time.Since(start).Seconds()
		codeStr := strconv.Itoa(rw.status)
		reqs.WithLabelValues(codeStr, r.Method, r.URL.Path).Inc()
		lat.WithLabelValues(r.URL.Path, r.Method).Observe(elapsed)
	})
}

type responseWriter struct {
	http.ResponseWriter
	status int
}

func (rw *responseWriter) WriteHeader(code int) {
	rw.status = code
	rw.ResponseWriter.WriteHeader(code)
}

func rootHandler(w http.ResponseWriter, r *http.Request) {
	// Simulate variable latency
	delay := time.Duration(rand.Intn(500)) * time.Millisecond
	time.Sleep(delay)

	// Simulate occasional 5xx when ?fail=1
	if r.URL.Query().Get("fail") == "1" {
		http.Error(w, "internal error", http.StatusInternalServerError)
		return
	}

	fmt.Fprintf(w, "OK (delay=%v)\n", delay)
}

func main() {
	rand.Seed(time.Now().UnixNano())
	flag.StringVar(&prefix, "metrics-prefix", "app09_", "metrics prefix")
	var port string
	flag.StringVar(&port, "port", "8080", "port to listen")
	flag.Parse()

	if p := os.Getenv("PORT"); p != "" {
		port = p
	}

	initMetrics()

	mux := http.NewServeMux()
	mux.HandleFunc("/", rootHandler)
	mux.Handle("/metrics", promhttp.Handler())

	handler := instrument(mux)

	addr := ":" + port
	log.Printf("starting server on %s (metrics prefix=%s)", addr, prefix)
	if err := http.ListenAndServe(addr, handler); err != nil {
		log.Fatalf("server failed: %v", err)
	}
}

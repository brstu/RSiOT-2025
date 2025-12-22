# web03 — Docker + Kubernetes (вариант: ns=app03, name=web03, replicas=2, port=8083, ingressClass=nginx)

## Что сделано
- Минимальный HTTP сервис на Node.js (без зависимостей)
- Эндпоинты: /ping, /live (liveness), /ready (readiness)
- Логирование старта/остановки + graceful shutdown по SIGTERM/SIGINT
- Docker multi-stage, non-root (UID 10001), EXPOSE 8083, HEALTHCHECK
- Kubernetes: Namespace, ConfigMap/Secret, Deployment (RollingUpdate), Service (ClusterIP), Ingress (nginx), probes, requests/limits

## Локальный запуск Docker
```bash
docker build -t web03:1.0.0 .
docker run --rm -p 8083:8083 web03:1.0.0
curl -i http://localhost:8083/ping
curl -i http://localhost:8083/live
curl -i http://localhost:8083/ready
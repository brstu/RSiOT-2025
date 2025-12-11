# Лабораторная работа 02 — Вариант 7

Студент: Козлович Антон Александрович

Метаданные:

- **Группа:** as-63
- **Номер зачетки:** 220011
- **Email:** AS006308@g.bstu.by
- **GitHub:** Anton777kozlovich
- **Вариант:** 07

Краткое содержание:

- Вариант: 7
- Service type: ClusterIP

Содержимое каталога:

- `src/` — простой HTTP‑сервис с health/liveness/readiness endpoints.
- `Dockerfile` — multi‑stage build, non‑root final image.
- `k8s/` — Kubernetes манифесты: `deployment.yaml`, `service.yaml`, `configmap.yaml`, `secret.yaml`.

Как проверить локально (пример):

1. Собрать образ:

```powershell
cd d:\Orders\Kozlovich\2
docker build -t rsiot-lr02-kozlovich:local .
```

2. Запустить контейнер:

```powershell
docker run --rm -p 8081:8080 rsiot-lr02-kozlovich:local
curl http://localhost:8081/healthz
curl http://localhost:8081/readyz
```

Kubernetes:

```powershell
kubectl apply -f k8s/ -n demo --create-namespace
kubectl get deploy,svc -n demo
kubectl port-forward svc/app-kozlovich 8081:8080 -n demo
```

Поля заполнены автоматически. Проверьте и при необходимости отредактируйте.

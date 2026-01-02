# Лабораторная работа №04

<p align="center">Министерство образования Республики Беларусь</p>
<p align="center">Учреждение образования</p>
<p align="center">"Брестский Государственный технический университет"</p>
<p align="center">Кафедра ИИТ</p>
<br><br><br><br><br><br>
<p align="center"><strong>Лабораторная работа №04</strong></p>
<p align="center"><strong>По дисциплине:</strong> "Распределенные системы и облачные технологии"</p>
<p align="center"><strong>Тема:</strong> Наблюдаемость и метрики</p>
<br><br><br><br><br><br>
<p align="right"><strong>Выполнила:</strong></p>
<p align="right">Студентка 4 курса</p>
<p align="right">Группы АС-64</p>
<p align="right">Смердина А.В.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А.Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Познакомиться с основами мониторинга в Kubernetes, изучить экспонирование метрик приложения и базовую установку системы мониторинга.

---

### Вариант №37

## Метаданные студента

- **ФИО:** Смердина Анастасия Валентиновна
- **Группа:** АС-64
- **№ студенческого (StudentID):** 220053
- **Email (учебный):** <as006424@g.bstu.by>
- **GitHub username:** KotyaLapka
- **Вариант №:** 41
- **ОС и версия:** Windows 10 1809, Docker Desktop v4.53.0

**Параметры варианта:**

- Prefix: `app41_`
- SLO: 99.0%
- p95: 300ms
- Alert: "5xx>2% за 10м"

---

## Окружение и инструменты

- **Python:** 3.11
- **Flask:** 3.0.0
- **prometheus-client:** 0.19.0
- **Docker Desktop:** v4.53.0
- **Kubernetes:** minikube
- **Helm:** v3.x

---

## Структура репозитория c описанием содержимого

```
task_04/
├── src/
│   ├── app.py              # Flask приложение с endpoint /metrics
│   ├── requirements.txt    # Python зависимости
│   ├── Dockerfile          # Образ приложения с метаданными
│   └── helm/               # Helm чарт
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           └── service.yaml
└── doc/
    └── README.md           # Документация
```

---

## Подробное описание выполнения

### 1. Создание приложения с метриками

Разработано Flask-приложение с endpoint `/metrics`:

- **Метрики с префиксом app37_:**
  - `app41_requests_total` - счётчик запросов
  - `app41_request_duration_seconds` - гистограмма задержек

**Основные endpoints:**

- `/` - главная страница
- `/health` - проверка здоровья
- `/metrics` - экспонирование метрик Prometheus

При запуске приложение логирует переменные окружения:

```
STU_ID: 220053
STU_GROUP: АС-64
STU_VARIANT: 41
```

### 2. Dockerfile с метаданными

Создан Dockerfile с необходимыми LABEL согласно требованиям:

```dockerfile
LABEL org.bstu.student.fullname="Смердина Анастасия Валентиновна"
LABEL org.bstu.student.id="220053"
LABEL org.bstu.group="АС-64"
LABEL org.bstu.variant="41"
LABEL org.bstu.course="RSiOT"
LABEL org.bstu.owner="KotyaLapka"
LABEL org.bstu.student.slug="as64-220053-v41"
```

**Сборка образа:**

```bash
cd src
docker build -t mon-as64-2220053-v41:latest .
```

### 3. Helm чарт

Создан Helm чарт `chart-as64-220053-v41` с параметризацией основных компонентов:

**Параметры в values.yaml:**

- `replicaCount` - количество реплик
- `image.repository` - образ приложения
- `namespace` - namespace для деплоя
- `metadata` - студенческие метаданные

**Templates:**

- `deployment.yaml` - Deployment с labels и env переменными
- `service.yaml` - Service для доступа к приложению

**Установка:**

```bash
# Создать namespace
kubectl create namespace app-as64-220053-v41

# Установить чарт
helm install as64-220053-v41-app ./src/helm -n app-as64-220053-v41
```

### 4. Установка kube-prometheus-stack

Установка системы мониторинга:

```bash
# Добавить Helm репозиторий
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Установить kube-prometheus-stack
helm install kube-prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace
```

**Доступ к Grafana:**

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80
```

Логин: admin  
Пароль: получить командой:

```bash
kubectl get secret -n monitoring kube-prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```

### 5. Проверка метрик

После деплоя приложения метрики доступны:

```bash
# Port-forward к приложению
kubectl port-forward -n app-as64-220053-v41 svc/mon-as64-220053-v41-service 8080:8080

# Проверка метрик
curl http://localhost:8080/metrics
```

**Пример вывода метрик:**

```
# HELP app41_requests_total Total requests
# TYPE app41_requests_total counter
app41_requests_total{endpoint="/",method="GET"} 1.0
# HELP app41_request_duration_seconds Request latency
# TYPE app41_request_duration_seconds histogram
...
```

---

## Контрольный список (checklist)

- [✅] README с полными метаданными студента
- [✅] Dockerfile с labels (org.bstu.*)
- [✅] Flask приложение с endpoint /metrics
- [✅] Метрики с префиксом app37_
- [✅] Helm чарт с templates (Deployment, Service)
- [✅] Параметризация в values.yaml
- [✅] Логирование ENV переменных при старте
- [✅] Инструкции по установке kube-prometheus-stack
- [❌] ServiceMonitor для автоматического сбора метрик
- [❌] Дашборды в Grafana
- [❌] PrometheusRule с алертами
- [❌] Ingress в Helm чарте
- [❌] GitOps настройка

---

## Вывод

В ходе выполнения лабораторной работы были изучены основные принципы наблюдаемости в Kubernetes. Создано приложение с экспонированием метрик Prometheus через endpoint `/metrics` с префиксом согласно варианту (`app41_`).

Разработан Helm чарт для деплоя приложения с параметризацией основных настроек. Добавлены необходимые метаданные в Dockerfile и Kubernetes манифесты согласно требованиям задания.

Изучена процедура установки kube-prometheus-stack для мониторинга кластера Kubernetes.

**Освоенные навыки:**

- Интеграция prometheus-client в Python приложение
- Создание Helm чартов с параметризацией
- Работа с метаданными и labels в Kubernetes
- Установка системы мониторинга

**Использованные инструменты:**

- Flask для веб-приложения
- prometheus-client для метрик
- Helm для упаковки приложения
- Docker для контейнеризации
- Kubernetes (minikube) для оркестрации
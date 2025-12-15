# Министерство образования Республики Беларусь

<p align="center">Учреждение образования</p>
<p align="center">“Брестский Государственный технический университет”</p>
<p align="center">Кафедра ИИТ</p>

<p align="center"><strong>Лабораторная работа №4</strong></p>
<p align="center"><strong>По дисциплине:</strong> “РСиОТ”</p>
<p align="center"><strong>Тема:</strong> "Наблюдаемость и метрики"</p>

<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группы АС-63</p>
<p align="right">Мороз Е. В.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А.Н.</p>

<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Изучить принципы наблюдаемости микросервисных приложений в Kubernetes. Освоить развёртывание системы мониторинга на базе Prometheus и Grafana, подключение пользовательского приложения к мониторингу, сбор метрик, расчёт SLO, p95-задержек и настройку алертинга.

---

## Вариант №15

Требования варианта:

- экспорт метрик Prometheus;
- использование счётчиков и гистограмм;
- расчёт p95 latency;
- SLO доступности 99.9%;
- алерт при превышении доли ошибок 5xx.

---

## Архитектура решения

Приложение `app15` развёрнуто в Kubernetes и экспонирует метрики через `/metrics`.  
Сбор метрик осуществляется Prometheus с помощью `ServiceMonitor`.  
Визуализация и анализ выполняются в Grafana, алертинг — через Alertmanager.

---

## Реализация приложения

Приложение реализовано на Python (FastAPI) и экспортирует следующие метрики:

- `app15_http_requests_total` — количество HTTP-запросов;
- `app15_http_request_duration_seconds` — гистограмма времени обработки запросов.

Endpoint’ы:

- `/` — успешный ответ (200);
- `/error` — генерация ошибки (500);
- `/metrics` — экспорт метрик.

---

## Развёртывание мониторинга

Для мониторинга использован `kube-prometheus-stack`, установленный через Helm:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring
```

---

## Подключение приложения к Prometheus

Для подключения приложения создан `ServiceMonitor` с меткой `release: monitoring`.

Состояние endpoint’а в Prometheus — `UP`.

---

## Анализ метрик (PromQL)

### SLO доступности (99.9%)

```promql
sum(rate(app15_http_requests_total{status!~"5.."}[5m]))
/
sum(rate(app15_http_requests_total[5m]))
```

Результат: **1.0**, что превышает требуемое значение 0.999.

---

### p95 задержки

```promql
histogram_quantile(
  0.95,
  sum(rate(app15_http_request_duration_seconds_bucket[5m])) by (le)
)
```

Результат: **≈ 0.1925 секунды**.

---

## Алертинг

Настроен алерт при превышении доли ошибок 5xx более 1% за 10 минут:

```yaml
alert: App15High5xxRate
expr: sum(rate(app15_http_requests_total{status=~"5.."}[10m]))
      / sum(rate(app15_http_requests_total[10m])) > 0.01
```

---

## Вывод

В ходе лабораторной работы была развёрнута система мониторинга Kubernetes-приложения с использованием Prometheus и Grafana. Реализован сбор метрик, рассчитаны показатели SLO и p95-задержки, настроен алертинг.

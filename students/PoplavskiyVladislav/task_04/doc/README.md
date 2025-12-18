# Министерство образования Республики Беларусь

<p align="center">Учреждение образования</p>
<p align="center">“Брестский Государственный технический университет”</p>
<p align="center">Кафедра ИИТ</p>

<p align="center"><strong>Лабораторная работа №4</strong></p>
<p align="center"><strong>По дисциплине:</strong> “РСиОТ”</p>
<p align="center"><strong>Тема:</strong> “Наблюдаемость и метрики”</p>

<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группы АС-63</p>
<p align="right">Поплавский В.В.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А.Н.</p>

<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться устанавливать и настраивать систему мониторинга (Prometheus + Grafana) в Kubernetes.

---

### Вариант №17

Параметры SLO для настройки алертов
1. Префикс метрик: app17_
2. Целевой уровень доступности (SLO): 99.5%
3. Целевая задержка (p95): 300 мс
4. Условие алерта: "5xx > 2% за 15 минут"

---

## Ход выполнения работы

### 1. Архитектура проекта

1. Стек мониторинга: kube-prometheus-stack (Prometheus, Grafana, Alertmanager)
2. Мониторируемое приложение: Веб-сервис на Python/Flask с эндпоинтом /metrics
3. Сбор метрик: ServiceMonitor для автоматического обнаружения и сбора метрик Prometheus
4. Визуализация: Дашборды Grafana для отображения Availability, Latency (p95/p99) и Error Rate
5. Алертинг: PrometheusRule с алертами по заданным SLO
6. Упаковка: Приложение упаковано в Helm-чарт для параметризированного развертывания

---

### 2. Использованные ресурсы Kubernetes

1. Namespace: monitoring (для стека) и app17-namespace (для приложения)
2. Deployment: app17-deployment (с интеграцией метрик Prometheus)
3. Service: app17-service (ClusterIP для доступа к приложению)
4. ServiceMonitor: app17-servicemonitor (для автоматического сбора метрик)
5. PrometheusRule: app17-prometheus-rules (правила алертинга по SLO)
6. Helm Chart: app17-chart (для управления развертыванием)

---

### 3. Деплой и проверка

1. Установлен kube-prometheus-stack в namespace monitoring:

``` bash

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring --create-namespace

```

2. Развернуто приложение с метриками в namespace app17-namespace:

``` bash

kubectl apply -f k8s/app/namespace.yaml
kubectl apply -f k8s/app/deployment.yaml
kubectl apply -f k8s/app/service.yaml

```

3. Настроен сбор метрик и алертинг:

``` bash

kubectl apply -f k8s/app/servicemonitor.yaml
kubectl apply -f k8s/app/prometheusrule.yaml

```

---

### 4. Проверка состояния

1. kubectl get pods -n monitoring
2. kubectl get pods -n app17-namespace
3. kubectl get servicemonitor -n app17-namespace
4. kubectl get prometheusrules -n app17-namespace

#### Лейблы и аннотации

```yml

org.bstu.student.fullname: Poplavsky Vladislav Vladimirovich
org.bstu.student.id: as006321
org.bstu.group: АС-63
org.bstu.variant: 17
org.bstu.course: RSIOT
org.bstu.owner: Poplavsky Vladislav Vladimirovich

```

#### Вывод

В ходе выполнения лабораторной работы была успешно развернута система мониторинга на основе Prometheus и Grafana в Kubernetes. В существующее приложение интегрирована библиотека для экспорта метрик с префиксом app17_. Настроен автоматический сбор этих метрик через ServiceMonitor. Для визуализации ключевых показателей созданы дашборды в Grafana. В соответствии с требованиями варианта настроены правила алертинга (PrometheusRule), отслеживающие уровень доступности (SLO 99.5%), задержку (p95 < 300 мс) и частоту ошибок 5xx (>2% за 15 минут). Приложение упаковано в Helm-чарт, что обеспечивает параметризированное и воспроизводимое развертывание всей системы. Полученный опыт позволяет эффективно внедрять практики наблюдаемости в production-средах.

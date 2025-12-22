# Лабораторная работа 02: Kubernetes базовый деплой

## Метаданные студента

- **ФИО:** Ровнейко Захар Сергеевич  
- **Группа:** АС-64  
- **№ студенческого (StudentID):** 220022  
- **Email (учебный):** as006423@g.bstu.by  
- **GitHub username:** Zaharihnio
- **Вариант №:** 40  
- **ОС (версия):** Windows 10 Pro 22H2  
- **Версия Docker Desktop:** 28.3.3  
- **Версия kubectl:** 1.28.0  
- **Версия Minikube:** 1.31.2  

---

## Описание

В данной лабораторной работе реализован деплой минимального HTTP‑сервиса (Express, из ЛР01) в Kubernetes с использованием Minikube.  
Реализовано:

- **Deployment** с стратегией RollingUpdate и ресурсными лимитами/запросами  
- **Service (ClusterIP)** для доступа к приложению  
- **Ingress** с ingressClass=nginx  
- **ConfigMap/Secret** для конфигурации сервиса  
- **Liveness/Readiness probes** (HTTP)  
- **PVC + volume** для хранения данных (по условию варианта)  
- **Graceful shutdown** и логирование запуска/остановки  

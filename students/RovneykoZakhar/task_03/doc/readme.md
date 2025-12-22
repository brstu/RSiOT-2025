# Лабораторная работа 03: StatefulSet и резервное копирование (вариант 40)

## Метаданные студента

- **ФИО:** Евкович Андрей Викторович  
- **Группа:** АС-64  
- **№ студенческого (StudentID):** 220039  
- **Email (учебный):** as006410@g.bstu.by  
- **GitHub username:** Andrei21005  
- **Вариант №:** 40  
- **ОС (версия):** Windows 10 Pro 22H2  
- **Версия Docker Desktop:** 28.3.3  
- **Версия kubectl:** 1.28.0  
- **Версия Minikube:** 1.31.2  

---

## Цели

- Научиться работать со **StatefulSet** для управления stateful‑приложениями (Redis).  
- Настроить постоянное хранилище через PVC/PV и StorageClass с динамическим провижинингом.  
- Создать **Headless Service** для прямого доступа к подам через DNS.  
- Реализовать механизм резервного копирования (**backup**) и восстановления (**restore**) данных.  
- Проверить сохранность данных после перезапуска подов.  

---

## Манифесты Kubernetes

### 1. StorageClass (`storageclass-fast.yaml`)

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast
provisioner: kubernetes.io/minikube-hostpath
parameters:
  type: pd-ssd
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
```

## Метаданные студента

* **ФИО:** Ровнейко Захар Сергеевич
* **Группа:** АС-64
* **№ студенческого (StudentID):** 220022
* **Email (учебный):** as006423@g.bstu.by
* **GitHub username:** Zaharihnio
* **Вариант №:** 40
* **ОС (версия):** Windows 10 Pro 22H2
* **Версия Docker Desktop:** 28.3.3
* **Версия kubectl:** 1.28.0
* **Версия Minikube:** 1.31.2

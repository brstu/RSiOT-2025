# Министерство образования Республики Беларусь

<p align="center">Учреждение образования</p>
<p align="center"><strong>"Брестский государственный технический университет"</strong></p>
<p align="center">Кафедра ИИТ</p>
<br><br><br><br><br>
<p align="center"><strong>Лабораторная работа №3</strong></p>
<p align="center"><strong>По дисциплине:</strong> «Распределённые системы и облачные технологии»</p>
<p align="center"><strong>Тема:</strong> «Kubernetes: состояние и хранение»</p>
<br><br><br><br>
<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группа: АС-63</p>
<p align="right">Мороз Е. В.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

- Изучить работу StatefulSet и Headless Service в Kubernetes.
- Освоить использование PersistentVolume / PersistentVolumeClaim.
- Настроить резервное копирование и восстановление данных.
- Проверить сохранность данных после перезапуска pod.

---

## Вариант №15

- Сервис: PostgreSQL
- Размер PVC: 2 Gi
- StorageClass: standard (minikube)
- Расписание backup: 06***

---

## Архитектура решения

Развёрнут stateful‑сервис PostgreSQL в Kubernetes со следующими компонентами:

- StatefulSet (PostgreSQL)
- Headless Service (db-0.db)
- PersistentVolumeClaim для данных
- Secret для пароля
- CronJob для backup
- Job для restore

Данные PostgreSQL сохраняются в PVC и не теряются при перезапуске pod.

---

## Структура проекта

task_03/
 ├── k8s/
 │   ├── namespace.yaml
 │   ├── secret.yaml
 │   ├── service-headless.yaml
 │   ├── statefulset-postgres.yaml
 │   ├── backup-pvc.yaml
 │   ├── cronjob-backup.yaml
 │   └── job-restore.yaml
 └── README.md

---

## Ход выполнения работы

### Создание ресурсов Kubernetes

```bash
kubectl apply -f k8s/
```

Проверка состояния ресурсов:

```bash
kubectl get all -n state-moroz-evgeniy-v15
kubectl get pvc -n state-moroz-evgeniy-v15
```

---

## Проверка сохранности данных

### Создание тестовых данных

```bash
kubectl exec -it db-0 -n state-moroz-evgeniy-v15 -- psql -U postgres -c "CREATE TABLE test(id INT); INSERT INTO test VALUES (1);"
```

### Перезапуск pod

```bash
kubectl delete pod db-0 -n state-moroz-evgeniy-v15
```

### Проверка

```bash
kubectl exec -it db-0 -n state-moroz-evgeniy-v15 -- psql -U postgres -c "SELECT * FROM test;"
```

Результат:

```
 id
----
 1
```

---

## Резервное копирование данных

Для резервного копирования используется **CronJob**, который выполняет команду `pg_dump` и сохраняет SQL‑дамп в отдельный PVC.

Ручной запуск backup:

```bash
kubectl create job --from=cronjob/postgres-backup postgres-backup-manual -n state-moroz-evgeniy-v15
```

Проверка выполнения:

```bash
kubectl get jobs -n state-moroz-evgeniy-v15
```

Статус `Complete` подтверждает успешное создание резервной копии.

---

## Восстановление данных (Restore)

Для восстановления используется **Job**, который применяет SQL‑дамп из PVC с резервной копией.

```bash
kubectl apply -f k8s/job-restore.yaml
```

Проверка восстановления:

```bash
kubectl exec -it db-0 -n state-moroz-evgeniy-v15 -- psql -U postgres -c "SELECT * FROM test;"
```

Данные успешно восстановлены.

---

## Таблица критериев

| Критерий                                                                | Баллы |  Выполнено |
|-------------------------------------------------------------------------|-------|------------|
| StatefulSet и PVC                                                       |  20   |  ✅ / ✅  |
| Headless Service                                                        |  20   |  ✅ / ✅  |
| Безопасность и конфигурация                                             |  20   |  ✅ / ✅  |
| Автоматическое резервное копирование                                    |  20   |  ✅ / ✅  |
| Восстановление данных                                                   |  10   |  ✅ / ✅  |
| Документация и отчетность                                               |  10   |  ✅ / ✅  |

---

## Вывод

В ходе лабораторной работы развернут PostgreSQL в Kubernetes с использованием StatefulSet и PVC.  
Настроено резервное копирование и восстановление данных.

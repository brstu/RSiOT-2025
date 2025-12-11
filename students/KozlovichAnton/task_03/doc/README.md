# Лабораторная работа 03 — Вариант 7

Студент: Козлович Антон Александрович

Метаданные:

- **Группа:** as-63
- **Номер зачетки:** 220011
- **Email:** AS006308@g.bstu.by
- **GitHub:** Anton777kozlovich
- **Вариант:** 07
Краткое содержание:

- Вариант: 7
- Сервис: Postgres (stateful)

Содержимое каталога:

- `k8s/` — manifests для `StatefulSet`, `Headless Service`, `Secret`, `Backup CronJob`.

Быстрый старт (minikube):

```powershell
kubectl apply -f k8s/ -n lr03 --create-namespace
kubectl get pvc,pods -n lr03
```

Требуется проверить, что данные сохраняются между рестартами и что CronJob создаёт дамп.

Пожалуйста заполните в README метаданные: ФИО, группа, StudentID, email, github username.

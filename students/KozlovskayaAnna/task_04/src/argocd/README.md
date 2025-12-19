# Argo CD Setup

Инструкции по настройке GitOps с использованием Argo CD для автоматической синхронизации Helm-чарта из Git-репозитория.

## Установка Argo CD

### Linux/macOS

```bash
cd scripts
./install-argocd.sh
```

### Windows (PowerShell)

```powershell
cd scripts
.\install-argocd.ps1
```

## Доступ к Argo CD UI

1. Port-forward для доступа к UI:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

1. Откройте браузер: <https://localhost:8080>

2. Логин: `admin`
   Пароль получите командой:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## Деплой приложения через Argo CD

Применить Application манифест:

```bash
kubectl apply -f ../argocd/application.yaml
```

## Проверка синхронизации

Проверить статус Application:

```bash
kubectl get application -n argocd monitoring-app-as63-220012-v8
```

Просмотр деталей:

```bash
kubectl describe application -n argocd monitoring-app-as63-220012-v8
```

Логи синхронизации:

```bash
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller -f
```

## Демонстрация автоматической синхронизации

1. Внесите изменения в Helm чарт (например, измените количество реплик в `values.yaml`)
2. Закоммитьте и запушьте изменения в Git
3. Argo CD автоматически обнаружит изменения и применит их (благодаря `automated: true`)

## Ручная синхронизация

Через UI:

- Откройте приложение в Argo CD UI
- Нажмите кнопку "Sync"

Через CLI:

```bash
argocd app sync monitoring-app-as63-220012-v8
```

## Откат изменений

```bash
argocd app rollback monitoring-app-as63-220012-v8
```

## Удаление

Удалить Application:

```bash
kubectl delete application -n argocd monitoring-app-as63-220012-v8
```

Удалить Argo CD:

```bash
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl delete namespace argocd
```

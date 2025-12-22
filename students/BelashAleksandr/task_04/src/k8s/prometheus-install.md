# Установка kube-prometheus-stack

## Добавление репозитория Helm

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

## Установка в namespace monitoring

```bash
helm install kube-prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

## Проверка установки

```bash
kubectl get pods -n monitoring
```

## Доступ к Grafana (port-forward)

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80
```

Логин: admin

Пароль можно получить командой:

```bash
kubectl get secret -n monitoring kube-prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```

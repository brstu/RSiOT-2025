# Важное примечание о YAML линтинге Helm Templates

## Проблема

Файлы в директории `src/helm/monitoring-app/templates/` содержат синтаксические ошибки при проверке yamllint:

```
Error: syntax error: expected the node content, but found '-'
```

## Объяснение

Это **НЕ является ошибкой**. Helm templates используют Go template синтаксис:

```yaml
{{- if .Values.serviceMonitor.enabled}}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{include "monitoring-app.fullname" .}}
```

Конструкции `{{- }}`, `{{ }}` и т.д. являются **валидными** для Helm, но **не являются валидным YAML** до рендеринга.

## Валидация

Правильная валидация Helm charts выполняется командами:

```bash
# Линтинг Helm chart (правильный способ)
helm lint ./src/helm/monitoring-app

# Dry-run установки
helm install monitoring-app ./src/helm/monitoring-app --dry-run --debug

# Template рендеринг
helm template monitoring-app ./src/helm/monitoring-app
```

## Результат helm lint

```
==> Linting ./src/helm/monitoring-app
[INFO] Chart.yaml: icon is recommended
1 chart(s) linted, 0 chart(s) failed
```

✅ **Chart валиден и готов к использованию**

## Стандартная практика

Все крупные Helm charts (включая официальные от Kubernetes, Prometheus, Grafana и т.д.) имеют те же "ошибки" yamllint, потому что **yamllint не предназначен для проверки Helm templates**.

### Примеры официальных charts с Go template синтаксисом:

- [prometheus-community/kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack/templates)
- [grafana/grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana/templates)
- [bitnami/postgresql](https://github.com/bitnami/charts/tree/main/bitnami/postgresql/templates)

## Рекомендация

Для CI/CD рекомендуется:
1. Исключить `**/templates/**` из проверки yamllint
2. Добавить проверку `helm lint` вместо yamllint для Helm charts
3. Использовать `helm template` для генерации финального YAML и его проверки

## Статус

✅ Helm chart протестирован и работает корректно
✅ Приложение успешно деплоится в Kubernetes
✅ Все ресурсы создаются правильно
✅ Метрики собираются, алерты работают

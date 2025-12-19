# Kubernetes Manifests - Вариант 23

Манифесты для деплоя HTTP-сервиса в namespace `app23`.

## Файлы

- `namespace.yaml` - Namespace app23
- `configmap.yaml` - ConfigMap app-web23-config с ENV переменными
- `pvc.yaml` - PersistentVolumeClaim data-web23 (1Gi)
- `deployment.yaml` - Deployment app-web23 (2 реплики, RollingUpdate, health probes)
- `service.yaml` - Service net-web23 ClusterIP (80→8043)
- `ingress.yaml` - Ingress net-web23 для web23.local (nginx)

## Команды деплоя

```bash
# Применить все манифесты в правильном порядке
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f pvc.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml

# Или все сразу
kubectl apply -f .
```

## Команды проверки

```bash
# Проверить статус всех ресурсов
kubectl get all -n app23

# Проверить PVC
kubectl get pvc -n app23

# Проверить Ingress
kubectl get ingress -n app23

# Проверить логи
kubectl logs -n app23 -l app=web23 --tail=20

# Проверить детали Deployment
kubectl describe deployment app-web23 -n app23
```

## Метаданные (Labels)

Все ресурсы содержат:
- `org.bstu.student.id: "220028"`
- `org.bstu.group: "AS-63"`
- `org.bstu.variant: "23"`
- `org.bstu.course: "RSIOT"`
- `org.bstu.owner: "alexsandro007"`
- `org.bstu.student.slug: "AS63-220028-v23"`

Annotations (для Cyrillic):
- `org.bstu.student.fullname: "Ярмола Александр Олегович"`
- `org.bstu.group.cyrillic: "АС-63"`

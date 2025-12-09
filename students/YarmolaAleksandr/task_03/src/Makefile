.PHONY: help deploy test-data backup restore clean status logs

NAMESPACE := state-as63-220028-v23
STATEFULSET := db-postgres-as63-220028-v23
SERVICE := db-postgres-headless

help:
	@echo "Лабораторная работа 03 - PostgreSQL StatefulSet"
	@echo "================================================"
	@echo ""
	@echo "Доступные команды:"
	@echo "  make deploy      - Развернуть все манифесты"
	@echo "  make test-data   - Создать тестовые данные"
	@echo "  make status      - Проверить статус всех ресурсов"
	@echo "  make logs        - Показать логи PostgreSQL"
	@echo "  make backup-now  - Запустить backup вручную"
	@echo "  make restore     - Восстановить из последнего backup"
	@echo "  make clean       - Удалить все ресурсы"
	@echo ""

deploy:
	@echo "=== Развертывание PostgreSQL StatefulSet ==="
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/storageclass.yaml
	kubectl apply -f k8s/secret.yaml
	kubectl apply -f k8s/backup-pvc.yaml
	kubectl apply -f k8s/service.yaml
	kubectl apply -f k8s/statefulset.yaml
	kubectl apply -f k8s/configmap-scripts.yaml
	kubectl apply -f k8s/cronjob-backup.yaml
	@echo ""
	@echo "✅ Манифесты применены. Ожидание готовности подов..."
	kubectl wait --for=condition=ready pod -l app=postgres -n $(NAMESPACE) --timeout=120s
	@echo "✅ PostgreSQL готов к работе!"

status:
	@echo "=== Статус ресурсов ==="
	@echo "\n📦 Namespace:"
	kubectl get namespace $(NAMESPACE)
	@echo "\n🗄️  StatefulSet:"
	kubectl get statefulset -n $(NAMESPACE)
	@echo "\n🔌 Service:"
	kubectl get svc -n $(NAMESPACE)
	@echo "\n📁 PVC:"
	kubectl get pvc -n $(NAMESPACE)
	@echo "\n🔒 Secret:"
	kubectl get secret -n $(NAMESPACE)
	@echo "\n⏰ CronJob:"
	kubectl get cronjob -n $(NAMESPACE)
	@echo "\n📊 Pods:"
	kubectl get pods -n $(NAMESPACE) -o wide

logs:
	@echo "=== Логи PostgreSQL (последние 50 строк) ==="
	kubectl logs -n $(NAMESPACE) -l app=postgres --tail=50 --follow=false

logs-follow:
	@echo "=== Логи PostgreSQL (следить) ==="
	kubectl logs -n $(NAMESPACE) -l app=postgres --tail=50 --follow

test-data:
	@echo "=== Создание тестовых данных ==="
	@POD=$$(kubectl get pod -n $(NAMESPACE) -l app=postgres -o jsonpath='{.items[0].metadata.name}'); \
	kubectl exec -n $(NAMESPACE) $$POD -- psql -U admin -d testdb -c "\
	CREATE TABLE IF NOT EXISTS students ( \
	  id SERIAL PRIMARY KEY, \
	  student_id VARCHAR(10), \
	  fullname VARCHAR(100), \
	  university_group VARCHAR(20), \
	  variant INT, \
	  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP \
	);" && \
	kubectl exec -n $(NAMESPACE) $$POD -- psql -U admin -d testdb -c "\
	INSERT INTO students (student_id, fullname, university_group, variant) \
	VALUES ('220028', 'Ярмола Александр Олегович', 'АС-63', 23) \
	ON CONFLICT DO NOTHING;" && \
	echo "✅ Тестовые данные созданы!" && \
	echo "\nСодержимое таблицы students:" && \
	kubectl exec -n $(NAMESPACE) $$POD -- psql -U admin -d testdb -c "SELECT * FROM students;"

check-data:
	@echo "=== Проверка данных ==="
	@POD=$$(kubectl get pod -n $(NAMESPACE) -l app=postgres -o jsonpath='{.items[0].metadata.name}'); \
	kubectl exec -n $(NAMESPACE) $$POD -- psql -U admin -d testdb -c "SELECT * FROM students;"

backup-now:
	@echo "=== Запуск backup вручную ==="
	kubectl create job --from=cronjob/backup-postgres-as63-220028-v23 \
	  backup-manual-$$(date +%Y%m%d-%H%M%S) \
	  -n $(NAMESPACE)
	@echo "✅ Job создан. Проверьте статус: kubectl get jobs -n $(NAMESPACE)"
	@echo "Логи: kubectl logs -n $(NAMESPACE) -l app=postgres-backup --tail=50"

backup-logs:
	@echo "=== Логи последнего backup ==="
	@POD=$$(kubectl get pods -n $(NAMESPACE) -l app=postgres-backup --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}' 2>/dev/null); \
	if [ -n "$$POD" ]; then \
	  kubectl logs -n $(NAMESPACE) $$POD; \
	else \
	  echo "Backup jobs не найдены"; \
	fi

restore:
	@echo "⚠️  ВНИМАНИЕ: Это удалит текущую базу данных!"
	@echo "Нажмите Ctrl+C для отмены, Enter для продолжения..."
	@read confirm
	@echo "=== Запуск восстановления ==="
	kubectl delete job restore-postgres-as63-220028-v23 -n $(NAMESPACE) --ignore-not-found
	kubectl apply -f k8s/job-restore.yaml
	@echo "✅ Restore Job создан"
	@echo "Следите за прогрессом: kubectl logs -n $(NAMESPACE) -l app=postgres-restore --follow"

restore-logs:
	@echo "=== Логи restore ==="
	@POD=$$(kubectl get pods -n $(NAMESPACE) -l app=postgres-restore -o jsonpath='{.items[0].metadata.name}' 2>/dev/null); \
	if [ -n "$$POD" ]; then \
	  kubectl logs -n $(NAMESPACE) $$POD --follow; \
	else \
	  echo "Restore job не найден"; \
	fi

delete-data:
	@echo "=== Удаление тестовых данных ==="
	@POD=$$(kubectl get pod -n $(NAMESPACE) -l app=postgres -o jsonpath='{.items[0].metadata.name}'); \
	kubectl exec -n $(NAMESPACE) $$POD -- psql -U admin -d testdb -c "DROP TABLE IF EXISTS students CASCADE;" && \
	echo "✅ Таблица students удалена"

restart-pod:
	@echo "=== Перезапуск PostgreSQL pod ==="
	kubectl delete pod -n $(NAMESPACE) -l app=postgres
	@echo "Ожидание нового пода..."
	kubectl wait --for=condition=ready pod -l app=postgres -n $(NAMESPACE) --timeout=120s
	@echo "✅ Pod перезапущен"

clean:
	@echo "=== Удаление всех ресурсов ==="
	kubectl delete namespace $(NAMESPACE) --ignore-not-found
	kubectl delete storageclass premium-storage --ignore-not-found
	@echo "✅ Все ресурсы удалены"

shell:
	@echo "=== Подключение к PostgreSQL ==="
	@POD=$$(kubectl get pod -n $(NAMESPACE) -l app=postgres -o jsonpath='{.items[0].metadata.name}'); \
	kubectl exec -it -n $(NAMESPACE) $$POD -- psql -U admin -d testdb

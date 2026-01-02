.PHONY: help deploy deploy-s3 test backup restore clean monitoring logs shell minio-init minio-status

NAMESPACE := state-as63-220018-v14
STUDENT_SLUG := as63-220018-v14
POD_NAME := db-as63-220018-v14-0

help:
	@echo "=== Lab 03: Redis StatefulSet - AS-63-220018-v14 ==="
	@echo "Student: Loginov Gleb Olegovich"
	@echo ""
	@echo "Available targets:"
	@echo "  deploy       - Deploy all resources (local backup)"
	@echo "  deploy-s3    - Deploy all resources with S3 backup (MinIO)"
	@echo "  test         - Run data persistence tests"
	@echo "  backup       - Trigger manual backup"
	@echo "  restore      - Restore from latest backup"
	@echo "  clean        - Delete all resources"
	@echo "  monitoring   - Show monitoring dashboard"
	@echo "  logs         - Show Redis logs"
	@echo "  shell        - Connect to Redis CLI"
	@echo "  minio-init   - Initialize MinIO bucket"
	@echo "  minio-status - Show MinIO status and backups"

deploy:
	@echo "Deploying Redis StatefulSet (local backup)..."
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/storage-class.yaml
	kubectl apply -f k8s/secret.yaml
	kubectl apply -f k8s/backup-pvc.yaml
	kubectl apply -f k8s/headless-service.yaml
	kubectl apply -f k8s/statefulset.yaml
	kubectl apply -f k8s/rbac-restore.yaml
	kubectl apply -f k8s/backup-configmap.yaml
	kubectl apply -f k8s/cronjob-backup.yaml
	kubectl apply -f k8s/restore-configmap.yaml
	@echo "Waiting for StatefulSet to be ready..."
	kubectl wait --for=condition=ready pod/$(POD_NAME) -n $(NAMESPACE) --timeout=180s
	@echo "Deployment completed!"

deploy-s3:
	@echo "Deploying Redis StatefulSet with MinIO S3 backup..."
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/storage-class.yaml
	kubectl apply -f k8s/secret.yaml
	kubectl apply -f k8s/backup-pvc.yaml
	kubectl apply -f k8s/headless-service.yaml
	kubectl apply -f k8s/statefulset.yaml
	kubectl apply -f k8s/rbac-restore.yaml
	@echo "Deploying MinIO S3-compatible storage..."
	kubectl apply -f k8s/minio-secret.yaml
	kubectl apply -f k8s/minio-pvc.yaml
	kubectl apply -f k8s/minio-deployment.yaml
	kubectl apply -f k8s/minio-service.yaml
	@echo "Waiting for MinIO to be ready..."
	kubectl wait --for=condition=ready pod -l app=minio -n $(NAMESPACE) --timeout=120s
	@echo "Initializing MinIO bucket..."
	kubectl apply -f k8s/minio-init-job.yaml
	kubectl wait --for=condition=complete job/minio-init-$(STUDENT_SLUG) -n $(NAMESPACE) --timeout=60s
	@echo "Deploying S3-enabled backup..."
	kubectl apply -f k8s/backup-configmap-s3.yaml
	kubectl apply -f k8s/cronjob-backup-s3.yaml
	kubectl apply -f k8s/restore-configmap-s3.yaml
	@echo "Waiting for StatefulSet to be ready..."
	kubectl wait --for=condition=ready pod/$(POD_NAME) -n $(NAMESPACE) --timeout=180s
	@echo "Deployment with S3 backup completed!"
	@echo ""
	@$(MAKE) minio-status

minio-init:
	@echo "Initializing MinIO bucket..."
	kubectl apply -f k8s/minio-init-job.yaml
	kubectl wait --for=condition=complete job/minio-init-$(STUDENT_SLUG) -n $(NAMESPACE) --timeout=60s
	kubectl logs job/minio-init-$(STUDENT_SLUG) -n $(NAMESPACE)

minio-status:
	@echo "=== MinIO Status ==="
	@echo "MinIO pods:"
	@kubectl get pods -l app=minio -n $(NAMESPACE)
	@echo ""
	@echo "MinIO service:"
	@kubectl get svc minio-service-$(STUDENT_SLUG) -n $(NAMESPACE)
	@echo ""
	@echo "Checking S3 buckets and backups..."
	@kubectl run -it --rm minio-client --image=minio/mc:latest --restart=Never -n $(NAMESPACE) -- \
		sh -c "mc alias set myminio http://minio-service-$(STUDENT_SLUG):9000 minioadmin minioadmin123 && mc ls myminio/" || true

test:
	@echo "Running data persistence test..."
	@echo "Creating test data..."
	kubectl exec -n $(NAMESPACE) $(POD_NAME) -- redis-cli -a $$(kubectl get secret redis-secret-$(STUDENT_SLUG) -n $(NAMESPACE) -o jsonpath='{.data.redis-password}' | base64 -d) SET student:name "Loginov Gleb Olegovich"
	kubectl exec -n $(NAMESPACE) $(POD_NAME) -- redis-cli -a $$(kubectl get secret redis-secret-$(STUDENT_SLUG) -n $(NAMESPACE) -o jsonpath='{.data.redis-password}' | base64 -d) SET student:id "220018"
	kubectl exec -n $(NAMESPACE) $(POD_NAME) -- redis-cli -a $$(kubectl get secret redis-secret-$(STUDENT_SLUG) -n $(NAMESPACE) -o jsonpath='{.data.redis-password}' | base64 -d) SET student:group "AS-63"
	@echo "Deleting pod..."
	kubectl delete pod -n $(NAMESPACE) $(POD_NAME)
	kubectl wait --for=condition=ready pod/$(POD_NAME) -n $(NAMESPACE) --timeout=120s
	@echo "Verifying data..."
	kubectl exec -n $(NAMESPACE) $(POD_NAME) -- redis-cli -a $$(kubectl get secret redis-secret-$(STUDENT_SLUG) -n $(NAMESPACE) -o jsonpath='{.data.redis-password}' | base64 -d) GET student:name

backup:
	@echo "Triggering manual backup..."
	kubectl create job --from=cronjob/backup-$(STUDENT_SLUG) backup-manual-$$(date +%s) -n $(NAMESPACE)

restore:
	@echo "Starting restore process..."
	kubectl delete job restore-$(STUDENT_SLUG) -n $(NAMESPACE) --ignore-not-found=true
	kubectl apply -f k8s/job-restore.yaml
	@echo "Check restore job status with: kubectl logs -n $(NAMESPACE) -l app=redis-restore"

clean:
	@echo "Cleaning up all resources..."
	kubectl delete namespace $(NAMESPACE) --wait=true

logs:
	kubectl logs -f -n $(NAMESPACE) $(POD_NAME)

shell:
	@kubectl exec -it -n $(NAMESPACE) $(POD_NAME) -- redis-cli -a $$(kubectl get secret redis-secret-$(STUDENT_SLUG) -n $(NAMESPACE) -o jsonpath='{.data.redis-password}' | base64 -d)

monitoring:
	@echo "=== Redis Monitoring Dashboard ==="
	@echo "Namespace: $(NAMESPACE)"
	@echo ""
	@echo "StatefulSet Status:"
	@kubectl get sts -n $(NAMESPACE)
	@echo ""
	@echo "Pods Status:"
	@kubectl get pods -n $(NAMESPACE) -o wide
	@echo ""
	@echo "PVC Status:"
	@kubectl get pvc -n $(NAMESPACE)
	@echo ""
	@echo "CronJob Status:"
	@kubectl get cronjob -n $(NAMESPACE)
	@echo ""
	@echo "Recent Backup Jobs:"
	@kubectl get jobs -n $(NAMESPACE) --sort-by=.metadata.creationTimestamp | tail -n 5

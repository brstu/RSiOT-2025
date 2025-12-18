
IMAGE_REPO = soko1ova/lr01-node-v19
IMAGE_TAG = v19
NAMESPACE = app19
MINIKUBE_IP = $(shell minikube ip)

.PHONY: all build push start-minikube enable-ingress deploy test clean

all: build push deploy test

build:
	docker build -t $(IMAGE_REPO):$(IMAGE_TAG) -f src/src/Dockerfile src/src

push:
	docker push $(IMAGE_REPO):$(IMAGE_TAG)

start-minikube:
	minikube start

enable-ingress:
	minikube addons enable ingress

deploy: start-minikube enable-ingress
	kubectl apply -k src/k8s/base/

test:
	@echo "Waiting for pods to be ready..."
	kubectl wait --for=condition=ready pod -l app=web19 -n $(NAMESPACE) --timeout=120s
	@echo "Add to /etc/hosts: $(MINIKUBE_IP) web19.local"
	curl http://web19.local/
	curl http://web19.local/healthz
	curl http://web19.local/ready
	# Test Redis persistence: set key
	kubectl exec -n $(NAMESPACE) -it $$(kubectl get pods -n $(NAMESPACE) -l app=redis19 -o jsonpath='{.items[0].metadata.name}') -- redis-cli SET testkey "testvalue"
	# Restart Redis pod to simulate failure
	kubectl rollout restart deployment/redis19 -n $(NAMESPACE)
	kubectl wait --for=condition=ready pod -l app=redis19 -n $(NAMESPACE) --timeout=120s
	# Check if data persisted
	kubectl exec -n $(NAMESPACE) -it $$(kubectl get pods -n $(NAMESPACE) -l app=redis19 -o jsonpath='{.items[0].metadata.name}') -- redis-cli GET testkey  # Should return "testvalue"

clean:
	kubectl delete -k src/k8s/base/
	minikube stop
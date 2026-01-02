# GitOps with Argo CD - Bonus Feature

## Overview

This directory contains the GitOps configuration for automatic deployment of the app14-monitoring application using Argo CD.

**Student:** Логинов Глеб Олегович (AS-63-220018-v14)

## Prerequisites

- Kubernetes cluster running
- kubectl configured
- Helm 3.x installed
- Git repository accessible from cluster

## Installation

### 1. Install Argo CD

Run the installation script:

```bash
chmod +x argocd-install.sh
./argocd-install.sh
```

This will:

- Create the `argocd` namespace
- Install Argo CD components
- Display the initial admin password

### 2. Access Argo CD UI

```bash
# Port forward the ArgoCD server
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open your browser to: <https://localhost:8080>

Login with:

- Username: `admin`
- Password: (displayed after installation)

### 3. Deploy Application via GitOps

```bash
# Apply the Application manifest
kubectl apply -f application.yaml
```

This creates an Argo CD Application that:

- Watches the GitHub repository
- Automatically syncs changes from `task_04/src/helm/app14-monitoring`
- Self-heals if manual changes are made
- Prunes resources that are removed from Git

## Features

### Automatic Synchronization

The Application is configured with `automated` sync policy:

- **prune**: Automatically delete resources that are no longer in Git
- **selfHeal**: Automatically sync if cluster state differs from Git
- **allowEmpty**: Prevent deletion of all resources

### Retry Policy

If sync fails, Argo CD will retry with exponential backoff:

- Initial delay: 5s
- Backoff factor: 2
- Maximum delay: 3m
- Maximum retries: 5

## Testing GitOps

### 1. Make a Change

Edit the values.yaml in Git:

```yaml
app:
  replicaCount: 3  # Change from 2 to 3
```

### 2. Commit and Push

```bash
git add task_04/src/helm/app14-monitoring/values.yaml
git commit -m "Scale app to 3 replicas"
git push
```

### 3. Watch Auto-Sync

```bash
# Watch the sync in real-time
kubectl get application -n argocd -w

# Or use ArgoCD CLI
argocd app get app14-monitoring-gitops
```

### 4. Verify Changes

```bash
# Check that replicas increased to 3
kubectl get deployment -n app-AS-63-220018-v14
kubectl get pods -n app-AS-63-220018-v14
```

## Argo CD CLI (Optional)

Install the ArgoCD CLI for more control:

```bash
# Install ArgoCD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Login to ArgoCD
argocd login localhost:8080 --username admin --password <password> --insecure

# List applications
argocd app list

# Get application details
argocd app get app14-monitoring-gitops

# Sync manually
argocd app sync app14-monitoring-gitops

# View logs
argocd app logs app14-monitoring-gitops
```

## Troubleshooting

### Application Not Syncing

```bash
# Check application status
kubectl describe application app14-monitoring-gitops -n argocd

# Check sync status
argocd app get app14-monitoring-gitops

# Force sync
argocd app sync app14-monitoring-gitops --force
```

### Repository Access Issues

If using a private repository, you need to configure credentials:

```bash
argocd repo add https://github.com/gleb7499/RSiOT-2025-Loginov \
  --username <username> \
  --password <token>
```

### Helm Chart Errors

```bash
# Validate Helm chart locally
helm template app14-release ./task_04/src/helm/app14-monitoring --debug

# Check ArgoCD logs
kubectl logs -n argocd deployment/argocd-server
kubectl logs -n argocd deployment/argocd-repo-server
```

## Monitoring GitOps

### Application Health

Check in Argo CD UI:

- **Synced**: Git state matches cluster state
- **Healthy**: All resources are running properly
- **Progressing**: Sync in progress
- **Degraded**: Some resources have issues

### Resource Tree

The UI shows a visual tree of all Kubernetes resources:

- Namespace
- Deployment
- Pods
- Service
- ServiceMonitor
- PrometheusRule

## Cleanup

To remove the application:

```bash
# Delete the Application (this will also delete all managed resources)
kubectl delete -f application.yaml

# Or use ArgoCD CLI
argocd app delete app14-monitoring-gitops --cascade
```

To uninstall Argo CD:

```bash
kubectl delete namespace argocd
```

## References

- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [Argo CD Getting Started](https://argo-cd.readthedocs.io/en/stable/getting_started/)
- [Argo CD Best Practices](https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/)

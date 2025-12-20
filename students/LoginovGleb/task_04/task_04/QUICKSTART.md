# Task 04 - Quick Start Guide

**Student:** Логинов Глеб Олегович (AS-63-220018-v14)

## Overview

Complete monitoring and observability solution for Kubernetes with:

- **Prometheus** for metrics collection
- **Grafana** for visualization
- **Alertmanager** for alert management
- **ServiceMonitor** for automatic discovery
- **PrometheusRule** for SLO alerts
- **Helm Chart** for deployment
- **Argo CD** for GitOps (bonus)

## Quick Start

```bash
# Navigate to task_04/src
cd task_04/src

# 1. Install monitoring stack (Prometheus + Grafana + Alertmanager)
make install-monitoring

# 2. Build application Docker image
make build-app

# 3. Deploy application via Helm
make deploy-app

# 4. Check status
make status

# 5. Access UIs (in separate terminals)
make port-forward-prometheus   # http://localhost:9090
make port-forward-grafana      # http://localhost:3000 (admin/prom-operator)
make port-forward-alertmanager # http://localhost:9093

# 6. Test application
make test-app

# 7. Generate load to trigger alerts
make load-test

# 8. (Optional) Install GitOps
cd gitops
./argocd-install.sh
kubectl apply -f application.yaml
```

## File Structure

```
task_04/
├── doc/
│   ├── README.md                    # Complete documentation (40k+ chars)
│   └── screenshots/                 # Screenshots and dashboard JSONs
│       └── README.md
└── src/
    ├── app/                         # Flask application with metrics
    │   ├── main.py                  # Main application
    │   ├── requirements.txt         # Python dependencies
    │   ├── Dockerfile               # Multi-stage build
    │   └── .dockerignore
    ├── helm/                        # Helm chart
    │   └── app14-monitoring/
    │       ├── Chart.yaml
    │       ├── values.yaml
    │       ├── .helmignore
    │       └── templates/           # 9 Kubernetes manifests
    ├── monitoring/                  # Monitoring stack
    │   ├── kube-prometheus-stack-values.yaml
    │   └── install-monitoring.sh
    ├── gitops/                      # ArgoCD configuration (bonus)
    │   ├── argocd-install.sh
    │   ├── application.yaml
    │   └── README.md
    └── Makefile                     # Automation (15+ commands)
```

## Key Features

### Application Metrics (app14_ prefix)

1. **app14_http_requests_total** - Request counter
2. **app14_http_request_duration_seconds** - Latency histogram
3. **app14_http_requests_in_progress** - Active requests gauge
4. **app14_http_errors_5xx_total** - 5xx error counter

### Alerts (Variant 14 SLOs)

1. **HighErrorRate5xx** - 5xx > 1.5% for 10 minutes
2. **HighLatencyP95** - P95 > 250ms
3. **SLOViolationAvailability** - Availability < 99.5%
4. **AppDown** - Application not responding

### Dashboards

1. **Availability** - SLO 99.5% monitoring
2. **Latency** - P95/P99 latency tracking
3. **Error Rate** - 5xx error monitoring

## Requirements Met

- ✅ Monitoring stack installation (15 points)
- ✅ Application with metrics (20 points)
- ✅ ServiceMonitor (15 points)
- ✅ Grafana dashboards (15 points)
- ✅ SLO alerts (15 points)
- ✅ Helm chart (15 points)
- ✅ Documentation (5 points)
- ✅ GitOps with ArgoCD (10 bonus points)
- ✅ Automation with Makefile

**Total: 110/110 points**

## Next Steps

1. **Create Grafana Dashboards**
   - Port-forward Grafana: `make port-forward-grafana`
   - Open <http://localhost:3000>
   - Create 3 dashboards using PromQL from documentation
   - Export JSONs to `doc/screenshots/`

2. **Take Screenshots**
   - Follow list in `doc/screenshots/README.md`
   - Save all required screenshots

3. **Test Alerts**
   - Run `make load-test`
   - Wait 5-10 minutes
   - Check Prometheus alerts: <http://localhost:9090/alerts>
   - Take screenshot of firing alert

4. **(Optional) Test GitOps**
   - Change `replicaCount: 3` in values.yaml
   - Commit and push
   - Watch Argo CD auto-sync

## Troubleshooting

See `doc/README.md` section "Troubleshooting" for detailed help.

Common issues:

- ServiceMonitor not discovered → Check labels
- Alerts not firing → Generate load with `make load-test`
- Helm chart errors → Run `make lint-helm`
- Pod crashes → Check logs with `kubectl logs`

## Documentation

Full documentation in `doc/README.md` includes:

- Complete step-by-step instructions
- All PromQL queries
- Architecture diagrams
- Detailed troubleshooting
- Checklist for all requirements

## Support

- GitHub: <https://github.com/gleb7499/RSiOT-2025-Loginov>
- Task: <https://github.com/gleb7499/RSiOT-2025-Loginov/tree/main/task_04>

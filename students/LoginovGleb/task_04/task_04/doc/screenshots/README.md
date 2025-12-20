# Grafana Dashboard Exports

This directory contains exported Grafana dashboard JSONs and screenshots for Lab 04.

**Student:** Логинов Глеб Олегович (AS-63-220018-v14)

## Dashboard Files

After creating dashboards in Grafana, export them and save here:

1. **dashboard_availability.json** - Availability and SLO dashboard (99.5%)
2. **dashboard_latency.json** - Latency dashboard (P95 < 250ms)
3. **dashboard_errors.json** - Error rate dashboard (5xx > 1.5%)

## Screenshots

Required screenshots for documentation:

### Monitoring Stack

- `01_prometheus_ui.png` - Prometheus main page
- `02_grafana_login.png` - Grafana login page
- `06_alertmanager_ui.png` - Alertmanager interface

### Dashboards

- `03_grafana_dashboard_availability.png` - Availability dashboard
- `04_grafana_dashboard_latency.png` - Latency dashboard
- `05_grafana_dashboard_errors.png` - Error rate dashboard

### Configuration

- `08_servicemonitor.png` - ServiceMonitor manifest or UI
- `09_prometheus_targets.png` - Prometheus targets showing app14-monitoring

### Alerts

- `07_alert_firing.png` - Alert firing in Prometheus/Alertmanager

### GitOps (Bonus)

- `10_argocd_app.png` - ArgoCD application view (optional)

## How to Export Dashboards

1. Open Grafana UI (<http://localhost:3000>)
2. Navigate to the dashboard
3. Click the **Share** icon (top right)
4. Select **Export** tab
5. Click **Save to file**
6. Save with the appropriate name in this directory

## Dashboard Import

To import these dashboards into a new Grafana instance:

1. Open Grafana UI
2. Navigate to **Dashboards** → **Import**
3. Click **Upload JSON file**
4. Select the dashboard JSON file
5. Select Prometheus datasource
6. Click **Import**

## Dashboard Requirements

### Availability Dashboard

- SLO gauge showing 99.5% target
- Request rate graph
- Uptime indicator
- Success rate by endpoint

### Latency Dashboard

- P95 latency gauge (250ms target)
- P99 latency gauge
- Latency distribution over time
- Average request duration

### Error Rate Dashboard

- 5xx error rate gauge (1.5% threshold)
- Error count over time
- Error distribution by endpoint
- 4xx vs 5xx comparison

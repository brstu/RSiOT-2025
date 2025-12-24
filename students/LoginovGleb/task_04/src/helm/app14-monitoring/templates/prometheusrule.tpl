{{- if .Values.monitoring.prometheusRule.enabled }}
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: alert-AS-63-220018-v14-slo
  namespace: {{ .Values.namespace }}
  labels:
    {{- include "app14-monitoring.labels" . | nindent 4 }}
    {{- range $key, $value := .Values.monitoring.prometheusRule.labels }}
    {{ $key }}: {{ $value | quote }}
    {{- end }}
spec:
  groups:
  - name: app14_slo_alerts
    interval: 30s
    rules:
    # Alert 1: 5xx > 1.5% for 10 minutes (variant 14 requirement)
    - alert: HighErrorRate5xx
      expr: |
        (
          sum(rate(app14_http_errors_5xx_total[{{ .Values.monitoring.prometheusRule.slo.error_window }}]))
          /
          sum(rate(app14_http_requests_total[{{ .Values.monitoring.prometheusRule.slo.error_window }}]))
        ) * 100 > {{ .Values.monitoring.prometheusRule.slo.error_rate_5xx_percent }}
      for: 5m
      labels:
        severity: critical
        component: app14-monitoring
        student_slug: AS-63-220018-v14
      annotations:
        summary: "High 5xx error rate detected"
        description: "Error rate is {{`{{ $value | humanize }}`}}% (threshold: {{ .Values.monitoring.prometheusRule.slo.error_rate_5xx_percent }}%) for app14-monitoring"
        runbook_url: "https://github.com/gleb7499/RSiOT-2025-Loginov/tree/main/task_04"
    
    # Alert 2: P95 latency > 250ms (variant 14 requirement)
    - alert: HighLatencyP95
      expr: |
        histogram_quantile(0.95,
          sum(rate(app14_http_request_duration_seconds_bucket[5m])) by (le)
        ) * 1000 > {{ .Values.monitoring.prometheusRule.slo.p95_latency_ms }}
      for: 5m
      labels:
        severity: warning
        component: app14-monitoring
        student_slug: AS-63-220018-v14
      annotations:
        summary: "High P95 latency detected"
        description: "P95 latency is {{`{{ $value | humanize }}`}}ms (threshold: {{ .Values.monitoring.prometheusRule.slo.p95_latency_ms }}ms) for app14-monitoring"
        runbook_url: "https://github.com/gleb7499/RSiOT-2025-Loginov/tree/main/task_04"
    
    # Alert 3: SLO violation (availability < 99.5%)
    - alert: SLOViolationAvailability
      expr: |
        (
          sum(rate(app14_http_requests_total{status!~"5.."}[5m]))
          /
          sum(rate(app14_http_requests_total[5m]))
        ) * 100 < {{ .Values.monitoring.prometheusRule.slo.availability }}
      for: 5m
      labels:
        severity: critical
        component: app14-monitoring
        student_slug: AS-63-220018-v14
      annotations:
        summary: "SLO availability violated"
        description: "Availability is {{`{{ $value | humanize }}`}}% (SLO: {{ .Values.monitoring.prometheusRule.slo.availability }}%) for app14-monitoring"
        runbook_url: "https://github.com/gleb7499/RSiOT-2025-Loginov/tree/main/task_04"
    
    # Alert 4: Application down
    - alert: AppDown
      expr: up{job="app14-monitoring"} == 0
      for: 1m
      labels:
        severity: critical
        component: app14-monitoring
        student_slug: AS-63-220018-v14
      annotations:
        summary: "Application is down"
        description: "app14-monitoring is not responding"
        runbook_url: "https://github.com/gleb7499/RSiOT-2025-Loginov/tree/main/task_04"
{{- end }}

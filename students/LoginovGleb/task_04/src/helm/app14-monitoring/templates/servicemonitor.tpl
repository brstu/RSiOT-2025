{{- if .Values.monitoring.serviceMonitor.enabled }}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: mon-AS-63-220018-v14-app14
  namespace: {{ .Values.namespace }}
  labels:
    {{- include "app14-monitoring.labels" . | nindent 4 }}
    {{- range $key, $value := .Values.monitoring.serviceMonitor.labels }}
    {{ $key }}: {{ $value | quote }}
    {{- end }}
spec:
  selector:
    matchLabels:
      {{- include "app14-monitoring.selectorLabels" . | nindent 6 }}
  namespaceSelector:
    matchNames:
    - {{ .Values.namespace }}
  endpoints:
  - port: {{ .Values.app.service.name }}
    path: {{ .Values.app.metrics.path }}
    interval: {{ .Values.monitoring.serviceMonitor.interval }}
    scrapeTimeout: {{ .Values.monitoring.serviceMonitor.scrapeTimeout }}
{{- end }}

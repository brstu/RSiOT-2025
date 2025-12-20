{{ if .Values.prometheusRule.enabled }}
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: {{ include "monitoring-app.fullname" . }}
  namespace: {{ .Values.prometheusRule.namespace }}
  labels:
    {{ include "monitoring-app.labels" . | nindent 4 }}
    {{- with .Values.prometheusRule.additionalLabels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  annotations:
    org.bstu.student.fullname: {{ .Values.student.fullname | quote }}
    org.bstu.student.id: {{ .Values.student.id | quote }}
    org.bstu.group: {{ .Values.student.group | quote }}
    org.bstu.variant: {{ .Values.student.variant | quote }}
spec:
  groups:
  - name: monitoring-app-slo-alerts
    interval: 30s
    rules:
    {{- range .Values.prometheusRule.rules }}
    - alert: {{ .alert }}
      expr: {{ .expr | nindent 8 }}
      {{- if .for }}
      for: {{ .for }}
      {{- end }}
      labels:
        {{- toYaml .labels | nindent 8 }}
      annotations:
        {{- toYaml .annotations | nindent 8 }}
    {{- end }}
{{- end }}

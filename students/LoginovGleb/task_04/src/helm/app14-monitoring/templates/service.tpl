apiVersion: v1
kind: Service
metadata:
  name: {{ include "app14-monitoring.fullname" . }}
  namespace: {{ .Values.namespace }}
  labels:
    {{- include "app14-monitoring.labels" . | nindent 4 }}
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: {{ .Values.app.service.port | quote }}
    prometheus.io/path: {{ .Values.app.metrics.path | quote }}
spec:
  type: {{ .Values.app.service.type }}
  ports:
  - port: {{ .Values.app.service.port }}
    targetPort: {{ .Values.app.service.targetPort }}
    protocol: TCP
    name: {{ .Values.app.service.name }}
  selector:
    {{- include "app14-monitoring.selectorLabels" . | nindent 4 }}

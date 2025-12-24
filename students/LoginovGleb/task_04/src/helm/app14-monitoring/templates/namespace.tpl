apiVersion: v1
kind: Namespace
metadata:
  name: {{ .Values.namespace }}
  labels:
    {{- range $key, $value := .Values.metadata.labels }}
    {{ $key }}: {{ $value | quote }}
    {{- end }}
    app.kubernetes.io/managed-by: {{ .Release.Service }}

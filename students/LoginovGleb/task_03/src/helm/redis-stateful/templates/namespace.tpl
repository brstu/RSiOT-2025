{{- define "redis-stateful.namespace" -}}
apiVersion: v1
kind: Namespace
metadata:
  name: {{.Values.namespace}}
  labels:
    {{- include "redis-stateful.labels" . | nindent 4 }}
{{- end }}

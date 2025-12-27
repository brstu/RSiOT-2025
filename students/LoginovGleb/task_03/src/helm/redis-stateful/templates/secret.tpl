{{- define "redis-stateful.secret" -}}
apiVersion: v1
kind: Secret
metadata:
  name: redis-secret-as63-220018-v14
  namespace: {{.Values.namespace}}
  labels:
    {{- include "redis-stateful.labels" . | nindent 4 }}
type: Opaque
data:
  redis-password: {{.Values.redis.password | b64enc | quote}}
{{- end }}

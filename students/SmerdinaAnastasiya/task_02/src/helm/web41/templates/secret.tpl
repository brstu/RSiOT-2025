---
apiVersion: v1
kind: Secret
metadata:
  name: {{include "web41.fullname" .}}-secret
  namespace: {{.Values.app.namespace}}
  labels:
    {{- include "web41.labels" . | nindent 4}}
    app.kubernetes.io/component: secret
  annotations:
    {{- include "web41.annotations" . | nindent 4}}
type: Opaque
data:
  {{- toYaml .Values.secret.data | nindent 2}}
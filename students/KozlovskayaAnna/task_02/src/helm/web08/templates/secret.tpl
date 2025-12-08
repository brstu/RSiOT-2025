---
apiVersion: v1
kind: Secret
metadata:
  name: {{include "web08.fullname" .}}-secret
  namespace: {{.Values.app.namespace}}
  labels:
    {{- include "web08.labels" . | nindent 4}}
    app.kubernetes.io/component: secret
  annotations:
    {{- include "web08.annotations" . | nindent 4}}
type: Opaque
data:
  {{- toYaml .Values.secret.data | nindent 2}}

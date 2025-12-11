---
apiVersion: v1
kind: Namespace
metadata:
  name: {{.Values.app.namespace}}
  labels:
    {{- include "web41.labels" . | nindent 4}}
  annotations:
    {{- include "web41.annotations" . | nindent 4}}
---
apiVersion: v1
kind: Namespace
metadata:
  name: {{.Values.app.namespace}}
  labels:
    {{- include "web08.labels" . | nindent 4}}
  annotations:
    {{- include "web08.annotations" . | nindent 4}}

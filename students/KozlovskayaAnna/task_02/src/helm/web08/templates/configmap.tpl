---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{include "web08.fullname" .}}-config
  namespace: {{.Values.app.namespace}}
  labels:
    {{- include "web08.labels" . | nindent 4}}
    app.kubernetes.io/component: config
  annotations:
    {{- include "web08.annotations" . | nindent 4}}
data:
  {{- toYaml .Values.configMap.data | nindent 2}}

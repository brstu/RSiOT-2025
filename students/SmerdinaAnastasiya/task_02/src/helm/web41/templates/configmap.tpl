---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{include "web41.fullname" .}}-config
  namespace: {{.Values.app.namespace}}
  labels:
    {{- include "web41.labels" . | nindent 4}}
    app.kubernetes.io/component: config
  annotations:
    {{- include "web41.annotations" . | nindent 4}}
data:
  {{- toYaml .Values.configMap.data | nindent 2}}
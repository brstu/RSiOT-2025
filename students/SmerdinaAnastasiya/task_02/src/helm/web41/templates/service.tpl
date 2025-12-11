---
apiVersion: v1
kind: Service
metadata:
  name: net-{{.Values.student.slug}}
  namespace: {{.Values.app.namespace}}
  labels:
    {{- include "web41.labels" . | nindent 4}}
    app.kubernetes.io/component: service
  annotations:
    {{- include "web41.annotations" . | nindent 4}}
spec:
  type: {{.Values.service.type}}
  selector:
    {{- include "web41.selectorLabels" . | nindent 4}}
  ports:
    - name: http
      protocol: TCP
      port: {{.Values.service.port}}
      targetPort: {{.Values.service.targetPort}}
  sessionAffinity: None
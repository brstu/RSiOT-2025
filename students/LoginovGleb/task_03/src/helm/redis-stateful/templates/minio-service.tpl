{{- if .Values.minio.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: minio-service-{{.Values.student.slug}}
  namespace: {{.Values.namespace}}
  labels:
    org.bstu.student.fullname: |
      {{.Values.student.fullname | replace " " "-" | quote}}
    org.bstu.student.id: {{.Values.student.id | quote}}
    org.bstu.group: {{.Values.student.group | quote}}
    org.bstu.variant: {{.Values.student.variant | quote}}
    org.bstu.course: "RSIOT"
    org.bstu.owner: {{.Values.student.github | quote}}
    org.bstu.student.slug: {{.Values.student.slug | quote}}
    app: minio
spec:
  type: ClusterIP
  selector:
    app: minio
    org.bstu.student.slug: {{.Values.student.slug | quote}}
  ports:
    - name: api
      port: 9000
      targetPort: 9000
    - name: console
      port: 9001
      targetPort: 9001
{{- end }}

{{- if .Values.minio.enabled }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minio-{{ .Values.student.slug }}
  namespace: {{ .Values.namespace }}
  labels:
    org.bstu.student.fullname: {{ .Values.student.fullname | replace " " "-" | quote }}
    org.bstu.student.id: {{ .Values.student.id | quote }}
    org.bstu.group: {{ .Values.student.group | quote }}
    org.bstu.variant: {{ .Values.student.variant | quote }}
    org.bstu.course: "RSIOT"
    org.bstu.owner: {{ .Values.student.github | quote }}
    org.bstu.student.slug: {{ .Values.student.slug | quote }}
    app: minio
spec:
  replicas: 1
  selector:
    matchLabels:
      app: minio
      org.bstu.student.slug: {{ .Values.student.slug | quote }}
  template:
    metadata:
      labels:
        app: minio
        org.bstu.student.fullname: {{ .Values.student.fullname | replace " " "-" | quote }}
        org.bstu.student.id: {{ .Values.student.id | quote }}
        org.bstu.group: {{ .Values.student.group | quote }}
        org.bstu.variant: {{ .Values.student.variant | quote }}
        org.bstu.course: "RSIOT"
        org.bstu.owner: {{ .Values.student.github | quote }}
        org.bstu.student.slug: {{ .Values.student.slug | quote }}
    spec:
      containers:
      - name: minio
        image: {{ .Values.minio.image.repository }}:{{ .Values.minio.image.tag }}
        args:
        - server
        - /data
        - --console-address
        - :9001
        env:
        - name: MINIO_ROOT_USER
          valueFrom:
            secretKeyRef:
              name: minio-secret-{{ .Values.student.slug }}
              key: root-user
        - name: MINIO_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: minio-secret-{{ .Values.student.slug }}
              key: root-password
        - name: STU_ID
          value: {{ .Values.student.id | quote }}
        - name: STU_GROUP
          value: {{ .Values.student.group | quote }}
        - name: STU_VARIANT
          value: {{ .Values.student.variant | quote }}
        ports:
        - containerPort: 9000
          name: api
        - containerPort: 9001
          name: console
        volumeMounts:
        - name: storage
          mountPath: /data
        resources:
          {{- toYaml .Values.minio.resources | nindent 10 }}
        livenessProbe:
          httpGet:
            path: /minio/health/live
            port: 9000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /minio/health/ready
            port: 9000
          initialDelaySeconds: 10
          periodSeconds: 5
      volumes:
      - name: storage
        persistentVolumeClaim:
          claimName: minio-storage-{{ .Values.student.slug }}
{{- end }}

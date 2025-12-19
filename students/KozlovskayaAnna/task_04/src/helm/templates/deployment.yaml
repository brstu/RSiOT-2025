apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "monitoring-app.fullname" . }}
  namespace: {{ include "monitoring-app.namespace" . }}
  labels:
    {{ include "monitoring-app.labels" . | nindent 4 }}
  annotations:
    org.bstu.student.fullname: {{ .Values.student.fullname | quote }}
    org.bstu.student.id: {{ .Values.student.id | quote }}
    org.bstu.group: {{ .Values.student.group | quote }}
    org.bstu.variant: {{ .Values.student.variant | quote }}
    org.bstu.course: "RSIOT"
spec:
  {{ if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{ end }}
  selector:
    matchLabels:
      {{- include "monitoring-app.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "monitoring-app.selectorLabels" . | nindent 8 }}
        {{- with .Values.commonLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "monitoring-app.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
      - name: {{ .Chart.Name }}
        securityContext:
          {{- toYaml .Values.securityContext | nindent 12 }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - name: http
          containerPort: {{ .Values.service.targetPort }}
          protocol: TCP
        env:
        {{- range $key, $value := .Values.env }}
        - name: {{ $key }}
          value: {{ $value | quote }}
        {{- end }}
        livenessProbe:
          {{- toYaml .Values.livenessProbe | nindent 12 }}
        readinessProbe:
          {{- toYaml .Values.readinessProbe | nindent 12 }}
        resources:
          {{- toYaml .Values.resources | nindent 12 }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}

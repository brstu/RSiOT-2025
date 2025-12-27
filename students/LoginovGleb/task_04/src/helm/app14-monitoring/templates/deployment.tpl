apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "app14-monitoring.fullname" . }}
  namespace: {{ .Values.namespace }}
  labels:
    {{- include "app14-monitoring.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.app.replicaCount }}
  selector:
    matchLabels:
      {{- include "app14-monitoring.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "app14-monitoring.selectorLabels" . | nindent 8 }}
        {{- range $key, $value := .Values.metadata.labels }}
        {{ $key }}: {{ $value | quote }}
        {{- end }}
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: {{ .Values.app.service.port | quote }}
        prometheus.io/path: {{ .Values.app.metrics.path | quote }}
    spec:
      containers:
      - name: {{ .Values.app.name }}
        image: "{{ .Values.app.image.repository }}:{{ .Values.app.image.tag }}"
        imagePullPolicy: {{ .Values.app.image.pullPolicy }}
        ports:
        - name: {{ .Values.app.service.name }}
          containerPort: {{ .Values.app.service.targetPort }}
          protocol: TCP
        env:
        - name: STU_ID
          value: {{ .Values.app.env.STU_ID | quote }}
        - name: STU_GROUP
          value: {{ .Values.app.env.STU_GROUP | quote }}
        - name: STU_VARIANT
          value: {{ .Values.app.env.STU_VARIANT | quote }}
        livenessProbe:
          httpGet:
            path: {{ .Values.app.livenessProbe.httpGet.path }}
            port: {{ .Values.app.livenessProbe.httpGet.port }}
          initialDelaySeconds: {{ .Values.app.livenessProbe.initialDelaySeconds }}
          periodSeconds: {{ .Values.app.livenessProbe.periodSeconds }}
          timeoutSeconds: {{ .Values.app.livenessProbe.timeoutSeconds }}
          failureThreshold: {{ .Values.app.livenessProbe.failureThreshold }}
        readinessProbe:
          httpGet:
            path: {{ .Values.app.readinessProbe.httpGet.path }}
            port: {{ .Values.app.readinessProbe.httpGet.port }}
          initialDelaySeconds: {{ .Values.app.readinessProbe.initialDelaySeconds }}
          periodSeconds: {{ .Values.app.readinessProbe.periodSeconds }}
          timeoutSeconds: {{ .Values.app.readinessProbe.timeoutSeconds }}
          failureThreshold: {{ .Values.app.readinessProbe.failureThreshold }}
        resources:
          {{- toYaml .Values.app.resources | nindent 10 }}

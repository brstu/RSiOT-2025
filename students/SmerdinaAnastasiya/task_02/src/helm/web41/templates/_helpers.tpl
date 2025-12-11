{{- define "web41.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 64 | trimSuffix "-" }}
{{- end }}

{{- define "web41.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 64 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "app-%s" .Values.student.slug | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "web41.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 64 | trimSuffix "-" }}
{{- end }}

{{- define "web41.labels" -}}
helm.sh/chart: {{ include "web41.chart" . }}
{{ include "web41.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
org.bstu.student.fullname: "SmerdinaAnastasiyaValentynovna"
org.bstu.student.id: {{ .Values.student.id | quote }}
org.bstu.group: {{ .Values.student.group | quote }}
org.bstu.variant: {{ .Values.student.variant | quote }}
org.bstu.course: {{ .Values.student.course | quote }}
org.bstu.owner: {{ .Values.student.owner | quote }}
org.bstu.student.slug: {{ .Values.student.slug | quote }}
{{- end }}

{{- define "web41.selectorLabels" -}}
app.kubernetes.io/name: {{ include "web41.name" . }}
app.kubernetes.io/instance: {{ .Values.student.slug }}
{{- end }}

{{- define "web41.annotations" -}}
org.bstu.student.fullname: {{ .Values.student.fullname | quote }}
org.bstu.student.email: {{ .Values.student.email | quote }}
org.bstu.lab: "task_02"
{{- end }}
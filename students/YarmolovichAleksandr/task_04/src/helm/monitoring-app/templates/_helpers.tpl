{{/*
Expand the name of the chart.
*/}}
{{- define "app24.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "app24.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "app24.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "app24.labels" -}}
helm.sh/chart: {{ include "app24.chart" . }}
{{ include "app24.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
org.bstu.student.id: {{ .Values.student.id | quote }}
org.bstu.student.fullname: {{ .Values.student.fullname | quote }}
org.bstu.group: {{ .Values.student.group | quote }}
org.bstu.variant: {{ .Values.student.variant | quote }}
org.bstu.course: {{ .Values.student.course | quote }}
org.bstu.owner: {{ .Values.student.owner | quote }}
org.bstu.student.slug: {{ .Values.student.slug | quote }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "app24.selectorLabels" -}}
app.kubernetes.io/name: {{ include "app24.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: app24
{{- end }}

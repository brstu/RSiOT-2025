{{- define "web08.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "web08.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "app-%s" .Values.student.slug | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "web08.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "web08.labels" -}}
helm.sh/chart: {{ include "web08.chart" . }}
{{ include "web08.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
org.bstu.student.fullname: "KozlovskayaAnnaGennadyevna"
org.bstu.student.id: {{ .Values.student.id | quote }}
org.bstu.group: {{ .Values.student.group | quote }}
org.bstu.variant: {{ .Values.student.variant | quote }}
org.bstu.course: {{ .Values.student.course | quote }}
org.bstu.owner: {{ .Values.student.owner | quote }}
org.bstu.student.slug: {{ .Values.student.slug | quote }}
{{- end }}

{{- define "web08.selectorLabels" -}}
app.kubernetes.io/name: {{ include "web08.name" . }}
app.kubernetes.io/instance: {{ .Values.student.slug }}
{{- end }}

{{- define "web08.annotations" -}}
org.bstu.student.fullname: {{ .Values.student.fullname | quote }}
org.bstu.student.email: {{ .Values.student.email | quote }}
org.bstu.lab: "task_02"
{{- end }}

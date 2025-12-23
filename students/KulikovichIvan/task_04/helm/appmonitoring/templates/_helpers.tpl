{{/*
Expand the name of the chart.
*/}}
{{- define "app11-monitoring.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "app11-monitoring.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "app11-monitoring.labels" -}}
helm.sh/chart: {{ include "app11-monitoring.chart" . }}
{{ include "app11-monitoring.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
org.bstu.student.fullname: {{ .Values.metadata.student.fullname | quote }}
org.bstu.student.id: {{ .Values.metadata.student.id | quote }}
org.bstu.group: {{ .Values.metadata.student.group | quote }}
org.bstu.variant: {{ .Values.metadata.student.variant | quote }}
org.bstu.course: RSIOT
org.bstu.owner: {{ .Values.metadata.labels.owner | quote }}
org.bstu.student.slug: {{ .Values.metadata.labels.slug | quote }}
slug: {{ .Values.metadata.labels.slug | quote }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "app11-monitoring.selectorLabels" -}}
app.kubernetes.io/name: {{ include "app11-monitoring.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "app11-monitoring.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "app11-monitoring.name" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
{{- define "web03.name" -}}
web03
{{- end -}}

{{- define "web03.labels" -}}
app.kubernetes.io/name: {{ include "web03.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: Helm
org.bstu.student.fullname: {{ .Values.studentMeta.fullname | quote }}
org.bstu.student.id: {{ .Values.studentMeta.studentId | quote }}
org.bstu.group: {{ .Values.studentMeta.group | quote }}
org.bstu.variant: {{ .Values.studentMeta.variant | quote }}
org.bstu.course: {{ .Values.studentMeta.course | quote }}
org.bstu.owner: {{ .Values.studentMeta.owner | quote }}
org.bstu.student.slug: {{ .Values.studentMeta.slug | quote }}
slug: {{ .Values.studentMeta.slug | quote }}
{{- end -}}

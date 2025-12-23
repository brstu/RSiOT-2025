{{- define "app39.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "app39.fullname" -}}
{{- printf "%s" (include "app39.name" .) -}}
{{- end -}}

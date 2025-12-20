{{- define "app34.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "app34.fullname" -}}
{{- printf "%s" (include "app34.name" .) -}}
{{- end -}}

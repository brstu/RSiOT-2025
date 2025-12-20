{{- define "redis-stateful.labels" -}}
org.bstu.student.fullname: "Loginov-Gleb-Olegovich"
org.bstu.student.id: "{{ .Values.student.id }}"
org.bstu.group: "{{ .Values.student.group }}"
org.bstu.variant: "{{ .Values.student.variant }}"
org.bstu.course: "RSIOT"
org.bstu.owner: "{{ .Values.student.github }}"
org.bstu.student.slug: "{{ .Values.student.slug }}"
{{- end -}}

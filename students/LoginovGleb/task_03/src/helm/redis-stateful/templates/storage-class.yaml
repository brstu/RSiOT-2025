apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: {{ .Values.storage.className }}
  labels:
{{ include "redis-stateful.labels" . | indent 4 }}
provisioner: {{ .Values.storage.provisioner }}
parameters:
  type: standard
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Retain
allowVolumeExpansion: true

{{- define "common.status-monitor.labels" -}}
organization/cluster: {{ .Values.global.cluster | default "Default" | quote }}
organization/namespace: {{ .Release.Namespace | default "Undefined" | quote }}
organization/team: {{ .Values.global.team | default "my_team" | quote }}
organization/product: {{ .Values.global.product | default .Chart.Name | quote }}
{{- end -}}

{{- define "status-monitor.labels" -}}
organization/subproduct: {{ .Release.Name | quote }}
{{- end -}}

{{- define "database.status-monitor.labels" -}}
organization/product: {{ .Values.global.product | default .Chart.Name | quote }}
{{- end -}}

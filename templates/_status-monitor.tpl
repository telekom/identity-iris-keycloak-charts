{{- define "common.status-monitor.labels" -}}
cluster: {{ .Values.global.cluster | default "Default" | quote }}
namespace: {{ .Release.Namespace | default "Undefined" | quote }}
product: {{ .Values.global.product | default .Chart.Name | quote }}
team: {{ .Values.global.team | default "my_team" | quote }}
product: {{ .Values.global.product | default .Chart.Name | quote }}
{{- end -}}

{{- define "status-monitor.labels" -}}
subproduct: {{ .Release.Name | quote }}
{{- end -}}

{{- define "database.status-monitor.labels" -}}
subproduct: {{ printf "%s-%s" .Release.Name "database" | quote }}
{{- end -}}

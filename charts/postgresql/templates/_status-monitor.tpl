{{- define "common.status-monitor.labels" -}}
{{- with .Values.global.labels.monitoring.general | default dict }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{- define "keycloak.status-monitor.labels" -}}
{{- with .Values.global.labels.monitoring.keycloak | default dict }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{- define "database.status-monitor.labels" -}}
{{- with .Values.global.labels.monitoring.database | default dict }}
{{- toYaml . }}
{{- end }}
{{- end }}

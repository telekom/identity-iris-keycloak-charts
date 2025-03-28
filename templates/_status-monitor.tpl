{{- define "common.status-monitor.labels" -}}
{{- with .Values.global.labels.monitoring.general | default list }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{- define "keycloak.status-monitor.labels" -}}
{{- with .Values.global.labels.monitoring.keycloak | default list }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{- define "database.status-monitor.labels" -}}
{{- with .Values.global.labels.monitoring.database | default list }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{- define "service-monitor.targetLabels" -}}
{{- with .Values.prometheus.serviceMonitor.targetLabels | default list }}
{{- toYaml . }}
{{- end }}
{{- end }}

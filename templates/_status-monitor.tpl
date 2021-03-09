{{- define "status-monitor.labels" -}}
tardis.telekom.de/cluster: {{ .Values.global.cluster | default "Default" | quote }}
tardis.telekom.de/namespace: {{ .Values.global.namespace | default "Undefined" | quote }}
tardis.telekom.de/product: {{ .Values.global.product | default .Chart.Name | quote }}
tardis.telekom.de/subproduct: {{ .Release.Name | quote }}
tardis.telekom.de/team: {{ .Values.global.team | default "io" | quote }}
{{- end -}}

{{- define "database.status-monitor.labels" -}}
tardis.telekom.de/cluster: {{ .Values.global.cluster | default "Default" | quote }}
tardis.telekom.de/namespace: {{ .Values.global.namespace | default "Undefined" | quote }}
tardis.telekom.de/product: "iris" {{- /* <== this is a fake, because we have postgresql subchart here */}}
tardis.telekom.de/subproduct: {{ printf "%s-%s" .Release.Name "database" | quote }}
tardis.telekom.de/team: {{ .Values.global.team | default "io" | quote }}
{{- end -}}

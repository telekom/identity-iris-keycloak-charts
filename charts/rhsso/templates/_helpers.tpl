{{- define "rhsso.labels" -}}
app: {{ include "prefixed_release_name" $ }}
component: {{ .Chart.Name }}
chart: {{ .Chart.Name }}-{{ .Chart.Version }}
release: {{ include "prefixed_release_name" $ }}
installed_by: {{ .Values.global.installed_by | default "tif" }}
{{- end -}}

{{- define "image.location" -}}
{{- if eq .Values.image.registry "" -}}
{{ .Values.image.repository }}:{{ .Values.image.tag }}
{{- else -}}
{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}
{{- end -}}
{{- end -}}

{{- define "image.init.location" -}}
{{- if eq .Values.image.registry "" -}}
{{ .Values.image.db_client_repository }}:{{ .Values.image.tag }}
{{- else -}}
{{ .Values.image.registry }}/{{ .Values.image.db_client_repository }}:{{ .Values.image.db_client_tag }}
{{- end -}}
{{- end -}}

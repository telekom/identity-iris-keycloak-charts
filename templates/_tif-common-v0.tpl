{{- define "env_short_name" -}}
  {{- .Release.Namespace | replace .Values.global.project_prefix "" -}}
{{- end -}}

{{- define "prefixed_release_name" -}}
  {{- .Values.global.project_prefix | default "tif-" }}{{ .Release.Name -}}
{{- end -}}

{{- define "db.database" -}}
  {{- if eq .Values.global.externalDatabase.enabled true -}}
    {{- include "env_short_name" $ | replace "-" "_" -}}_{{ .Release.Name | replace "-" "_" -}}
  {{- else -}}
    {{- .Values.global.db.database -}}
  {{- end -}}
{{- end -}}

{{- define "db.username" -}}
  {{- if eq .Values.global.externalDatabase.enabled true -}}
    {{- include "env_short_name" $ | replace "-" "_" -}}_{{ .Release.Name | replace "-" "_" -}}
  {{- else -}}
    {{- .Values.global.db.username -}}
  {{- end -}}
{{- end -}}

{{- define "db.password" -}}
  {{- if eq .Values.global.externalDatabase.enabled true -}}
    {{- .Values.global.db.external_password -}}
  {{- else -}}
    {{- .Values.global.db.password  }}
  {{- end -}}
{{- end -}}

{{- define "db.host" -}}
  {{- if eq .Values.global.externalDatabase.enabled true -}}
    {{- .Values.global.externalDatabase.host -}}
  {{- else -}}
    {{ .Release.Name -}}-postgresql
  {{- end -}}
{{- end -}}

{{- define "image_pull_secrets" -}}
{{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ $.Release.Name -}}-pullsecret-{{ .name }}
{{- end -}}
{{- end -}}
{{- end -}}
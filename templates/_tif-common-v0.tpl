{{- define "prefixed_release_name" -}}
  {{- .Values.global.project_prefix | default "tif-" }}{{ .Release.Name -}}
{{- end -}}

{{- define "db.database" -}}
{{- .Values.global.db.database -}}
{{- end -}}

{{- define "db.username" -}}
{{- .Values.global.db.username -}}
{{- end -}}

{{- define "db.password" -}}
{{- .Values.global.db.password  }}
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
{{- define "image_pull_secrets" -}}
{{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "database.host" -}}
  {{- if and (eq .Values.global.database.location "external") .Values.externalDatabase.host  -}}
    {{- .Values.externalDatabase.host -}}
  {{- else -}}
    {{ .Release.Name }}-postgresql
  {{- end -}}
{{- end -}}

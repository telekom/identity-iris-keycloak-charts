{{- define "image_pull_secrets" -}}
{{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
{{- if not (kindIs "string" .) }}
  - name: {{ $.Release.Name }}-{{ .name }}
{{- else }}
  - name: {{ . }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "db.host" -}}
  {{- if eq .Values.global.externalDatabase.enabled true -}}
    {{- .Values.global.externalDatabase.host -}}
  {{- else -}}
    {{ .Release.Name -}}-postgresql
  {{- end -}}
{{- end -}}
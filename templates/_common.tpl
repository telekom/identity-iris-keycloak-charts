{{- define "image_pull_secrets" -}}
{{- if gt (len .Values.global.imagePullSecrets) 0 }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ required "name key is required for imagePullSecrets" .name }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "database.host" -}}
  {{- if .Values.postgresql.enabled -}}
    {{ .Release.Name }}-postgresql
  {{- else -}}
    {{- if .Values.externalDatabase.host -}}
      {{- .Values.externalDatabase.host -}}
    {{- else -}}
      {{ fail "if postgresql isn't enabled, externalDatabase.host has to be defined." }}
    {{- end -}}
  {{- end -}}
{{- end -}}

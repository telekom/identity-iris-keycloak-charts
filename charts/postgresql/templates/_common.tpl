{{- define "image_pull_secrets" -}}
{{- if gt (len .Values.global.imagePullSecrets) 0 }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ required "name key is required for imagePullSecrets" .name }}
{{- end -}}
{{- end -}}
{{- end -}}

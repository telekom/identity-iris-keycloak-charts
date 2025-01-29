{{- define "image_pull_secrets" -}}
{{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
{{- if not (kindIs "string" .) }}
  - name: {{ .name }}
{{- else }}
  - name: {{ . }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "platformSpecificValue" -}}
{{- $ := index . 0 -}}
{{- $template := printf "{{ %s | toYaml }}" (index . 2) -}}
{{- with index . 1 -}}
{{- $value := tpl $template $ -}}

{{- if and (eq $value "null") -}}
{{- $selectedPlatformFile := printf "platforms/%s.yaml" .Values.global.platform -}}
{{- $platformValues := $.Files.Get $selectedPlatformFile | fromYaml -}}
{{ $value = tpl $template (mergeOverwrite (dict "Values" $platformValues) $) }}
{{- end -}}

{{- if not (eq $value "null") -}}
{{ $value }}
{{- end -}}

{{- end -}}
{{- end -}}
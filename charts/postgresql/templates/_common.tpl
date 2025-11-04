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

{{/*
Construct the full image name following the Bitnami pattern.
Usage: {{ include "common.image" (dict "imageRoot" .Values.path.to.image "global" .Values.global) }}
Parameters:
  - imageRoot: The image configuration object (must contain: registry, repository, tag, digest)
  - global: The global values object (must contain: imageRegistry)
Returns: registry/repository:tag or registry/repository@digest
*/}}
{{- define "common.image" -}}
  {{- $registryName := .imageRoot.registry -}}
  {{- if not $registryName -}}
    {{- $registryName = .global.imageRegistry -}}
  {{- end -}}
  {{- $repositoryName := .imageRoot.repository -}}
  {{- $separator := ":" -}}
  {{- $termination := .imageRoot.tag | toString -}}
  {{- if .imageRoot.digest -}}
    {{- $separator = "@" -}}
    {{- $termination = .imageRoot.digest | toString -}}
  {{- end -}}
  {{- if $registryName -}}
    {{- printf "%s/%s%s%s" $registryName $repositoryName $separator $termination -}}
  {{- else -}}
    {{- printf "%s%s%s" $repositoryName $separator $termination -}}
  {{- end -}}
{{- end -}}

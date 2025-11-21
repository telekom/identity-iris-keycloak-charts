{{/*
SPDX-FileCopyrightText: 2025 Deutsche Telekom AG

SPDX-License-Identifier: Apache-2.0
*/}}

{{/*
Image helpers for PostgreSQL chart.
*/}}

{{/*
Generic image builder helper that constructs image reference with cascading global/override pattern.
Supports flexible image paths:
- With registry and namespace: {registry}/{namespace}/{repository}:{tag}
- With registry only: {registry}/{repository}:{tag}
- Without registry/namespace: {repository}:{tag}
Usage: include "images.build" (dict "root" $ "imageConfig" .Values.image)
Note: Explicitly setting registry or namespace to empty string ("") will override global defaults
*/}}
{{- define "postgresql.images.build" -}}
{{- $registry := "" -}}
{{- $namespace := "" -}}
{{- if hasKey .imageConfig "registry" -}}
  {{- $registry = .imageConfig.registry -}}
{{- else -}}
  {{- $registry = .root.Values.global.image.registry -}}
{{- end -}}
{{- if hasKey .imageConfig "namespace" -}}
  {{- $namespace = .imageConfig.namespace -}}
{{- else -}}
  {{- $namespace = .root.Values.global.image.namespace -}}
{{- end -}}
{{- $repository := .imageConfig.repository -}}
{{- $tag := .imageConfig.tag -}}
{{- if and $registry $namespace -}}
{{- printf "%s/%s/%s:%s" $registry $namespace $repository $tag -}}
{{- else if $registry -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- else -}}
{{- printf "%s:%s" $repository $tag -}}
{{- end -}}
{{- end -}}

{{- define "postgresql.images.postgresql" -}}
{{- include "postgresql.images.build" (dict "root" . "imageConfig" .Values.image) -}}
{{- end -}}

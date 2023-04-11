{{/*
Expand the name of the chart.
*/}}
{{- define "postgres.name" -}}
{{- default .Chart.Name .Values.global.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "postgres.fullname" -}}
{{- if .Values.global.fullnameOverride }}
  {{- .Values.global.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
  {{- $name := default .Chart.Name .Values.global.nameOverride }}
  {{- if contains $name .Release.Name }}
    {{- .Release.Name | trunc 63 | trimSuffix "-" }}
  {{- else }}
    {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "postgresql.labels" -}}
app: {{ .Release.Name }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: postgresql
app.kubernetes.io/instance: {{ .Release.Name }}-postgresql
app.kubernetes.io/component: database
app.kubernetes.io/part-of: tif-runtime
{{ .Values.global.labels | toYaml }}
{{- end -}}

{{- define "postgresql.selector" -}}
app.kubernetes.io/instance: {{ .Release.Name }}-postgresql
{{- end -}}

{{- define "postgresql.image" -}}
{{- $imageName := "postgres" -}}
{{- $imageTag := "12.3-debian" -}}
{{- $imageRepository := "mtr.devops.telekom.de" -}}
{{- $imageOrganization := "tardis-common" -}}
{{- if .Values.image -}}
  {{- if not (kindIs "string" .Values.image) -}}
    {{ $imageRepository = .Values.image.repository | default $imageRepository -}}
    {{ $imageOrganization = .Values.image.organization | default $imageOrganization -}}
    {{ $imageName = .Values.image.name | default $imageName -}}
    {{ $imageTag = .Values.image.tag | default $imageTag -}}
    {{- printf "%s/%s/%s:%s" $imageRepository $imageOrganization $imageName $imageTag -}}
  {{- else -}}
    {{- if .Values.global.image.force -}}
      {{- .Values.image | replace "mtr.devops.telekom.de" .Values.global.image.repository | replace "tardis-common" .Values.global.image.organization -}}
    {{- else -}}
      {{- .Values.database.postgres.image -}}
    {{- end -}}
  {{- end -}}
{{- else -}}
 {{- printf "%s/%s/%s:%s" $imageRepository $imageOrganization $imageName $imageTag -}}
{{- end -}}
{{- end -}}

{{- define "postgresql.env" }}
- name: PGDATA
  value: {{ .Values.persistence.mountDir | default "/var/lib/postgresql/data" }}/pgdata
- name: POSTGRES_USER
  value: {{ .Values.global.database.username | default .Values.username }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "postgresql.secretName" . }}
      key: databasePassword
- name: POSTGRES_DB
  value: {{ .Values.global.database.database }}
{{- if .Values.adminPassword }}
- name: POSTGRES_ADMIN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "postgresql.secretName" . }}
      key: adminPassword
{{- end }}
- name: POSTGRES_MAX_CONNECTIONS
  value: "{{ .Values.maxConnections }}"
- name: POSTGRES_SHARED_BUFFERS
  value: {{ .Values.sharedBuffers }}
- name: POSTGRES_MAX_PREPARED_TRANSACTIONS
  value: "{{ .Values.maxPreparedTransactions }}"
{{- end -}}

{{- define "postgresql.deploymentName" -}}
{{- printf "%s-%s" (include "postgres.fullname" .) .Chart.Name -}}
{{- end -}}

{{- define "postgresql.pvcName" -}}
{{- printf "%s-%s-data" (include "postgres.fullname" .) .Chart.Name -}}
{{- end -}}

{{- define "postgresql.secretName" -}}
{{- printf "%s-%s" (include "postgres.fullname" .) .Chart.Name -}}
{{- end -}}

{{- define "postgresql.serviceName" -}}
{{- printf "%s-%s" (include "postgres.fullname" .) .Chart.Name -}}
{{- end -}}

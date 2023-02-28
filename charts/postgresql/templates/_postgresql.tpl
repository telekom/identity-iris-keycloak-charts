{{- define "postgresql.labels" -}}
app: {{ .Release.Name }}
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
      name: {{ .Release.Name }}-{{ .Chart.Name }}
      key: databasePassword
- name: POSTGRES_DB
  value: {{ .Values.global.database.database }}
- name: POSTGRES_ADMIN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-{{ .Chart.Name }}
      key: adminPassword
- name: POSTGRES_MAX_CONNECTIONS
  value: "{{ .Values.max_connections }}"
- name: POSTGRES_SHARED_BUFFERS
  value: {{ .Values.shared_buffers }}
- name: POSTGRES_MAX_PREPARED_TRANSACTIONS
  value: "{{ .Values.max_prepared_transactions }}"
{{- end -}}

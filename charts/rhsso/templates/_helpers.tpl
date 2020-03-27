{{- define "rhsso.labels" -}}
app: {{ include "prefixed_release_name" $ }}
component: {{ .Chart.Name }}
chart: {{ .Chart.Name }}-{{ .Chart.Version }}
release: {{ include "prefixed_release_name" $ }}
installed_by: {{ .Values.global.installed_by | default "tif" }}
{{- end -}}

{{- define "keycloak.admin.env" -}}
- name: KEYCLOAK_USER
  value: {{ .Values.admin_username }}
- name: KEYCLOAK_PASSWORD
  value: {{ .Values.admin_password }}
- name: KEYCLOAK_IMPORT
  value: "/tmp/keycloak/realms/tif-realm.json"
- name: PROXY_ADDRESS_FORWARDING
  value: "true"
{{- end -}}

{{- define "keycloak.db.env" -}}
- name: DB_VENDOR
  value: "postgres"
- name: DB_PORT
  value: "5432"
- name: DB_ADDR
  value: {{ include "db.host" $ | default .Values.db.host }}
- name: DB_DATABASE
  value: {{ include "db.database" $ | default .Values.db.database }} 
- name: DB_USER
  value: {{ include "db.username" $ | default .Values.db.username }}
- name: DB_PASSWORD
  value: {{ include "db.password" $ | default .Values.db.password }}
{{- end -}}

{{- define "postgres.checkdb.env" -}}
- name: PGHOST
  value: {{ include "db.host" $ | default .Values.db.host }}
- name: PGDATABASE
  value: {{ include "db.database" $ | default .Values.db.database }}
- name: PGUSER
  value: {{ include "db.username" $ | default .Values.db.username }}
- name: PGPASSWORD
  value: {{ include "db.password" $ | default .Values.db.password }}
{{- end -}}

{{- define "image.location" -}}
{{- if eq .Values.image.registry "" -}}
{{ .Values.image.repository }}:{{ .Values.image.tag }}
{{- else -}}
{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}
{{- end -}}
{{- end -}}

{{- define "image.init.location" -}}
{{- if eq .Values.image.registry "" -}}
{{ .Values.image.db_client_repository }}:{{ .Values.image.db_client_tag }}
{{- else -}}
{{ .Values.image.registry }}/{{ .Values.image.db_client_repository }}:{{ .Values.image.db_client_tag }}
{{- end -}}
{{- end -}}

{{- define "env_short_name" -}}
  {{- .Release.Namespace | replace .Values.global.project_prefix "" -}}
{{- end -}}

{{- define "prefixed_release_name" -}}
  {{- .Values.global.project_prefix | default "tif-" }}{{ .Release.Name -}}
{{- end -}}

{{- define "db.database" -}}
  {{- if eq .Values.global.use_external_database true -}}
    {{- include "env_short_name" $ | replace "-" "_" -}}_{{ .Release.Name | replace "-" "_" -}}
  {{- else -}}
    {{- .Values.global.db.database -}}
  {{- end -}}
{{- end -}}

{{- define "db.username" -}}
  {{- if eq .Values.global.use_external_database true -}}
    {{- include "env_short_name" $ | replace "-" "_" -}}_{{ .Release.Name | replace "-" "_" -}}
  {{- else -}}
    {{- .Values.global.db.username -}}
  {{- end -}}
{{- end -}}

{{- define "db.password" -}}
  {{- if eq .Values.global.use_external_database true -}}
    {{- .Values.global.db.external_password -}}
  {{- else -}}
    {{- .Values.global.db.password  }}
  {{- end -}}
{{- end -}}

{{- define "db.host" -}}
  {{- if eq .Values.global.use_external_database true -}}
    {{- .Values.global.db.external_svc_name -}}
  {{- else -}}
    {{ .Release.Name -}}-postgresql
  {{- end -}}
{{- end -}}

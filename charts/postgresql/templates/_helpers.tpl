{{- define "postgresql.labels" -}}
app: {{ include "prefixed_release_name" $ }}
component: {{ .Chart.Name }}
chart: {{ .Chart.Name }}-{{ .Chart.Version }}
release: {{ include "prefixed_release_name" $ }}
installed_by: {{ .Values.global.installed_by | default "tif" }}
{{ .Values.global.labels | toYaml }}
{{- end -}}

{{- define "postgresql.env" -}}
{{- if .Values.mount_dir }}
- name: PGDATA
  value: {{ .Values.data_dir }}
{{- end }}
- name: POSTGRES_USER
  value: {{ .Values.global.db.username | default .Values.username }}
- name: POSTGRES_PASSWORD
  value: {{ .Values.global.db.password | default .Values.password }}
- name: POSTGRES_DATABASE
  value: {{ .Values.global.db.database | default .Values.database }}
- name: POSTGRES_ADMIN_PASSWORD
  value: {{ .Values.global.db.admin_password | default .Values.admin_password }}
- name: POSTGRES_MAX_CONNECTIONS
  value: "{{ .Values.max_connections }}"
- name: POSTGRES_SHARED_BUFFERS
  value: {{ .Values.shared_buffers }}
- name: POSTGRES_MAX_PREPARED_TRANSACTIONS
  value: "{{ .Values.max_prepared_transactions }}"
{{- end -}}

{{- define "postgresql.mount.dir" -}}
{{ .Values.mount_dir | default .Values.data_dir }}
{{- end -}}

{{- define "postgresql.image.location" -}}
{{- if eq .Values.image.registry "" -}}
{{ .Values.image.repository }}:{{ .Values.image.tag }}
{{- else -}}
{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}
{{- end -}}
{{- end -}}

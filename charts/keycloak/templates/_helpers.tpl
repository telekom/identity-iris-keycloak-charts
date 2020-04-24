{{- define "keycloak.labels" -}}
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

{{- define "keycloak.image.tag" -}}
{{- if and (eq .Values.global.platform "openshift") (.Values.image.tag_openshift) -}}
{{ .Values.image.tag_openshift }}
{{- else -}}
{{ .Values.image.tag }}
{{- end -}}
{{- end -}}

{{- define "keycloak.image.location" -}}
{{- if eq .Values.image.registry "" -}}
{{ .Values.image.repository }}:{{ tpl "keycloak.image.tag" $ }}
{{- else -}}
{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ include "keycloak.image.tag" $ }}
{{- end -}}
{{- end -}}

{{- define "keycloak.image.init.location" -}}
{{- if eq .Values.image.registry "" -}}
{{ .Values.image.db_client_repository }}:{{ .Values.image.db_client_tag }}
{{- else -}}
{{ .Values.image.registry }}/{{ .Values.image.db_client_repository }}:{{ .Values.image.db_client_tag }}
{{- end -}}
{{- end -}}

{{- define "keycloak.host" -}}
{{- if not (empty .Values.ingress.hostname) }}
{{- .Values.ingress.hostname -}}
{{- else }}
{{- printf "%s-%s.%s" .Release.Name .Release.Namespace .Values.global.domain }}
{{- end -}}
{{- end -}}
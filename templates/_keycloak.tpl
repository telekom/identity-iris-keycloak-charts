{{- define "keycloak.labels" -}}
app: {{ .Release.Name }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: keycloak
{{ include "keycloak.selector" . }}
app.kubernetes.io/component: idp
{{- if .Values.global.labels.common }}
{{ .Values.global.labels.common | toYaml }}
{{- end }}
{{- end -}}

{{- define "keycloak.selector" -}}
app.kubernetes.io/instance: {{ .Release.Name }}-keycloak
{{- end -}}

{{- define "keycloak.checksums" -}}
checksum/config: {{ include (print $.Template.BasePath "/configmap-cache.yml") . | sha256sum }}
{{- range .Values.templateChangeTriggers }}
checksum/{{ . }}: {{ include (print $.Template.BasePath "/" . ) $ | sha256sum }}
{{- end -}}
{{- end -}}

{{- define "keycloak.dbUrlProperties" -}}
{{- $ssl := .Values.externalDatabase.ssl | default "true" | toString }}
{{- $sslMode := .Values.externalDatabase.sslMode | default "verify-full" }}
{{- $sslCert := "" }}
{{- $sslKey := "" }}
{{- $sslRootCert := "" }}

{{- if .Values.externalDatabase.sslCert }}
{{- $sslCert = "&sslcert=/certificates/sslcert.crt" }}
{{- end -}}
{{- if .Values.externalDatabase.sslKey }}
{{- $sslKey = "&sslkey=/certificates/sslkey.pk8" }}
{{- end -}}
{{- if .Values.externalDatabase.sslRootCert }}
{{- $sslRootCert = "&sslrootcert=/certificates/sslrootcert.crt" }}
{{- end -}}

{{- printf "?ssl=%s&sslmode=%s%s%s%s" $ssl $sslMode $sslCert $sslKey $sslRootCert -}}
{{ end -}}

{{- define "keycloak.url" }}
{{- printf "https://%s:%s" (include "keycloak.host" $) "80" }}
{{- end }}

{{- define "keycloak.env" }}
- name: KC_HOSTNAME
  value: {{ include "keycloak.adminHost" $ }}
- name: KC_PROXY_HEADERS
  value: "xforwarded"
- name: KC_HTTP_ENABLED
  value: "true"
- name: QUARKUS_TRANSACTION_MANAGER_ENABLE_RECOVERY
  value: "false"
- name: JAVA_OPTS_APPEND
  value: -Djgroups.dns.query={{ .Release.Name }}-jgroups.{{ .Release.Namespace }}
- name: KC_METRICS_ENABLED
  value: "true"
- name: KC_HTTP_METRICS_HISTOGRAMS_ENABLED
  value: "true"
- name: URI_METRICS_ENABLED
  value: "true"
- name: CLIENT_AUTH_METHOD_METRICS_ENABLED
  value: {{ .Values.clientAuthMethodMetricsEnabled | quote }}
- name: KC_BOOTSTRAP_ADMIN_USERNAME
  value: {{ .Values.adminUsername }}
- name: KC_BOOTSTRAP_ADMIN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}
      key: adminPassword
- name: KEYCLOAK_LOGLEVEL
  value: {{ .Values.logLevel | default "INFO" }}
- name: PROXY_ADDRESS_FORWARDING
  value: "true"
- name: KC_DB_URL_PORT
  value: {{ .Values.global.database.port | default "5432" | quote }}
- name: KC_DB_URL_HOST
  value: {{ include "database.host" $ }}
- name: KC_DB_URL_DATABASE
  value: {{ .Values.global.database.database }}
{{- if .Values.global.database.schema }}
- name: KC_DB_SCHEMA
  value: {{ .Values.global.database.schema }}
{{- end }}
- name: KC_DB_USERNAME
  value: {{ .Values.global.database.username }}
- name: KC_DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}
      key: databasePassword
{{- if .Values.externalDatabase.ssl }}
- name: KC_DB_URL_PROPERTIES
  value: {{ include "keycloak.dbUrlProperties" $ | quote }}
{{- end -}}
{{- end -}}

{{- define "keycloak.checkdatabase.env" }}
- name: PGHOST
  value: {{ include "database.host" $ }}
- name: PGPORT
  value: {{ .Values.global.database.port | default "5432" | quote }}
- name: PGDATABASE
  value: {{ .Values.global.database.database }}
- name: PGUSER
  value: {{ .Values.global.database.username }}
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}
      key: databasePassword
{{- end -}}

{{- define "keycloak.adminHost" }}
{{- if not (empty .Values.ingress.adminHostname) -}}
{{- .Values.ingress.adminHostname -}}
{{- else -}}
{{ include "keycloak.host" $ }}
{{- end -}}
{{- end -}}

{{- define "keycloak.host" -}}
{{- if not (empty .Values.ingress.hostname) }}
{{- .Values.ingress.hostname -}}
{{- else }}
{{- printf "%s-%s.%s" .Release.Name .Release.Namespace .Values.global.domain }}
{{- end -}}
{{- end -}}

{{- define "keycloak.db.certificates.volume" }}
{{- if and .Values.externalDatabase.ssl (or .Values.externalDatabase.sslCert .Values.externalDatabase.sslKey .Values.externalDatabase.sslRootCert) }}
- name: certificates
  secret:
    secretName: {{ .Release.Name }}-certificates
{{- end -}}
{{ end -}}

{{- define "keycloak.db.certificates.volumeMount" }}
{{- if and .Values.externalDatabase.ssl (or .Values.externalDatabase.sslCert .Values.externalDatabase.sslKey .Values.externalDatabase.sslRootCert) }}
- name: certificates
  mountPath: /certificates
{{- end -}}
{{ end -}}

{{- define "keycloak.ingress.annotations" }}
{{- $globalAnnotations := dict "annotations" .Values.global.ingress.annotations | deepCopy -}}
{{- $localAnnotations := dict "annotations" .Values.ingress.annotations -}}
{{- $mergedAnnotations := mergeOverwrite $globalAnnotations $localAnnotations }}
{{- $mergedAnnotations | toYaml -}}
{{ end -}}

{{- define "keycloak.tls.secret" -}}
{{- if not (and (empty .Values.ingress.tls.secret) (empty .Values.global.ingress.tlsSecret)) -}}
secretName: {{ .Values.ingress.tls.secret | default .Values.global.ingress.tlsSecret -}}
{{- end -}}
{{- end -}}

{{- define "keycloak.tls.hosts" -}}
{{- if or (not .Values.ingress.tls.hosts) (eq (len .Values.ingress.tls.hosts) 0) -}}
- {{ include "keycloak.host" . }}
{{- else -}}
{{- range .Values.ingress.tls.hosts }}
- {{ . }}
{{- end -}}
{{- end -}}
{{- end -}}

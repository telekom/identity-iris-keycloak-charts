{* SPDX-FileCopyrightText: 2023 Deutsche Telekom AG *}
{* SPDX-License-Identifier: Apache-2.0 *}


{{- define "keycloak.labels" -}}
app: {{ .Release.Name }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: keycloak
{{ include "keycloak.selector" . }}
app.kubernetes.io/component: idp
{{- end -}}

{{- define "keycloak.selector" -}}
app.kubernetes.io/instance: {{ .Release.Name }}-keycloak
{{- end -}}

{{- define "keycloak.checksums" -}}
checksum/config: {{ include (print $.Template.BasePath "/configmap-config.yml") . | sha256sum }}
{{- range .Values.templateChangeTriggers }}
checksum/{{ . }}: {{ include (print $.Template.BasePath "/" . ) $ | sha256sum }}
{{- end -}}
{{- end -}}

{{- define "keycloak.jdbcParams" -}}
{{- $ssl := "true" }}
{{- $sslMode := .Values.externalDatabase.sslMode | default "verify-full" }}
{{- $sslCert := "&sslcert=" }}
{{- $sslKey := "&sslkey=" }}
{{- $sslRootCert := "&sslrootcert=" }}

{{- if .Values.externalDatabase.sslCert }}
{{- $sslCert = "&sslcert=/certificates/sslcert.crt" }}
{{- end -}}
{{- if .Values.externalDatabase.sslKey }}
{{- $sslKey = "&sslkey=/certificates/sslkey.pk8" }}
{{- end -}}
{{- if .Values.externalDatabase.sslRootCert }}
{{- $sslRootCert = "&sslrootcert=/certificates/sslrootcert.crt" }}
{{- end -}}

{{- printf "ssl=%s&sslmode=%s%s%s%s" $ssl $sslMode $sslCert $sslKey $sslRootCert -}}
{{ end -}}

{{- define "keycloak.url" }}
{{- printf "https://%s:%s" (include "keycloak.host" $) "80" }}
{{- end }}

{{- define "keycloak.env" }}
- name: KC_HOSTNAME
  value: {{ include "keycloak.adminHost" $ }}
- name: KC_PROXY
  value: edge
- name: KC_HTTP_ENABLED
  value: "true"
- name: KC_CACHE_CONFIG_FILE  
  value: infinispan.xml
- name: jgroups.dns.query
  value: {{ .Release.Name }}-jgroups.{{ .Release.Namespace }}
- name: KEYCLOAK_ADMIN
  value: {{ .Values.adminUsername }}
- name: KEYCLOAK_ADMIN_PASSWORD
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
- name: JDBC_PARAMS
  value: {{ include "keycloak.jdbcParams" $ | quote }}
{{- end -}}
{{- end -}}

{{- define "keycloak.checkdatabase.env" }}
- name: PGHOST
  value: {{ include "database.host" $ }}
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
{{- if .Values.externalDatabase.ssl }}
- name: certificates
  secret:
    secretName: {{ .Release.Name }}-certificates
{{- end -}}
{{ end -}}

{{- define "keycloak.db.certificates.volumeMount" }}
{{- if .Values.externalDatabase.ssl }}
- name: certificates
  mountPath: /certificates
{{- end -}}
{{ end -}}

{{- define "keycloak.ingress.tlsSecret" -}}
{{- if not (and (empty .Values.ingress.tlsSecret) (empty .Values.global.ingress.tlsSecret)) -}}
secretName: {{ .Values.ingress.tlsSecret | default .Values.global.ingress.tlsSecret -}}
{{- end -}}
{{- end -}}

{{- define "keycloak.ingress.ingressClassName" -}}
{{- if or (include "platformSpecificValue" (list $ . ".Values.ingress.ingressClassName")) (include "platformSpecificValue" (list $ . ".Values.global.ingress.ingressClassName")) -}}
ingressClassName: {{ include "platformSpecificValue" (list $ . ".Values.ingress.ingressClassName") | default (include "platformSpecificValue" (list $ . ".Values.global.ingress.ingressClassName")) }}
{{- end -}}
{{- end -}}

{{- define "haproxy.image" -}}
   {{- printf "mtr.devops.telekom.de/tardis-common/haproxy:2.4.0-alpine" -}}
{{- end -}}

{{- define "keycloak.labels" -}}
app: {{ .Release.Name }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: keycloak
{{ include "keycloak.selector" . }}
app.kubernetes.io/component: idp
app.kubernetes.io/part-of: tif-runtime
{{ .Values.global.labels | toYaml }}
{{- end -}}

{{- define "keycloak.selector" -}}
app.kubernetes.io/instance: {{ .Release.Name }}-keycloak
{{- end -}}

{{- define "keycloak.image" -}}
{{- $imageName := "iris" -}}
{{- $imageTag := "3.1.2" -}}
{{- $imageRepository := "mtr.devops.telekom.de" -}}
{{- $imageOrganization := "tardis-internal/io" -}}
{{- if .Values.image -}}
  {{- if not (kindIs "string" .Values.image) -}}
    {{ $imageRepository = .Values.image.repository | default $imageRepository -}}
    {{ $imageOrganization = .Values.image.organization | default $imageOrganization -}}
    {{ $imageName = .Values.image.name | default $imageName -}}
    {{ $imageTag = .Values.image.tag | default $imageTag -}}
    {{- printf "%s/%s/%s:%s" $imageRepository $imageOrganization $imageName $imageTag -}}
  {{- else -}}
    {{- .Values.image -}}
  {{- end -}}
{{- else -}}
 {{- printf "%s/%s/%s:%s" $imageRepository $imageOrganization $imageName $imageTag -}}
{{- end -}}
{{- end -}}

{{- define "keycloak.init.image" -}}
{{- $imageName := "postgres" -}}
{{- $imageTag := "12.3-debian" -}}
{{- $imageRepository := "mtr.devops.telekom.de" -}}
{{- $imageOrganization := "tardis-common" -}}
{{- if .Values.postgresql.image -}}
  {{- if not (kindIs "string" .Values.postgresql.image) -}}
    {{ $imageRepository = .Values.postgresql.image.repository | default $imageRepository -}}
    {{ $imageOrganization = .Values.postgresql.image.organization | default $imageOrganization -}}
    {{ $imageName = .Values.postgresql.image.name | default $imageName -}}
    {{ $imageTag = .Values.postgresql.image.tag | default $imageTag -}}
    {{- printf "%s/%s/%s:%s" $imageRepository $imageOrganization $imageName $imageTag -}}
  {{- else -}}
    {{- .Values.postgresql.image -}}
  {{- end -}}
{{- else -}}
 {{- printf "%s/%s/%s:%s" $imageRepository $imageOrganization $imageName $imageTag -}}
{{- end -}}
{{- end -}}

{{- define "keycloak.annotations" -}}
ops.eni.telekom.de/pipeline-meta-ref: {{ .Release.Name }}-pipeline-metadata
{{- if eq (toString .Values.global.metadata.pipeline.forceRedeploy) "true" }}
ops.eni.telekom.de/pipeline-force-redeploy: '{{ now | date "2006-01-02T15:04:05Z07:00" }}'
{{- end -}}
{{- end -}}

{{- define "keycloak.checksums" -}}
checksum/config: {{ include (print $.Template.BasePath "/configmap-config.yml") . | sha256sum }}
checksum/realm: {{ include (print $.Template.BasePath "/configmap-realm.yml") . | sha256sum }}
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

{{- define "keycloak.realms" }}
{{- $realmsPath := "/opt/jboss/keycloak/standalone/configuration/realms" -}}
{{- $realms := "" -}}
{{- range $path, $_ := .Files.Glob "realms/*.json" -}}
  {{- $jsonFilename := base $path -}}
  {{- $r := printf "%s/%s" $realmsPath $jsonFilename -}}
  {{- $realms = printf "%s,%s" $realms $r -}}
{{- end }}
{{-  if eq $realms "" -}}
  {{- range .Values.realms -}}
  {{- if or (eq .enabled true) (and (eq .name "rover") (eq $.Values.roverRealmEnabled true)) -}}
  {{- $r := printf "%s/_generated_%s.json" $realmsPath .name -}}
  {{- $realms = printf "%s,%s" $realms $r -}}
  {{- end -}}
  {{- end -}}
{{- end -}}
{{- $realms -}}
{{ end }}

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
  value: eni-infinispan.xml
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
{{- if not (eq (include "keycloak.realms" $) "") }}
- name: KEYCLOAK_IMPORT
  value: {{ trimPrefix "," (include "keycloak.realms" $)  | quote }}
{{- end }}
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

{{- define "keycloak.merged.ingress.annotations" }}
{{- $globalAnnotations := dict "annotations" .Values.global.ingress.annotations | deepCopy -}}
{{- $localAnnotations := dict "annotations" .Values.ingress.annotations -}}
{{- $mergedAnnotations := mergeOverwrite $globalAnnotations $localAnnotations }}
{{- $mergedAnnotations | toYaml -}}
{{ end -}}

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
{{- if eq .Values.global.platform "tdi" -}}
ingressClassName: {{ .Values.ingress.ingressClassName | default "triton-ingress" -}}
{{- end -}}
{{- end -}}

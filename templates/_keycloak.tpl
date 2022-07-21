{{- define "haproxy.image" -}}
   {{- printf "mtr.external.otc.telekomcloud.com/tif-public/haproxy:2.4.0-alpine" -}}
{{- end -}}

{{- define "keycloak.labels" -}}
app: {{ .Release.Name }}
app.kubernetes.io/name: keycloak
app.kubernetes.io/instance: {{ .Release.Name }}-keycloak
app.kubernetes.io/component: idp
app.kubernetes.io/part-of: tif-runtime
app.kubernetes.io/managed-by: {{ .Values.global.installed_by | default "tif" }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{ .Values.global.labels | toYaml }}
{{- end -}}

{{- define "keycloak.selector" -}}
app.kubernetes.io/instance: {{ .Release.Name }}-keycloak
{{- end -}}

{{- define "keycloak.image" -}}
{{- $imageName := "iris" -}}
{{- $imageTag := "2.0.0" -}}
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
{{- $sslMode := .Values.global.externalDatabase.sslMode | default "verify-full" }}
{{- $sslCert := "&sslcert=" }}
{{- $sslKey := "&sslkey=" }}
{{- $sslRootCert := "&sslrootcert=" }}

{{- if .Values.global.externalDatabase.sslCert }}
{{- $sslCert = "&sslcert=/certificates/sslcert.crt" }}
{{- end -}}
{{- if .Values.global.externalDatabase.sslKey }}
{{- $sslKey = "&sslkey=/certificates/sslkey.pk8" }}
{{- end -}}
{{- if .Values.global.externalDatabase.sslRootCert }}
{{- $sslRootCert = "&sslrootcert=/certificates/sslrootcert.crt" }}
{{- end -}}

{{- printf "ssl=%s&sslmode=%s%s%s%s" $ssl $sslMode $sslCert $sslKey $sslRootCert -}}
{{ end -}}

{{- define "keycloak.javaOptions" -}}
{{- if .Values.javaOptions -}}
{{ .Values.javaOptions }}
{{- else -}}
-Xms64m -Xmx512m -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=256m -Djava.net.preferIPv4Stack=true -Djboss.modules.system.pkgs=org.jboss.byteman -Djava.awt.headless=true
{{- end -}}
{{- end -}}

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
  {{- $r := printf "%s/_generated_%s.json" $realmsPath .name -}}
  {{- $realms = printf "%s,%s" $realms $r -}}
  {{- end -}}
{{- end -}}
{{- $realms -}}
{{ end }}

{{- define "keycloak.haCacheEnvParams" -}}
{{- if or (gt (int .Values.replicas) 1) .Values.autoscaling.enabled }}
- name: CACHE_OWNERS_COUNT
  value: "2"
- name: CACHE_OWNERS_AUTH_SESSIONS_COUNT
  value: "2"
{{- else }}
- name: CACHE_OWNERS_COUNT
  value: "1"
- name: CACHE_OWNERS_AUTH_SESSIONS_COUNT
  value: "1"
{{- end }}
{{ end }}

{{- define "keycloak.env" }}
- name: KEYCLOAK_USER
  value: {{ .Values.admin_username }}
- name: KEYCLOAK_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}
      key: keycloakPassword
- name: KEYCLOAK_LOGLEVEL
  value: {{ .Values.logLevel | default "INFO" }}
- name: WILDFLY_LOGLEVEL
  value: {{ .Values.logLevel | default "INFO" }}
{{- if not (eq (include "keycloak.realms" $) "") }}
- name: KEYCLOAK_IMPORT
  value: {{ trimPrefix "," (include "keycloak.realms" $)  | quote }}
{{- end }}
- name: PROXY_ADDRESS_FORWARDING
  value: "true"
{{- include "keycloak.haCacheEnvParams" . -}}
- name: DB_VENDOR
  value: "postgres"
- name: DB_PORT
  value: "5432"
- name: DB_ADDR
  value: {{ include "db.host" $ }}
- name: DB_DATABASE
  value: {{ .Values.global.db.database }} 
- name: DB_USER
  value: {{ .Values.global.db.username }}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}
      key: dbPassword
{{- if .Values.global.externalDatabase.ssl }}
- name: JDBC_PARAMS
  value: {{ include "keycloak.jdbcParams" $ | quote }}
{{- end -}}
{{- if .Values.javaOptions }}
- name: JAVA_OPTS
  value: {{ include "keycloak.javaOptions" $ | quote }}
{{- end -}}
{{- end -}}

{{- define "keycloak.checkdatabase.env" }}
- name: PGHOST
  value: {{ include "db.host" $ }}
- name: PGDATABASE
  value: {{ .Values.global.db.database }}
- name: PGUSER
  value: {{ .Values.global.db.username }}
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}
      key: dbPassword
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
{{- if .Values.global.externalDatabase.ssl }}
- name: certificates
  secret:
    secretName: {{ .Release.Name }}-certificates
{{- end -}}
{{ end -}}

{{- define "keycloak.db.certificates.volumeMount" }}
{{- if .Values.global.externalDatabase.ssl }}
- name: certificates
  mountPath: /certificates
{{- end -}}
{{ end -}}

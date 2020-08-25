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
{{- $imageName := "tif-keycloak" -}}
{{- $imageTag := "1.0.0" -}}
{{- $imageRepository := "mtr.external.otc.telekomcloud.com" -}}
{{- $imageOrganization := "tif-public" -}}
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
{{- $imageRepository := "mtr.external.otc.telekomcloud.com" -}}
{{- $imageOrganization := "tif-public" -}}
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

{{- define "keycloak.env" }}
- name: KEYCLOAK_USER
  value: {{ .Values.admin_username }}
- name: KEYCLOAK_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}
      key: keycloakPassword
- name: KEYCLOAK_IMPORT
  value: "/opt/jboss/keycloak/standalone/configuration/realms/tif-realm.json"
- name: PROXY_ADDRESS_FORWARDING
  value: "true"
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
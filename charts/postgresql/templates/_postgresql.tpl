{{- define "postgresql.labels" -}}
app: {{ .Release.Name }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}-postgresql
app.kubernetes.io/name: postgresql
app.kubernetes.io/component: database
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

{{- define "postgresql.selector" -}}
app.kubernetes.io/instance: {{ .Release.Name }}-postgresql
{{- end -}}

{{- define "postgresql.deploymentName" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name -}}
{{- end -}}

{{- define "postgresql.pvcName" -}}
{{- printf "%s-%s-data" .Release.Name .Chart.Name -}}
{{- end -}}

{{- define "postgresql.secretName" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name -}}
{{- end -}}

{{- define "postgresql.serviceName" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name -}}
{{- end -}}

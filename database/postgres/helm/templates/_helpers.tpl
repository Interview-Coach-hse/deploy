{{- define "interview-coach-postgres.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "interview-coach-postgres.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "interview-coach-postgres.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "interview-coach-postgres.labels" -}}
app.kubernetes.io/name: {{ include "interview-coach-postgres.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: postgres
{{- end -}}

{{- define "interview-coach-postgres.selectorLabels" -}}
app.kubernetes.io/name: {{ include "interview-coach-postgres.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: postgres
{{- end -}}

{{- define "interview-coach-postgres.secretName" -}}
{{ include "interview-coach-postgres.fullname" . }}-secret
{{- end -}}

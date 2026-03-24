{{- define "interview-coach-backend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "interview-coach-backend.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "interview-coach-backend.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "interview-coach-backend.labels" -}}
app.kubernetes.io/name: {{ include "interview-coach-backend.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: backend
{{- end -}}

{{- define "interview-coach-backend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "interview-coach-backend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: backend
{{- end -}}

{{- define "interview-coach-backend.configName" -}}
{{ include "interview-coach-backend.fullname" . }}-config
{{- end -}}

{{- define "interview-coach-backend.secretName" -}}
{{ include "interview-coach-backend.fullname" . }}-secret
{{- end -}}

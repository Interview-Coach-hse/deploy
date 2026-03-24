{{- define "interview-coach-ingress-nginx.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "interview-coach-ingress-nginx.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "interview-coach-ingress-nginx.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "interview-coach-ingress-nginx.labels" -}}
app.kubernetes.io/name: {{ include "interview-coach-ingress-nginx.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: controller
{{- end -}}

{{- define "interview-coach-ingress-nginx.selectorLabels" -}}
app.kubernetes.io/name: {{ include "interview-coach-ingress-nginx.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: controller
{{- end -}}

{{- define "interview-coach-ingress-nginx.serviceAccountName" -}}
{{- if .Values.controller.serviceAccount.create -}}
{{- default (include "interview-coach-ingress-nginx.fullname" .) .Values.controller.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.controller.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "interview-coach-ingress-nginx.configMapName" -}}
{{ include "interview-coach-ingress-nginx.fullname" . }}
{{- end -}}

{{- define "virtual-customer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "virtual-customer.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "virtual-customer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "virtual-customer.labels" -}}
helm.sh/chart: {{ include "virtual-customer.chart" . }}
{{ include "virtual-customer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: store-app
app.kubernetes.io/component: simulator
{{- end }}

{{- define "virtual-customer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "virtual-customer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "virtual-customer.name" . }}
{{- end }}

{{- define "virtual-customer.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "virtual-customer.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "virtual-customer.datadogLabels" -}}
{{- if .Values.datadog.enabled }}
tags.datadoghq.com/env: {{ .Values.datadog.env | quote }}
tags.datadoghq.com/service: {{ .Values.datadog.service | quote }}
tags.datadoghq.com/version: {{ .Values.image.tag | quote }}
{{- end }}
{{- end }}
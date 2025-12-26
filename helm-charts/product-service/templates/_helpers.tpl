{{/*
Expand the name of the chart.
*/}}
{{- define "product-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "product-service.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "product-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "product-service.labels" -}}
helm.sh/chart: {{ include "product-service.chart" . }}
{{ include "product-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: store-app
app.kubernetes.io/component: backend
{{- end }}

{{/*
Selector labels
*/}}
{{- define "product-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "product-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "product-service.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "product-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "product-service.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Datadog labels for unified service tagging
*/}}
{{- define "product-service.datadogLabels" -}}
{{- if .Values.datadog.enabled }}
tags.datadoghq.com/env: {{ .Values.datadog.env | quote }}
tags.datadoghq.com/service: {{ .Values.datadog.service | quote }}
tags.datadoghq.com/version: {{ .Values.image.tag | quote }}
{{- end }}
{{- end }}

{{/*
Datadog annotations for auto-instrumentation
*/}}
{{- define "product-service.datadogAnnotations" -}}
{{- if .Values.datadog.enabled }}
{{- if .Values.datadog.apm.enabled }}
admission.datadoghq.com/enabled: "true"
{{- if eq .Values.datadog.apm.language "rust" }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
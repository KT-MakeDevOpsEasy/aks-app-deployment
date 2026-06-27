{{- define "database.fullname" -}}
{{ .Release.Name }}-database
{{- end }}

{{- define "database.labels" -}}
app.kubernetes.io/name: database
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{- define "database.selectorLabels" -}}
app.kubernetes.io/name: database
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

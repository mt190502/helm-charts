{{- define "copilot-api.main.image" -}}
{{- if .Values.image.main.tag -}}
{{- printf "%s:v%s" .Values.image.main.repository (.Values.image.main.tag | toString) -}}
{{- else -}}
{{- printf "%s:v%s" .Values.image.main.repository .Chart.AppVersion -}}
{{- end -}}
{{- end -}}
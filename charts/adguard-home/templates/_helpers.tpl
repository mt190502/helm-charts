{{- define "adguard-home.web.image" -}}
{{- if .Values.image.web.tag -}}
{{- printf "%s:v%s" .Values.image.web.repository (.Values.image.web.tag | toString) -}}
{{- else -}}
{{- printf "%s:v%s" .Values.image.web.repository .Chart.AppVersion -}}
{{- end -}}
{{- end -}}
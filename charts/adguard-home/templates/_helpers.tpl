{{- define "adguard-home.web.image" -}}
{{- if .Values.image.web.tag -}}
{{- printf "%s:v%s" .Values.image.web.repository (.Values.image.web.tag | toString) -}}
{{- else -}}
{{- printf "%s:v%s" .Values.image.web.repository .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{- define "getSecretValue" -}}
{{- if .Values.global.web.tls.enabled -}}
{{- $secret := lookup "v1" "Secret" .Values.global.web.tls.secretNamespace .Values.global.web.tls.secretName -}}
{{- if $secret -}}
{{- $value := index $secret.data .key -}}
{{- $value -}}
{{- else -}}
{{- printf "Error: Key '%s' not found in Secret '%s/%s'" .Values.global.web.tls.key .Values.global.web.tls.secretNamespace .Values.global.web.tls.secretName -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- define "paperless-ngx.image" -}}
{{- if .Values.image.tag -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.repository .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{- define "redis.url" -}}
{{- if eq .Values.global.redis.external.enabled .Values.global.redis.internal.enabled -}}
{{- fail "redis.url: redis.external.enabled and redis.internal.enabled are equal" -}}
{{- end -}}
{{- if .Values.global.redis.external.enabled -}}
{{- printf "redis://%s:%d" .Values.global.redis.external.host .Values.global.redis.external.port -}}
{{- else -}}
{{- printf "redis://%s-broker:6379" .Release.Name -}}
{{- end -}}
{{- end -}}
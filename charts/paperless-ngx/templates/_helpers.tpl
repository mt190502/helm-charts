{{- define "paperless-ngx.web.image" -}}
{{- if .Values.image.web.tag -}}
{{- printf "%s:%s" .Values.image.web.repository (.Values.image.web.tag | toString) -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.web.repository .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{- define "paperless-ngx.postgres.image" -}}
{{- if .Values.image.postgres.tag -}}
{{- printf "%s:%s" .Values.image.postgres.repository (.Values.image.postgres.tag | toString) -}}
{{- else -}}
{{- printf "%s:latest" .Values.image.postgres.repository -}}
{{- end -}}
{{- end -}}

{{- define "paperless-ngx.broker.image" -}}
{{- if .Values.image.broker.tag -}}
{{- printf "%s:%s" .Values.image.broker.repository (.Values.image.broker.tag | toString) -}}
{{- else -}}
{{- printf "%s:latest" .Values.image.broker.repository -}}
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
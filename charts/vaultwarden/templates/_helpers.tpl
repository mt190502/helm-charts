{{- define "vaultwarden.web.image" -}}
{{- if .Values.image.web.tag -}}
{{- printf "%s:%s" .Values.image.web.repository (.Values.image.web.tag | toString) -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.web.repository .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{- define "vaultwarden.postgres.image" -}}
{{- if .Values.image.postgres.tag -}}
{{- printf "%s:%s" .Values.image.postgres.repository (.Values.image.postgres.tag | toString) -}}
{{- else -}}
{{- printf "%s:latest" .Values.image.postgres.repository -}}
{{- end -}}
{{- end -}}

{{- define "postgres.url" -}}
{{- if eq .Values.global.postgres.external.enabled .Values.global.postgres.internal.enabled -}}
{{- fail "postgres.url: postgres.external.enabled and postgres.internal.enabled are equal" -}}
{{- end -}}
{{- if .Values.global.postgres.external.enabled -}}
{{- printf "postgresql://%s:%s@%s:%s/%s" .Values.global.postgres.options.username .Values.global.postgres.options.password .Values.global.postgres.external.host .Values.global.postgres.external.port .Values.global.postgres.options.database | quote -}}
{{- else -}}
{{- printf "postgresql://%s:%s@%s-postgres:5432/%s" .Values.global.postgres.options.username .Values.global.postgres.options.password .Release.Name .Values.global.postgres.options.database | quote -}}
{{- end -}}
{{- end -}}

{{- define "memos.image" -}}
{{- if .Values.image.tag -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.repository .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{- define "postgres.url" -}}
{{- if eq .Values.global.postgres.external.enabled .Values.global.postgres.internal.enabled -}}
{{- fail "postgres.url: postgres.external.enabled and postgres.internal.enabled are equal" -}}
{{- end -}}
{{- if .Values.global.postgres.external.enabled -}}
{{- printf "postgresql://%s:%s@%s:%s/%s?sslmode=disable" .Values.global.postgres.options.username .Values.global.postgres.options.password .Values.global.postgres.external.host .Values.global.postgres.external.port .Values.global.postgres.options.database | quote -}}
{{- else -}}
{{- printf "postgresql://%s:%s@%s-postgres:5432/%s?sslmode=disable" .Values.global.postgres.options.username .Values.global.postgres.options.password .Release.Name .Values.global.postgres.options.database | quote -}}
{{- end -}}
{{- end -}}

{{- define "commafeed.web.image" -}}
{{- if .Values.image.web.tag -}}
{{- printf "%s:%s-postgresql" .Values.image.web.repository (.Values.image.web.tag | toString) -}}
{{- else -}}
{{- printf "%s:%s-postgresql" .Values.image.web.repository .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{- define "commafeed.postgres.image" -}}
{{- if .Values.image.postgres.tag -}}
{{- printf "%s:%s" .Values.image.postgres.repository (.Values.image.postgres.tag | toString) -}}
{{- else -}}
{{- printf "%s:latest" .Values.image.postgres.repository -}}
{{- end -}}
{{- end -}}

{{- define "postgres.jdbc" -}}
{{- if eq .Values.global.postgres.external.enabled .Values.global.postgres.internal.enabled -}}
{{- fail "postgres.jdbc: postgres.external.enabled and postgres.internal.enabled are equal" -}}
{{- end -}}
{{- if .Values.global.postgres.external.enabled -}}
{{- printf "jdbc:postgresql://%s:%.0f/%s" .Values.global.postgres.external.host .Values.global.postgres.external.port .Values.global.postgres.options.database | quote -}}
{{- else -}}
{{- printf "jdbc:postgresql://%s-postgres:5432/%s" .Release.Name .Values.global.postgres.options.database | quote -}}
{{- end -}}
{{- end -}}

{{- define "commafeed.image" -}}
{{- if .Values.image.tag -}}
{{- printf "%s:%s-postgresql" .Values.image.repository .Values.image.tag -}}
{{- else -}}
{{- printf "%s:%s-postgresql" .Values.image.repository .Chart.AppVersion -}}
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

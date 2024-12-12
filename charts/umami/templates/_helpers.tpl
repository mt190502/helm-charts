{{- define "umami.web.image" -}}
{{- if .Values.global.postgres.selected -}}
{{- printf "%s:postgresql-v%s" .Values.image.web.repository ((or .Values.image.web.tag .Chart.AppVersion) | toString) -}}
{{- else if .Values.global.mysql.selected -}}
{{- printf "%s:mysql-v%s" .Values.image.web.repository ((or .Values.image.web.tag .Chart.AppVersion) | toString) -}}
{{- else if .Values.image.web.tag -}}
{{- printf "%s:%s" .Values.image.web.repository ((or .Values.image.web.tag .Chart.AppVersion) | toString) -}}
{{- end -}}
{{- end -}}

{{- define "umami.postgres.image" -}}
{{- if .Values.image.postgres.tag -}}
{{- printf "%s:%s" .Values.image.postgres.repository (.Values.image.postgres.tag | toString) -}}
{{- else -}}
{{- printf "%s:postgresql-latest" .Values.image.postgres.repository -}}
{{- end -}}
{{- end -}}

{{- define "umami.mysql.image" -}}
{{- if .Values.image.mysql.tag -}}
{{- printf "%s:%s" .Values.image.mysql.repository (.Values.image.mysql.tag | toString) -}}
{{- else -}}
{{- printf "%s:mysql-latest" .Values.image.mysql.repository -}}
{{- end -}}
{{- end -}}

{{- define "postgres.url" -}}
{{- if and .Values.global.postgres.selected (eq .Values.global.postgres.external.enabled .Values.global.postgres.internal.enabled) -}}
{{- fail "postgres.url: postgres.external.enabled and postgres.internal.enabled are equal" -}}
{{- else if eq .Values.global.postgres.selected .Values.global.mysql.selected -}}
{{- fail "postgres.url: postgres.selected and mysql.selected cannot both" -}}
{{- end -}}
{{- if .Values.global.postgres.external.enabled -}}
{{- printf "postgresql://%s:%s@%s:%.0f/%s" .Values.global.postgres.options.username .Values.global.postgres.options.password .Values.global.postgres.external.host .Values.global.postgres.external.port .Values.global.postgres.options.database | quote -}}
{{- else -}}
{{- printf "postgresql://%s:%s@%s-postgres:5432/%s" .Values.global.postgres.options.username .Values.global.postgres.options.password .Release.Name .Values.global.postgres.options.database | quote -}}
{{- end -}}
{{- end -}}

{{- define "mysql.url" -}}
{{- if and .Values.global.mysql.selected (eq .Values.global.mysql.external.enabled .Values.global.mysql.internal.enabled) -}}
{{- fail "mysql.url: mysql.external.enabled and mysql.internal.enabled are equal" -}}
{{- else if eq .Values.global.postgres.selected .Values.global.mysql.selected -}}
{{- fail "mysql.url: postgres.selected and mysql.selected cannot both" -}}
{{- end -}}
{{- if .Values.global.mysql.external.enabled -}}
{{- printf "mysql://%s:%s@%s:%.0f/%s" .Values.global.mysql.options.username .Values.global.mysql.options.password .Values.global.mysql.external.host .Values.global.mysql.external.port .Values.global.mysql.options.database | quote -}}
{{- else -}}
{{- printf "mysql://%s:%s@%s-mysql:3306/%s" .Values.global.mysql.options.username .Values.global.mysql.options.password .Release.Name .Values.global.mysql.options.database | quote -}}
{{- end -}}
{{- end -}}

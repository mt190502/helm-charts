{{- define "redmine.web.image" -}}
{{- if .Values.image.web.tag -}}
{{- printf "%s:%s" .Values.image.web.repository (.Values.image.web.tag | toString) -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.web.repository .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{- define "redmine.postgres.image" -}}
{{- if eq .Values.global.postgres.external.enabled .Values.global.postgres.internal.enabled -}}
{{- fail "postgres.url: postgres.external.enabled and postgres.internal.enabled are equal" -}}
{{- end -}}
{{- if eq .Values.global.postgres.selected .Values.global.mysql.selected -}}
{{- fail "postgres.url: postgres.selected and mysql.selected are equal" -}}
{{- end -}}
{{- if .Values.image.postgres.tag -}}
{{- printf "%s:%s" .Values.image.postgres.repository (.Values.image.postgres.tag | toString) -}}
{{- else -}}
{{- printf "%s:postgresql-latest" .Values.image.postgres.repository -}}
{{- end -}}
{{- end -}}

{{- define "redmine.mysql.image" -}}
{{- if eq .Values.global.mysql.external.enabled .Values.global.mysql.internal.enabled -}}
{{- fail "mysql.url: mysql.external.enabled and mysql.internal.enabled are equal" -}}
{{- end -}}
{{- if eq .Values.global.mysql.selected .Values.global.postgres.selected -}}
{{- fail "mysql.url: mysql.selected and postgres.selected are equal" -}}
{{- end -}}
{{- if .Values.image.mysql.tag -}}
{{- printf "%s:%s" .Values.image.mysql.repository (.Values.image.mysql.tag | toString) -}}
{{- else -}}
{{- printf "%s:mysql-latest" .Values.image.mysql.repository -}}
{{- end -}}
{{- end -}}
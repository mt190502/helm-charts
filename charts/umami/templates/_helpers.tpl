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

{{- define "postgres.credentials" -}}
{{- if eq .Values.global.postgres.external.enabled .Values.global.postgres.internal.enabled -}}
{{- fail "postgres.url: postgres.external.enabled and postgres.internal.enabled are equal" -}}
{{- end -}}
{{- if eq .Values.global.postgres.selected .Values.global.mysql.selected -}}
{{- fail "postgres.url: postgres.selected and mysql.selected are equal" -}}
{{- end -}}
{{- $namespace := (lookup "v1" "Namespace" "" .Release.Namespace) -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres" .Release.Name)) -}}
{{- $raw := (default false .raw) -}}
{{- if and (not $secret) .Values.global.postgres.secret.enabled (eq (.Values.global.postgres.secret.autoCreate | toString) "false") }}
{{- fail (printf "secret not found in '%s' namespace and autoCreate secret is '%v'" .Release.Namespace .Values.global.postgres.secret.autoCreate) }}
{{- end -}}
{{- $namespace := (lookup "v1" "Namespace" "" .Release.Namespace) -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres" .Release.Name)) -}}
{{- if and (not $secret) .Values.global.postgres.secret.enabled (eq (.Values.global.postgres.secret.autoCreate | toString) "false") }}
{{- fail (printf "secret not found in '%s' namespace and autoCreate secret is '%v'" .Release.Namespace .Values.global.postgres.secret.autoCreate) }}
{{- else if and (not .Values.global.postgres.secret.enabled) (eq (.Values.global.postgres.secret.autoCreate | toString) "false") }}
  {{- if .Values.global.postgres.external.enabled -}}
    {{- printf "postgresql://%s:%s@%s:%d/%s" .Values.global.postgres.options.username .Values.global.postgres.options.password .Values.global.postgres.external.host .Values.global.postgres.external.port .Values.global.postgres.options.database -}}
  {{- else -}}
    {{- printf "postgresql://%s:%s@%s-postgres:%d/%s" .Values.global.postgres.options.username .Values.global.postgres.options.password .Release.Name 5432 .Values.global.postgres.options.database -}}
  {{- end -}}
{{- else -}}
{{- printf "postgresql://$(POSTGRES_USERNAME):$(POSTGRES_PASSWORD)@$(POSTGRES_HOST):$(POSTGRES_PORT)/$(POSTGRES_DATABASE)" -}}
{{- end -}}
{{- end -}}

{{- define "mysql.credentials" -}}
{{- if eq .Values.global.mysql.external.enabled .Values.global.mysql.internal.enabled -}}
{{- fail "mysql.url: mysql.external.enabled and mysql.internal.enabled are equal" -}}
{{- end -}}
{{- if eq .Values.global.postgres.selected .Values.global.mysql.selected -}}
{{- fail "postgres.url: postgres.selected and mysql.selected are equal" -}}
{{- end -}}
{{- $namespace := (lookup "v1" "Namespace" "" .Release.Namespace) -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-mysql" .Release.Name)) -}}
{{- $raw := (default false .raw) -}}
{{- if and (not $secret) .Values.global.mysql.secret.enabled (eq (.Values.global.mysql.secret.autoCreate | toString) "false") }}
{{- fail (printf "secret not found in '%s' namespace and autoCreate secret is '%v'" .Release.Namespace .Values.global.mysql.secret.autoCreate) }}
{{- else if and (not .Values.global.mysql.secret.enabled) (eq (.Values.global.mysql.secret.autoCreate | toString) "false") }}
  {{- if .Values.global.mysql.external.enabled -}}
    {{- printf "mysql://%s:%s@%s:%d/%s" .Values.global.mysql.options.username .Values.global.mysql.options.password .Values.global.mysql.external.host .Values.global.mysql.external.port .Values.global.mysql.options.database -}}
  {{- else -}}
    {{- printf "mysql://%s:%s@%s-postgres:%d/%s" .Values.global.mysql.options.username .Values.global.mysql.options.password .Release.Name 3306 .Values.global.mysql.options.database -}}
  {{- end -}}
{{- else -}}
{{- printf "mysql://$(MYSQL_USERNAME):$(MYSQL_PASSWORD)@$(MYSQL_HOST):$(MYSQL_PORT)/$(MYSQL_DATABASE)" -}}
{{- end -}}
{{- end -}}

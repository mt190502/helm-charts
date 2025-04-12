{{- define "<<<APPNAME>>>.main.image" -}}
{{- if .Values.global.postgresql.selected -}}
{{- printf "%s:%s" .Values.image.main.repository ((or .Values.image.main.tag .Chart.AppVersion) | toString) -}}
{{- else if .Values.global.mysql.selected -}}
{{- printf "%s:%s" .Values.image.main.repository ((or .Values.image.main.tag .Chart.AppVersion) | toString) -}}
{{- else if .Values.image.main.tag -}}
{{- printf "%s:%s" .Values.image.main.repository ((or .Values.image.main.tag .Chart.AppVersion) | toString) -}}
{{- end -}}
{{- end -}}

{{- define "<<<APPNAME>>>.postgresql.image" -}}
{{- if eq .Values.global.postgresql.external.enabled .Values.global.postgresql.internal.enabled -}}
{{- fail "postgresql.image: postgresql.external.enabled and postgresql.internal.enabled are equal" -}}
{{- end -}}
{{- if eq .Values.global.postgresql.selected .Values.global.mysql.selected -}}
{{- fail "postgresql.image: postgresql.selected and mysql.selected are equal" -}}
{{- end -}}
{{- if .Values.image.postgresql.tag -}}
{{- printf "%s:%s" .Values.image.postgresql.repository (.Values.image.postgresql.tag | toString) -}}
{{- else -}}
{{- fail "postgresql image tag is not set" -}}
{{- end -}}
{{- end -}}

{{- define "<<<APPNAME>>>.mysql.image" -}}
{{- if eq .Values.global.mysql.external.enabled .Values.global.mysql.internal.enabled -}}
{{- fail "mysql.image: mysql.external.enabled and mysql.internal.enabled are equal" -}}
{{- end -}}
{{- if eq .Values.global.mysql.selected .Values.global.postgresql.selected -}}
{{- fail "mysql.image: mysql.selected and postgresql.selected are equal" -}}
{{- end -}}
{{- if .Values.image.mysql.tag -}}
{{- printf "%s:%s" .Values.image.mysql.repository (.Values.image.mysql.tag | toString) -}}
{{- else -}}
{{- fail "mysql image tag is not set" -}}
{{- end -}}
{{- end -}}

{{- define "postgresql.credentials" -}}
{{- if eq .Values.global.postgresql.external.enabled .Values.global.postgresql.internal.enabled -}}
{{- fail "postgresql.credentials: postgresql.external.enabled and postgresql.internal.enabled are equal" -}}
{{- end -}}
{{- if eq .Values.global.postgresql.selected .Values.global.mysql.selected -}}
{{- fail "postgresql.credentials: postgresql.selected and mysql.selected are equal" -}}
{{- end -}}
{{- $namespace := (lookup "v1" "Namespace" "" .Release.Namespace) -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgresql" .Release.Name)) -}}
{{- $raw := (default false .raw) -}}
{{- if and (not $secret) .Values.global.postgresql.secret.enabled (eq (.Values.global.postgresql.secret.autoCreate | toString) "false") }}
{{- fail (printf "secret not found in '%s' namespace and autoCreate secret is '%v'" .Release.Namespace .Values.global.postgresql.secret.autoCreate) }}
{{- end -}}
{{- $namespace := (lookup "v1" "Namespace" "" .Release.Namespace) -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgresql" .Release.Name)) -}}
{{- if and (not $secret) .Values.global.postgresql.secret.enabled (eq (.Values.global.postgresql.secret.autoCreate | toString) "false") }}
{{- fail (printf "secret not found in '%s' namespace and autoCreate secret is '%v'" .Release.Namespace .Values.global.postgresql.secret.autoCreate) }}
{{- else if and (not .Values.global.postgresql.secret.enabled) (eq (.Values.global.postgresql.secret.autoCreate | toString) "false") }}
  {{- if .Values.global.postgresql.external.enabled -}}
    {{- printf "postgresql://%s:%s@%s:%d/%s" .Values.global.postgresql.options.username .Values.global.postgresql.options.password .Values.global.postgresql.external.host .Values.global.postgresql.external.port .Values.global.postgresql.options.database -}}
  {{- else -}}
    {{- printf "postgresql://%s:%s@%s-postgresql:%d/%s" .Values.global.postgresql.options.username .Values.global.postgresql.options.password .Release.Name 5432 .Values.global.postgresql.options.database -}}
  {{- end -}}
{{- else -}}
{{- printf "postgresql://$(DB_USERNAME):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_DATABASE)" -}}
{{- end -}}
{{- end -}}

{{- define "mysql.credentials" -}}
{{- if eq .Values.global.mysql.external.enabled .Values.global.mysql.internal.enabled -}}
{{- fail "mysql.credentials: mysql.external.enabled and mysql.internal.enabled are equal" -}}
{{- end -}}
{{- if eq .Values.global.postgresql.selected .Values.global.mysql.selected -}}
{{- fail "mysql.credentials: postgresql.selected and mysql.selected are equal" -}}
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
    {{- printf "mysql://%s:%s@%s-mysql:%d/%s" .Values.global.mysql.options.username .Values.global.mysql.options.password .Release.Name 3306 .Values.global.mysql.options.database -}}
  {{- end -}}
{{- else -}}
{{- printf "mysql://$(DB_USERNAME):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_DATABASE)" -}}
{{- end -}}
{{- end -}}
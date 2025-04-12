{{- define "<<<APPNAME>>>.main.image" -}}
{{- if .Values.image.main.tag -}}
{{- printf "%s:%s" .Values.image.main.repository (.Values.image.main.tag | toString) -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.main.repository .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{- define "<<<APPNAME>>>.mysql.image" -}}
{{- if .Values.image.mysql.tag -}}
{{- printf "%s:%s" .Values.image.mysql.repository (.Values.image.mysql.tag | toString) -}}
{{- else -}}
{{- fail "mysql image tag is not set" -}}
{{- end -}}
{{- end -}}

{{- define "mysql.credentials" -}}
{{- if eq .Values.global.mysql.external.enabled .Values.global.mysql.internal.enabled -}}
{{- fail "mysql.url: mysql.external.enabled and mysql.internal.enabled are equal" -}}
{{- end -}}
{{- $namespace := (lookup "v1" "Namespace" "" .Release.Namespace) -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-mysql" .Release.Name)) -}}
{{- $raw := (default false .raw) -}}
{{- if and (not $secret) .Values.global.mysql.secret.enabled (eq (.Values.global.mysql.secret.autoCreate | toString) "false") }}
{{- fail (printf "secret not found in '%s' namespace and autoCreate secret is '%v'" .Release.Namespace .Values.global.mysql.secret.autoCreate) }}
{{- end -}}
{{- $namespace := (lookup "v1" "Namespace" "" .Release.Namespace) -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-mysql" .Release.Name)) -}}
{{- if and (not $secret) .Values.global.mysql.secret.enabled (eq (.Values.global.mysql.secret.autoCreate | toString) "false") }}
{{- fail (printf "secret not found in '%s' namespace and autoCreate secret is '%v'" .Release.Namespace .Values.global.mysql.secret.autoCreate) }}
{{- else if and (not .Values.global.mysql.secret.enabled) (eq (.Values.global.mysql.secret.autoCreate | toString) "false") }}
  {{- if .Values.global.mysql.external.enabled -}}
    {{- printf "mysql://%s:%s@%s:%d/%s" .Values.global.mysql.options.username .Values.global.mysql.options.password .Values.global.mysql.external.host .Values.global.mysql.external.port .Values.global.mysql.options.database -}}
  {{- else -}}
    {{- printf "mysql://%s:%s@%s-mysql:%d/%s" .Values.global.mysql.options.username .Values.global.mysql.options.password .Release.Name 5432 .Values.global.mysql.options.database -}}
  {{- end -}}
{{- else -}}
{{- printf "mysql://$(DB_USERNAME):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_DATABASE)" -}}
{{- end -}}
{{- end -}}
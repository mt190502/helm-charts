{{- define "ghost.main.image" -}}
{{- if .Values.image.main.tag -}}
{{- printf "%s:%s" .Values.image.main.repository (.Values.image.main.tag | toString) -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.main.repository .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{- define "ghost.mysql.image" -}}
{{- if .Values.image.mysql.tag -}}
{{- printf "%s:%s" .Values.image.mysql.repository (.Values.image.mysql.tag | toString) -}}
{{- else -}}
{{- fail "mysql image tag is not set" -}}
{{- end -}}
{{- end -}}

{{- define "mysql.credentials" -}}
{{- if eq .Values.mysql.external.enabled .Values.mysql.internal.enabled -}}
{{- fail "mysql.url: mysql.external.enabled and mysql.internal.enabled are equal" -}}
{{- end -}}
{{- $namespace := (lookup "v1" "Namespace" "" .Release.Namespace) -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-mysql" .Release.Name)) -}}
{{- $raw := (default false .raw) -}}
{{- if and (not $secret) .Values.mysql.secret.enabled (eq (.Values.mysql.secret.autoCreate | toString) "false") }}
{{- fail (printf "secret not found in '%s' namespace and autoCreate secret is '%v'" .Release.Namespace .Values.mysql.secret.autoCreate) }}
{{- end -}}
{{- $namespace := (lookup "v1" "Namespace" "" .Release.Namespace) -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-mysql" .Release.Name)) -}}
{{- if and (not $secret) .Values.mysql.secret.enabled (eq (.Values.mysql.secret.autoCreate | toString) "false") }}
{{- fail (printf "secret not found in '%s' namespace and autoCreate secret is '%v'" .Release.Namespace .Values.mysql.secret.autoCreate) }}
{{- else if and (not .Values.mysql.secret.enabled) (eq (.Values.mysql.secret.autoCreate | toString) "false") }}
  {{- if .Values.mysql.external.enabled -}}
    {{- printf "mysql://%s:%s@%s:%d/%s" .Values.mysql.options.username .Values.mysql.options.password .Values.mysql.external.host .Values.mysql.external.port .Values.mysql.options.database -}}
  {{- else -}}
    {{- printf "mysql://%s:%s@%s-mysql:%d/%s" .Values.mysql.options.username .Values.mysql.options.password .Release.Name 5432 .Values.mysql.options.database -}}
  {{- end -}}
{{- else -}}
{{- printf "mysql://$(DB_USERNAME):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_DATABASE)" -}}
{{- end -}}
{{- end -}}
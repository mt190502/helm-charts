{{- define "codimd.main.image" -}}
{{- if .Values.image.main.tag -}}
{{- printf "%s:%s" .Values.image.main.repository (.Values.image.main.tag | toString) -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.main.repository .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{- define "codimd.postgresql.image" -}}
{{- if .Values.image.postgresql.tag -}}
{{- printf "%s:%s" .Values.image.postgresql.repository (.Values.image.postgresql.tag | toString) -}}
{{- else -}}
{{- fail "postgresql image tag is not set" -}}
{{- end -}}
{{- end -}}

{{- define "postgresql.credentials" -}}
{{- if eq .Values.postgresql.external.enabled .Values.postgresql.internal.enabled -}}
{{- fail "postgresql.credentials: postgresql.external.enabled and postgresql.internal.enabled are equal" -}}
{{- end -}}
{{- $namespace := (lookup "v1" "Namespace" "" .Release.Namespace) -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgresql" .Release.Name)) -}}
{{- $raw := (default false .raw) -}}
{{- if and (not $secret) .Values.postgresql.secret.enabled (eq (.Values.postgresql.secret.autoCreate | toString) "false") }}
{{- fail (printf "secret not found in '%s' namespace and autoCreate secret is '%v'" .Release.Namespace .Values.postgresql.secret.autoCreate) }}
{{- end -}}
{{- $namespace := (lookup "v1" "Namespace" "" .Release.Namespace) -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgresql" .Release.Name)) -}}
{{- if and (not $secret) .Values.postgresql.secret.enabled (eq (.Values.postgresql.secret.autoCreate | toString) "false") }}
{{- fail (printf "secret not found in '%s' namespace and autoCreate secret is '%v'" .Release.Namespace .Values.postgresql.secret.autoCreate) }}
{{- else if and (not .Values.postgresql.secret.enabled) (eq (.Values.postgresql.secret.autoCreate | toString) "false") }}
  {{- if .Values.postgresql.external.enabled -}}
    {{- printf "postgres://%s:%s@%s:%.0f/%s" .Values.postgresql.options.username .Values.postgresql.options.password .Values.postgresql.external.host .Values.postgresql.external.port .Values.postgresql.options.database -}}
  {{- else -}}
    {{- printf "postgres://%s:%s@%s-postgresql:%d/%s" .Values.postgresql.options.username .Values.postgresql.options.password .Release.Name 5432 .Values.postgresql.options.database -}}
  {{- end -}}
{{- else -}}
{{- printf "postgres://$(DB_USERNAME):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_DATABASE)" -}}
{{- end -}}
{{- end -}}
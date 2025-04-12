{{- define "paperless-ngx.main.image" -}}
{{- if .Values.image.main.tag -}}
{{- printf "%s:%s" .Values.image.main.repository (.Values.image.main.tag | toString) -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.main.repository .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{- define "paperless-ngx.postgresql.image" -}}
{{- if .Values.image.postgresql.tag -}}
{{- printf "%s:%s" .Values.image.postgresql.repository (.Values.image.postgresql.tag | toString) -}}
{{- else -}}
{{- fail "postgresql image tag is not set" -}}
{{- end -}}
{{- end -}}

{{- define "paperless-ngx.redis.image" -}}
{{- if .Values.image.redis.tag -}}
{{- printf "%s:%s" .Values.image.redis.repository (.Values.image.redis.tag | toString) -}}
{{- else -}}
{{- printf "%s:latest" .Values.image.redis.repository -}}
{{- end -}}
{{- end -}}

{{- define "redis.url" -}}
{{- if eq .Values.global.redis.external.enabled .Values.global.redis.internal.enabled -}}
{{- fail "redis.url: redis.external.enabled and redis.internal.enabled are equal" -}}
{{- end -}}
{{- if .Values.global.redis.external.enabled -}}
{{- printf "redis://%s:%d" .Values.global.redis.external.host .Values.global.redis.external.port -}}
{{- else -}}
{{- printf "redis://%s-redis:6379" .Release.Name -}}
{{- end -}}
{{- end -}}

{{- define "postgresql.credentials" -}}
{{- if eq .Values.global.postgresql.external.enabled .Values.global.postgresql.internal.enabled -}}
{{- fail "postgresql.credentials: postgresql.external.enabled and postgresql.internal.enabled are equal" -}}
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
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

{{- define "postgres.credentials" -}}
{{- if eq .Values.global.postgres.external.enabled .Values.global.postgres.internal.enabled -}}
{{- fail "postgres.url: postgres.external.enabled and postgres.internal.enabled are equal" -}}
{{- end -}}
{{- $namespace := (lookup "v1" "Namespace" "" .Release.Namespace) -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres" .Release.Name)) -}}
{{- $raw := (default false .raw) -}}
{{- if and (not $secret) .Values.global.postgres.secret.enabled (eq (.Values.global.postgres.secret.autoCreate | toString) "false") }}
{{- fail (printf "secret not found in '%s' namespace and autoCreate secret is '%v'" .Release.Namespace .Values.global.postgres.secret.autoCreate) }}
{{- else if and (not .Values.global.postgres.secret.enabled) (eq (.Values.global.postgres.secret.autoCreate | toString) "false") }}
  {{- if .Values.global.postgres.external.enabled -}}
    {{- printf "jdbc:postgresql://%s:%s/%s" .Values.global.postgres.external.host .Values.global.postgres.external.port .Values.global.postgres.options.database -}}
  {{- else -}}
    {{- printf "jdbc:postgresql://%s-postgres:%d/%s" .Release.Name 5432 .Values.global.postgres.options.database -}}
  {{- end -}}
{{- else -}}
{{- printf "jdbc:postgresql://$(DB_HOST):$(DB_PORT)/$(DB_DATABASE)" -}}
{{- end -}}
{{- end -}}
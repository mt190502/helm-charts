{{- define "commafeed.main.image" -}}
{{- if .Values.image.main.tag -}}
{{- printf "%s:%s-postgresql" .Values.image.main.repository (.Values.image.main.tag | toString) -}}
{{- else -}}
{{- printf "%s:%s-postgresql" .Values.image.main.repository .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{- define "commafeed.postgresql.image" -}}
{{- if .Values.image.postgresql.tag -}}
{{- printf "%s:%s" .Values.image.postgresql.repository (.Values.image.postgresql.tag | toString) -}}
{{- else -}}
{{- fail "postgresql image tag is not set" -}}
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
    {{- printf "jdbc:postgresql://%s:%s/%s" .Values.global.postgresql.external.host .Values.global.postgresql.external.port .Values.global.postgresql.options.database -}}
  {{- else -}}
    {{- printf "jdbc:postgresql://%s-postgresql:%d/%s" .Release.Name 5432 .Values.global.postgresql.options.database -}}
  {{- end -}}
{{- else -}}
{{- printf "jdbc:postgresql://$(DB_HOST):$(DB_PORT)/$(DB_DATABASE)" -}}
{{- end -}}
{{- end -}}
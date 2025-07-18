{{- define "nightscout.main.image" -}}
{{- if .Values.image.main.tag -}}
{{- printf "%s:%s" .Values.image.main.repository (.Values.image.main.tag | toString) -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.main.repository .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{- define "nightscout.mongo.image" -}}
{{- if .Values.image.mongo.tag -}}
{{- printf "%s:%s" .Values.image.mongo.repository (.Values.image.mongo.tag | toString) -}}
{{- else -}}
{{- fail "mongo image tag is not set" -}}
{{- end -}}
{{- end -}}

{{- define "mongo.credentials" -}}
{{- if eq .Values.mongo.external.enabled .Values.mongo.internal.enabled -}}
{{- fail "mongo.url: mongo.external.enabled and mongo.internal.enabled are equal" -}}
{{- end -}}
{{- $namespace := (lookup "v1" "Namespace" "" .Release.Namespace) -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-mongo" .Release.Name)) -}}
{{- $raw := (default false .raw) -}}
{{- if and (not $secret) .Values.mongo.secret.enabled (eq (.Values.mongo.secret.autoCreate | toString) "false") }}
{{- fail (printf "secret not found in '%s' namespace and autoCreate secret is '%v'" .Release.Namespace .Values.mongo.secret.autoCreate) }}
{{- end -}}
{{- $namespace := (lookup "v1" "Namespace" "" .Release.Namespace) -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-mongo" .Release.Name)) -}}
{{- if and (not $secret) .Values.mongo.secret.enabled (eq (.Values.mongo.secret.autoCreate | toString) "false") }}
{{- fail (printf "secret not found in '%s' namespace and autoCreate secret is '%v'" .Release.Namespace .Values.mongo.secret.autoCreate) }}
{{- else if and (not .Values.mongo.secret.enabled) (eq (.Values.mongo.secret.autoCreate | toString) "false") }}
  {{- if .Values.mongo.external.enabled -}}
    {{- printf "mongodb://%s:%s@%s:%d/%s" .Values.mongo.external.username .Values.mongo.external.password .Values.mongo.external.host .Values.mongo.external.port .Values.mongo.options.database -}}
  {{- else -}}
    {{- printf "mongodb://%s:%s@%s-mongo:%d/%s" .Values.mongo.internal.username .Values.mongo.internal.password .Release.Name 27017 .Values.mongo.options.database -}}
  {{- end -}}
{{- else -}}
{{- printf "mongodb://$(DB_USERNAME):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_DATABASE)" -}}
{{- end -}}
{{- end -}}
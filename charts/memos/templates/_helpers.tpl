{{- define "memos.web.image" -}}
{{- if .Values.image.web.tag -}}
{{- printf "%s:%s" .Values.image.web.repository (.Values.image.web.tag | toString) -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.web.repository .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{- define "memos.postgres.image" -}}
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
{{- if and $namespace $secret }}
  {{- $data := $secret.data -}}
  {{- $username := (get $data .Values.global.postgres.secret.usernameKey | b64dec) -}}
  {{- $password := (get $data .Values.global.postgres.secret.passwordKey | b64dec) -}}
  {{- $database := (get $data .Values.global.postgres.secret.databaseKey | b64dec) -}}
  {{- if .Values.global.postgres.external.enabled -}}
    {{- printf "%s %s %s %s %.0f" $username $password $database .Values.global.postgres.external.host .Values.global.postgres.external.port -}}
  {{- else -}}
    {{- printf "%s %s %s %s %d" $username $password $database (printf "%s-postgres" .Release.Name) 5432 -}}
  {{- end -}}
{{- else -}}
  {{- $username := .Values.global.postgres.options.username -}}
  {{- $password := .Values.global.postgres.options.password -}}
  {{- $database := .Values.global.postgres.options.database -}}
  {{- if .Values.global.postgres.external.enabled -}}
    {{- printf "%s %s %s %s %.0f" $username $password $database .Values.global.postgres.external.host .Values.global.postgres.external.port -}}
  {{- else -}}
    {{- printf "%s %s %s %s %d" $username $password $database (printf "%s-postgres" .Release.Name) 5432 -}}
  {{- end -}}
{{- end -}}
{{- end -}}
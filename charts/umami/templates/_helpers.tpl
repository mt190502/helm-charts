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
{{- $namespace := (lookup "v1" "Namespace" "" .Release.Namespace) -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres" .Release.Name)) -}}
{{- $raw := (default false .raw) -}}
{{- if and (not $secret) .Values.global.postgres.secret.enabled (eq (.Values.global.postgres.secret.autoCreate | toString) "false") }}
{{- fail (printf "secret not found in '%s' namespace and autoCreate secret is '%v'" .Release.Namespace .Values.global.postgres.secret.autoCreate) }}
{{- else if and $namespace $secret }}
  {{- $data := $secret.data -}}
  {{- $username := (get $data .Values.global.postgres.secret.usernameKey | b64dec) -}}
  {{- $password := (get $data .Values.global.postgres.secret.passwordKey | b64dec) -}}
  {{- $database := (get $data .Values.global.postgres.secret.databaseKey | b64dec) -}}
  {{- if .Values.global.postgres.external.enabled -}}
    {{- if $raw -}}
      {{- printf "%s %s %s %s %.0f" $username $password $database .Values.global.postgres.external.host .Values.global.postgres.external.port -}}
    {{- else -}}
      {{- printf "postgresql://%s:%s@%s:%d/%s" $username $password .Values.global.postgres.external.host .Values.global.postgres.external.port $database -}}
    {{- end -}}
  {{- else -}}
    {{- if $raw -}}
      {{- printf "%s %s %s %s %d" $username $password $database (printf "%s-postgres" .Release.Name) 5432 -}}
    {{- else -}}
      {{- printf "postgresql://%s:%s@%s:%d/%s" $username $password (printf "%s-postgres" .Release.Name) 5432 $database -}}
    {{- end -}}
  {{- end -}}
{{- else -}}
  {{- $username := .Values.global.postgres.options.username -}}
  {{- $password := .Values.global.postgres.options.password -}}
  {{- $database := .Values.global.postgres.options.database -}}
  {{- if .Values.global.postgres.external.enabled -}}
    {{- if $raw -}}
      {{- printf "%s %s %s %s %.0f" $username $password $database .Values.global.postgres.external.host .Values.global.postgres.external.port -}}
    {{- else -}}
      {{- printf "postgresql://%s:%s@%s:%d/%s" $username $password .Values.global.postgres.external.host .Values.global.postgres.external.port $database -}}
    {{- end -}}
  {{- else -}}
    {{- if $raw -}}
      {{- printf "%s %s %s %s %d" $username $password $database (printf "%s-postgres" .Release.Name) 5432 -}}
    {{- else -}}
      {{- printf "postgresql://%s:%s@%s:%d/%s" $username $password (printf "%s-postgres" .Release.Name) 5432 $database -}}
    {{- end -}}
  {{- end -}}
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
{{- else if and $namespace $secret }}
  {{- $data := $secret.data -}}
  {{- $username := (get $data .Values.global.mysql.secret.usernameKey | b64dec) -}}
  {{- $password := (get $data .Values.global.mysql.secret.passwordKey | b64dec) -}}
  {{- $database := (get $data .Values.global.mysql.secret.databaseKey | b64dec) -}}
  {{- $rootPassword := (get $data .Values.global.mysql.secret.rootPasswordKey | b64dec) -}}
  {{- if .Values.global.mysql.external.enabled -}}
    {{- if $raw -}}
      {{- printf "%s %s %s %s %s %.0f" $username $password $database $rootPassword .Values.global.mysql.external.host .Values.global.mysql.external.port -}}
    {{- else -}}
      {{- printf "mysql://%s:%s@%s:%d/%s" $username $password .Values.global.mysql.external.host .Values.global.mysql.external.port $database -}}
    {{- end -}}
  {{- else -}}
    {{- if $raw -}}
      {{- printf "%s %s %s %s %s %d" $username $password $database $rootPassword (printf "%s-mysql" .Release.Name) 3306 -}}
    {{- else -}}
      {{- printf "mysql://%s:%s@%s:%d/%s" $username $password (printf "%s-mysql" .Release.Name) 3306 $database -}}
    {{- end -}}
  {{- end -}}
{{- else -}}
  {{- $username := .Values.global.mysql.options.username -}}
  {{- $password := .Values.global.mysql.options.password -}}
  {{- $database := .Values.global.mysql.options.database -}}
  {{- $rootPassword := .Values.global.mysql.options.rootPassword -}}
  {{- if .Values.global.mysql.external.enabled -}}
    {{- if $raw -}}
      {{- printf "%s %s %s %s %s %.0f" $username $password $database $rootPassword .Values.global.mysql.external.host .Values.global.mysql.external.port -}}
    {{- else -}}
      {{- printf "mysql://%s:%s@%s:%d/%s" $username $password .Values.global.mysql.external.host .Values.global.mysql.external.port $database -}}
    {{- end -}}
  {{- else -}}
    {{- if $raw -}}
      {{- printf "%s %s %s %s %s %d" $username $password $database $rootPassword (printf "%s-mysql" .Release.Name) 3306 -}}
    {{- else -}}
      {{- printf "mysql://%s:%s@%s:%d/%s" $username $password (printf "%s-mysql" .Release.Name) 3306 $database -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

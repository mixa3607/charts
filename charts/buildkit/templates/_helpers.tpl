{{/*
Return the path to the cert file.
*/}}
{{- define "buildkit.tlsCert" -}}
{{- required "Certificate is required when TLS in enabled" .Values.tls.cert -}}
{{- end -}}

{{/*
Return the path to the cert key file.
*/}}
{{- define "buildkit.tlsCertKey" -}}
{{- required "Certificate Key is required when TLS in enabled" .Values.tls.certKey -}}
{{- end -}}

{{/*
Return the path to the CA cert file.
*/}}
{{- define "buildkit.tlsCertCACert" -}}
{{- required "Certificate CA is required when TLS in enabled" .Values.tls.certCA -}}
{{- end -}}

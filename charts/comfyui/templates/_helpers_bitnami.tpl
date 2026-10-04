{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper comfyui image name
*/}}
{{- define "comfyui.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global "chart" .Chart) -}}
{{- end -}}

{{/* Return the proper File Browser image name */}}
{{- define "comfyui.fileManagerImage" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.fileManagerSidecar.image "global" .Values.global "chart" .Chart) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "comfyui.imagePullSecrets" -}}
{{- $images := list .Values.image -}}
{{- if .Values.fileManagerSidecar.enabled -}}
{{- $images = append $images .Values.fileManagerSidecar.image -}}
{{- end -}}
{{- include "common.images.renderPullSecrets" (dict "images" $images "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "comfyui.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return true if cert-manager required annotations for TLS signed certificates are set in the Ingress annotations
Ref: https://cert-manager.io/docs/usage/ingress/#supported-annotations
*/}}
{{- define "comfyui.ingress.certManagerRequest" -}}
{{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "comfyui.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "comfyui.validateValues.foo" .) -}}
{{- $messages := append $messages (include "comfyui.validateValues.bar" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}

{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper llamacpp-rpc image name
*/}}
{{- define "llamacpp-rpc.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global "chart" .Chart) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "llamacpp-rpc.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.image) "context" $) -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "llamacpp-rpc.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "llamacpp-rpc.validateValues.foo" .) -}}
{{- $messages := append $messages (include "llamacpp-rpc.validateValues.bar" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}

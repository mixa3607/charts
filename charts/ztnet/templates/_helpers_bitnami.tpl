{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper ZeroTier image name
*/}}
{{- define "ztnet.zerotier.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.zerotier.image "global" .Values.global "chart" .Chart) -}}
{{- end -}}

{{/*
Return the proper ztnet image name
*/}}
{{- define "ztnet.ztnet.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.ztnet.image "global" .Values.global "chart" .Chart) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "ztnet.imagePullSecrets" -}}
{{- $imagePullSecrets := (include "common.images.renderPullSecrets" (dict "images" (list .Values.ztnet.image .Values.zerotier.image) "context" $) | fromYaml).imagePullSecrets | default list -}}
{{- $pullSecrets := list -}}
{{- range .Values.pullSecrets }}
{{- $pullSecrets = append $pullSecrets (dict "name" .) -}}
{{- end -}}
{{- $pullSecrets = concat $imagePullSecrets $pullSecrets -}}
{{- if $pullSecrets }}
imagePullSecrets:
{{- toYaml $pullSecrets | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Return true if cert-manager required annotations for TLS signed certificates are set in the Ingress annotations
Ref: https://cert-manager.io/docs/usage/ingress/#supported-annotations
*/}}
{{- define "ztnet.ingress.certManagerRequest" -}}
{{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") }}
    {{- true -}}
{{- end -}}
{{- end -}}

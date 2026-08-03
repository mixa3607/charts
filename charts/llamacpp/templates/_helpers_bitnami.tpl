{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper llamacpp image name
*/}}
{{- define "llamacpp.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global "chart" .Chart) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "llamacpp.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "llamacpp.serviceAccountName" -}}
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
{{- define "llamacpp.ingress.certManagerRequest" -}}
{{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "llamacpp.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "llamacpp.validateValues.foo" .) -}}
{{- $messages := append $messages (include "llamacpp.validateValues.bar" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}

{{/*
Generate INI content from models configuration.
*/}}
{{- define "llamacpp.renderModelsIni" -}}
{{- $root := . -}}
{{- with .Values.models -}}
{{- $defaults := .defaults | default dict -}}
{{- range $name, $config := .presets -}}
{{- if or (not (hasKey $config "enabled")) $config.enabled -}}
{{- $presetConfig := omit $config "enabled" -}}
{{- $mergedConfig := mergeOverwrite (dict) $defaults $presetConfig -}}
[{{ $name }}]
{{ range $k, $v := $mergedConfig }}{{ include "llamacpp.renderIniValue" (list $root $k $v) }}{{ end }}
{{ end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Render a single INI value, supporting arrays (each element = separate line)
and nested maps (flattened with dot notation).

Special array handling:
  device, tensor-split, fit-target — join with ","
  override-tensor — dict format: each element {target, tensors} → "(a|b)=CPU,(c)=GPU"
*/}}
{{- define "llamacpp.renderIniValue" -}}
{{- $root := index . 0 -}}
{{- $key := index . 1 -}}
{{- $value := index . 2 -}}
{{- if kindIs "slice" $value -}}
{{- if or (eq $key "device") (eq $key "tensor-split") (eq $key "fit-target") }}
{{ printf "%s = %s\n" $key (join "," $value) }}
{{- else if eq $key "override-tensor" }}
{{- if and $value (kindIs "map" (index $value 0)) }}
{{ printf "%s = %s\n" $key (include "llamacpp.renderOverrideTensor" (list $root $value)) }}
{{- else }}
{{- range $item := $value }}{{ $key }} = {{ include "common.tplvalues.render" (dict "value" $item "context" $root) }}
{{ end -}}
{{- end }}
{{- else }}
{{- range $item := $value }}{{ $key }} = {{ include "common.tplvalues.render" (dict "value" $item "context" $root) }}
{{ end -}}
{{- end }}
{{- else if kindIs "map" $value -}}
{{- range $sk, $sv := $value }}{{ include "llamacpp.renderIniValue" (list $root (printf "%s-%s" $key $sk) $sv) }}{{ end -}}
{{- else }}{{ $key }} = {{ include "common.tplvalues.render" (dict "value" $value "context" $root) }}
{{ end -}}
{{- end -}}

{{/*
Render override-tensor from structured array.
Input: list of {target: string, tensors: []string}
Output: "(t1|t2)=CPU,(t3)=GPU"  (entries with empty tensors are skipped)
*/}}
{{- define "llamacpp.renderOverrideTensor" -}}
{{- $entries := index . 1 -}}
{{- $parts := list -}}
{{- range $entry := $entries }}
{{- if and (hasKey $entry "tensors") $entry.tensors }}
{{- $parts = append $parts (printf "(%s)=%s" (join "|" $entry.tensors) $entry.target) -}}
{{- end }}
{{- end }}
{{- join "," $parts -}}
{{- end -}}

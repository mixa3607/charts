# Helm package for HuggingFace Model Downloader

Web UI for downloading Hugging Face models and datasets.

## TL;DR

```console
helm install my-release oci://ghcr.io/mixa3607/charts/huggingface-model-downloader
```

## Prerequisites

- Kubernetes 1.30+
- Helm 3.8.0+

## Configuration

The chart persists the Hugging Face cache in a 100 GiB PVC by default. Set
`persistence.existingClaim` to use an existing volume, or set
`persistence.enabled=false` for ephemeral storage.

Enable ingress and basic authentication before exposing the Web UI publicly:

```console
helm install my-release oci://ghcr.io/mixa3607/charts/huggingface-model-downloader \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=hfd.example.com \
  --set auth.enabled=true \
  --set auth.username=admin \
  --set auth.password=change-me
```

For private or gated Hugging Face repositories, reference a Secret with an
`HF_TOKEN` key through `extraEnvVarsSecret`.

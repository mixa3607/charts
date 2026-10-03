# Helm package for proxy-pass

HTTP proxy pass over kubernetes ingresss

## TL;DR

```console
helm install my-release oci://ghcr.io/mixa3607/charts/proxy-pass
```

Set `endpoint.ip` to the upstream IP address to create the Service's Endpoints.
Without it, the chart creates a Service without a backend.

## Prerequisites

- Kubernetes 1.30+
- Helm 3.8.0+

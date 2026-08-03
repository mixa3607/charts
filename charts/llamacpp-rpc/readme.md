# llama.cpp RPC server helm chart

## TL;DR

```console
helm install my-release oci://ghcr.io/mixa3607/charts/llamacpp-rpc
```

## Prerequisites

- Kubernetes 1.30+
- Helm 3.8.0+

## RPC server configuration

The RPC server is configured via `.Values.rpcSettings`:

```yaml
rpcSettings:
  enableCache: true            # enable --cache flag
  cacheDir: /llama-rpc-cache   # sets LLAMA_CACHE env var
  host: 0.0.0.0                # --host
  port: 50052                  # --port
  threads: null                # --threads (null = default)
  device: null                 # --device, comma-separated (null = default)
```

## Persistence

Enable persistence to keep the RPC cache across restarts:

```yaml
persistence:
  enabled: true
  mountPath: /llama-rpc-cache
  size: 8Gi
```

## Custom args

To override the auto-generated args:

```yaml
args:
  - --host
  - 0.0.0.0
  - --port
  - "50052"
  - --cache
  - --threads
  - "38"
```

# Helm package for comfyui

The most powerful and modular diffusion model GUI, api and backend with a graph/nodes interface.

## TL;DR

```console
helm install my-release oci://ghcr.io/mixa3607/charts/comfyui
```

## Prerequisites

- Kubernetes 1.30+
- Helm 3.8.0+

## File Browser

File Browser is enabled by default through `fileManagerSidecar.enabled`. It shares the ComfyUI data volume, including `persistence.subPath`, and has its own Service port at `service.ports.fileManager`. When the main ingress is enabled, `ingress.fileManager.enabled` routes the path from `fileManagerSidecar.config.server.baseURL` (default `/filebrowser`) to it. Set `fileManagerSidecar.config.server.externalUrl` to the public URL when accessing File Browser from outside the cluster.

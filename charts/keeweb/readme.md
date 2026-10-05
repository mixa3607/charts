# Helm package for keeweb

Free cross-platform password manager compatible with KeePass

## TL;DR

```console
helm install my-release oci://ghcr.io/mixa3607/charts/keeweb
```

## Prerequisites

- Kubernetes 1.30+
- Helm 3.8.0+

## Networking and storage

KeeWeb serves HTTP inside the cluster. Configure `ingress.tls` to terminate TLS
at the ingress controller; no backend TLS transport configuration is required.
The chart does not create a PVC: KeeWeb is a static client-side application.

Version 0.2.0 removes the HTTPS service port and the nginx certificate PVC.
Remove backend HTTPS annotations and `keewebNginxVolume` from existing values
before upgrading. Helm deletes the old PVC during the upgrade.

# Helm package for Suwayomi-Server

Suwayomi-Server is a free and open source manga reader server that runs extensions built for [Mihon (Tachiyomi)](https://mihon.app/).

## TL;DR

```console
helm install my-release oci://ghcr.io/mixa3607/charts/suwayomi-server
```

## Prerequisites

- Kubernetes 1.30+
- Helm 3.8.0+
- A client application (Suwayomi-WebUI, Mihon, Neko, KOReader, etc.)

## Configuration

The chart uses the official [Suwayomi-Server Docker image](https://github.com/Suwayomi/Suwayomi-Server-docker)
which supports environment variables for configuration. See the
[Docker documentation](https://github.com/Suwayomi/Suwayomi-Server-docker#environment-variables)
for a full list of available environment variables.

### Common settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.timezone` | Container timezone (`TZ`) | `Etc/UTC` |
| `config.bindIP` | IP address to bind to (`BIND_IP`) | `0.0.0.0` |
| `config.extensionStores` | List of extension stores (`EXTENSION_STORES`) | `[]` |
| `config.authMode` | Authentication mode (`AUTH_MODE`) | `none` |
| `config.authUsername` | Auth username (`AUTH_USERNAME`) | `""` |
| `config.authPassword` | Auth password (`AUTH_PASSWORD`) | `""` |
| `config.webUIEnabled` | Enable WebUI (`WEB_UI_ENABLED`) | `true` |
| `config.debugLogs` | Enable debug logs (`DEBUG`) | `false` |
| `image.tag` | Docker image tag (`stable`, `latest`, `preview`) | `""` (uses `appVersion`) |
| `persistence.enabled` | Enable persistent storage | `false` |
| `persistence.mountPath` | Data directory path | `/home/suwayomi/.local/share/Tachidesk` |

### Persistence

By default, persistence is disabled. Enable it to preserve your library data:

```yaml
persistence:
  enabled: true
  size: 8Gi
```

### Authentication

To enable authentication (recommended when exposing publicly):

```yaml
config:
  authMode: basic_auth
  authUsername: myuser
  authPassword: mypass
```

### Extension Stores

To add custom extension stores:

```yaml
config:
  extensionStores:
    - "https://raw.githubusercontent.com/USER/repo/main/index.min.json"
```

### Ingress

To expose Suwayomi-Server via an ingress:

```yaml
ingress:
  enabled: true
  hostname: suwayomi.example.com
  tls: true
```

### Using a custom server.conf

For settings not available as environment variables, you can mount a custom
`server.conf` file using `extraVolumes` and `extraVolumeMounts`. The file should
be placed in the data directory (`/home/suwayomi/.local/share/Tachidesk/server.conf`).

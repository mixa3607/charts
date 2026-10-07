# ZTNet

Deploys ZTNet and a ZeroTier controller in one pod. PostgreSQL is external;
configure `POSTGRES_*`, `NEXTAUTH_URL` and an authentication secret through
`ztnet.extraEnvVars` or `ztnet.extraEnvVarsSecret`.

## Kubernetes defaults

- ZTNet 0.8.5 and ZeroTier 1.16.2 run as UID/GID `1001:1001`, with
  `runAsNonRoot`, no privileged mode, no privilege escalation and all
  capabilities dropped. The ZeroTier image starts with `-U`; this configuration
  is for a controller, not a node requiring a TUN device or host networking
  administration.
- `podSecurityContext.fsGroup` is `1001`, with `OnRootMismatch` ownership policy.
- ZTNet's startup probe allows up to ten minutes for database initialization
  and migrations before liveness checks begin.
- ZTNet binds to `0.0.0.0`; its internal authentication URL uses localhost and
  `containerPorts.httppublic`. Both environment variables can be overridden
  explicitly in `ztnet.extraEnvVars`.
- An empty `dnsPolicy` selects `ClusterFirst`, or `ClusterFirstWithHostNet`
  when `hostNetwork: true`. Explicit policies are respected.

## Writable Prisma engines

The image's global Prisma CLI downloads engines into a root-owned directory.
By default, the chart copies that directory into an `emptyDir` using a non-root
init container, then mounts it into ZTNet. The init container uses ZTNet's
configured image (including registry, tag/digest and pull policy) and the shared
`containerSecurityContext`. User-supplied `initContainers`, `extraVolumes` and
`extraVolumeMounts` remain available alongside the built-in resources.

```yaml
ztnet:
  prismaEngines:
    enabled: true
    path: /usr/local/lib/node_modules/prisma/node_modules/@prisma/engines
```

Disable `ztnet.prismaEngines.enabled` for custom images that do not need this
workaround. Reserve the name `prisma-engines` for the built-in container/volume
while it is enabled.

## Storage prerequisites

Existing controller files, including `authtoken.secret`, `identity.secret`
and `controller.d`, must be accessible to UID 1001. Provisioned volumes must
be writable by UID/GID 1001. For NFS, configure server-side UID/GID mappings and
permissions if the CSI driver does not apply fsGroup. The chart does not use a
root container to change ownership or make private keys world-readable.

ZTNet uses a writable root filesystem for its `.env` and Next.js files.
Changing its UID or enabling a read-only root filesystem requires a compatible
custom image and appropriate writable mounts.

# accounts

Service accounts, cluster RBAC, and optional long-lived API tokens.
No dependencies or workload resources.

```yaml
accounts:
  mixa3607:
    namespace: kube-system
    labels:
      owner: mixa3607
    annotations:
      description: "Personal admin account"
    clusterRole:
      existingName: cluster-admin
    token:
      enabled: true
  observer:
    clusterRole:
      rules:
        - apiGroups: [""]
          resources: ["pods", "pods/log", "services", "events"]
          verbs: ["get", "list", "watch"]
    token:
      enabled: false
```

- The account key is the ServiceAccount name (a DNS label, up to 63 characters).
- `namespace` defaults to the release namespace. Additional namespaces must
  already exist; the chart does not create them.
- Optional `labels` and `annotations` maps apply only to the ServiceAccount.
  Values must be strings. Custom labels override chart labels with the same key.
- Exactly one of `clusterRole.existingName` or `clusterRole.rules` is required.
  The binding always applies across the cluster; the account namespace does
  not limit the scope of its permissions.
- The ClusterRole (when using `rules`) and ClusterRoleBinding are named
  `<release-namespace>-<release>-<account>`.
- Setting `token.enabled: true` creates a Secret named `<release>-<account>-token`
  in the account namespace. No long-lived token is created by default.
- `automountServiceAccountToken: false` disables automatic token mounting in
  pods but does not prevent API token issuance.

The Secret declares its type and ServiceAccount annotation without token data.
The Kubernetes controller populates `data` asynchronously; Helm neither generates
the token nor stores it in values. A normal upgrade does not recreate the Secret
or rotate the token. Removing an account or disabling `token.enabled` causes Helm
to delete the Secret. The `helm.sh/resource-policy: keep` annotation is not used.

Changing `existingName` or switching between an existing role and a chart-managed
role requires recreating the ClusterRoleBinding because `roleRef` is immutable.
Updating `rules` in a chart-managed role does not require recreating the binding.

## Exporting a kubeconfig

Use `export-kubeconfig.py` with Python 3 and kubectl:

```bash
python3 ./helm-charts/charts/accounts/export-kubeconfig.py mixa3607 ~/.kube/mixa3607.json
python3 ./helm-charts/charts/accounts/export-kubeconfig.py mixa3607 - --duration=1h
```

By default, the script reads the account's persistent token Secret. With
`--duration`, it calls `kubectl create token` to issue a new JWT through the
TokenRequest API instead. This requires `create` permission on
`serviceaccounts/token`; no token Secret is required. The server determines
the actual lifetime, and the exported token is not refreshed automatically.
Duration is passed directly to kubectl (for example, `1h`, `24h`, or `0` for
the server default). Existing persistent tokens are unaffected.

`--kubeconfig` and `--context` select the source credentials for either mode.
`--namespace` selects the account namespace (default: `kube-system`).
`--release` selects the Secret name prefix (default: `accounts`) and is ignored
with `--duration`. Connection and TLS settings are copied from the source context.
Use `-` as the output path for JSON on stdout. File output uses mode `0600`
and refuses to overwrite existing files.

Validation:

```bash
helm lint ./helm-charts/charts/accounts
helm template accounts ./helm-charts/charts/accounts -n kube-system \
  -f kube/kube-system/accounts/values.yaml
```

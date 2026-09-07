#!/usr/bin/env python3
"""Export a kubeconfig using a stored token or issue a JWT with --duration."""

import argparse
import base64
import json
import os
from pathlib import Path
import subprocess
import sys


def kubectl_json(args, command):
    invocation = ["kubectl"]
    if args.kubeconfig:
        invocation += ["--kubeconfig", args.kubeconfig]
    if args.context:
        invocation += ["--context", args.context]
    # Do not echo command output/errors: responses may contain credentials.
    result = subprocess.run(
        invocation + command, capture_output=True, text=True, check=False
    )
    if result.returncode:
        raise ValueError("kubectl failed; check source context, connection and permissions")
    return json.loads(result.stdout)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("account", help="ServiceAccount name from values.yaml")
    parser.add_argument("output", type=Path, help="new kubeconfig file (must not exist), or - for stdout")
    parser.add_argument("--namespace", default="kube-system", help="account namespace")
    parser.add_argument("--release", default="accounts", help="Helm release name (Secret mode only)")
    parser.add_argument("--duration", help="issue a new token with the requested lifetime (e.g. 1h) instead of reading a Secret")
    parser.add_argument("--kubeconfig", help="source admin kubeconfig")
    parser.add_argument("--context", help="source context (default: current)")
    args = parser.parse_args()
    to_stdout = args.output == Path("-")
    if not to_stdout and (args.output.exists() or args.output.is_symlink()):
        parser.error("output already exists; choose a new file")

    try:
        source = kubectl_json(args, ["config", "view", "--minify", "--flatten", "--raw", "-o", "json"])
        cluster = source["clusters"][0]["cluster"]
        # Copy connection/TLS settings, never source user credentials.
        cluster = {key: value for key, value in cluster.items() if key in (
            "server", "certificate-authority-data", "tls-server-name", "proxy-url",
            "disable-compression", "insecure-skip-tls-verify",
        )}
        if cluster.get("insecure-skip-tls-verify"):
            raise ValueError("source disables TLS verification; configure a trusted server CA first")
        if args.duration is not None:
            response = kubectl_json(args, [
                "-n", args.namespace, "create", "token", args.account,
                f"--duration={args.duration}", "-o", "json",
            ])
            token = response.get("status", {}).get("token")
        else:
            secret = kubectl_json(args, [
                "-n", args.namespace, "get", "secret",
                f"{args.release}-{args.account}-token", "-o", "json",
            ])
            if (secret.get("type") != "kubernetes.io/service-account-token" or
                    secret["metadata"].get("annotations", {}).get(
                        "kubernetes.io/service-account.name") != args.account):
                raise ValueError("secret does not belong to the requested service account")
            encoded = secret.get("data", {}).get("token")
            if not encoded:
                raise ValueError("token is not populated yet; retry after the controller fills the Secret")
            token = base64.b64decode(encoded, validate=True).decode("utf-8")
        if not token:
            raise ValueError("token is empty")
        context_name = f"{source['contexts'][0]['name']}-{args.account}"
        config = {
            "apiVersion": "v1", "kind": "Config",
            "clusters": [{"name": "cluster", "cluster": cluster}],
            "users": [{"name": args.account, "user": {"token": token}}],
            "contexts": [{"name": context_name, "context": {
                "cluster": "cluster", "user": args.account, "namespace": args.namespace,
            }}],
            "current-context": context_name,
        }
        if to_stdout:
            json.dump(config, sys.stdout, indent=2)
            sys.stdout.write("\n")
        else:
            # O_EXCL also prevents overwriting a file created since the initial check.
            fd = os.open(args.output, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
            with os.fdopen(fd, "w") as output:
                json.dump(config, output, indent=2)
                output.write("\n")
    except (OSError, ValueError, KeyError, IndexError):
        print("Export failed: check the source kubeconfig, permissions, duration or Secret readiness, TLS settings and output path.", file=sys.stderr)
        return 1
    if not to_stdout:
        print(f"Kubeconfig written to {args.output}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

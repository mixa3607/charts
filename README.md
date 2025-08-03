# Helm Library for Kubernetes
![ci](https://img.shields.io/github/actions/workflow/status/mixa3607/charts/push-master.yaml?branch=master&style=flat-square)
![license](https://img.shields.io/github/license/mixa3607/charts?style=flat-square)

## TL;DR

```console
helm install my-release oci://ghcr.io/mixa3607/charts/<chart>
```

## Before you begin

### Prerequisites

- Kubernetes 1.30+
- Helm 3.8.0+

### Setup a Kubernetes Cluster

[k3s](https://github.com/k3s-io/k3s/)

### Install Helm

Helm is a tool for managing Kubernetes charts. Charts are packages of pre-configured Kubernetes resources.

To install Helm, refer to the [Helm install guide](https://github.com/helm/helm#install) and ensure that the `helm` binary is in the `PATH` of your shell.

### Using Helm

Once you have installed the Helm client, you can deploy a Bitnami Helm Chart into a Kubernetes cluster.

Please refer to the [Quick Start guide](https://helm.sh/docs/intro/quickstart/) if you wish to get running in just a few commands, otherwise, the [Using Helm Guide](https://helm.sh/docs/intro/using_helm/) provides detailed instructions on how to use the Helm client to manage packages on your Kubernetes cluster.

Useful Helm Client Commands:

- Install a chart: `helm install my-release oci://ghcr.io/mixa3607/charts/<chart>`
- Upgrade your application: `helm upgrade my-release oci://ghcr.io/mixa3607/charts/<chart>`

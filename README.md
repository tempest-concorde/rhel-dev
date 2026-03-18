# rhel-dev

Custom RHEL 10 bootc development image with ISO and qcow2 output for amd64 and arm64.

## About

This repo is a **reference implementation** meant to be forked.
The Quay repository (`quay.io/rh-ee-chbutler/rhel-dev`) is private — you cannot pull pre-built images.
Fork this repo and point it at your own registry to build your own image.

## What's included

Base: `registry.redhat.io/rhel10/rhel-bootc`

- **dnf packages**: Go, Java 21, Maven, podman, skopeo, butane, coreos-installer, Tailscale, yq, jq, dnsmasq, firewalld, and more
- **CLI tools**: `oc`, `oc-mirror`, `openshift-install` (4.18–4.21), `direnv`, `gomplate`, `cosign`, `argocd`
- **Multi-arch**: amd64 and arm64 builds via CI

## Forking and adapting

1. **Fork** this repo.

1. **Create your own Quay.io repository** (or any OCI registry).

1. **Update CI workflow references** — in `.github/workflows/build-release.yml` (and `pr.yaml`, `create-release.yml`), change `REGISTRY_USER` and `IMAGE_REGISTRY` to match your registry:

   ```yaml
   env:
     REGISTRY_USER: your-username
     IMAGE_REGISTRY: quay.io
   ```

1. **Set up GitHub Actions secrets** for your registry: `REGISTRY_USER`, `REGISTRY_PASSWORD`, `RH_REGISTRY_USER`, `RH_REGISTRY_PASSWORD`.

1. **Customize the `Containerfile`** — add or remove packages and tools.

1. **Update `versions.env`** — set the tool versions you want.

1. **Update `config.toml.tmpl`** — adjust installer preferences (user, SSH key, partitions).

1. **Update the `Makefile`** — replace `quay.io/rh-ee-chbutler/rhel-dev` with your image reference in the `iso`, `qcow`, and `verify` targets.

## Local usage

### Prerequisites

- podman (not Docker)
- Must run as root

### Environment variables

Set these before building:

```shell
export SSH_KEY_PATH=$HOME/.ssh/id_rsa.pub
export DOCKER_AUTH_PATH=$(pwd)/docker-auth.json
export PASSWORD_HASH='' # openssl passwd -6 (use single quotes)
export USERNAME=myusername
```

### Build

```shell
# Build an ISO installer
make iso

# Build a qcow2 VM image
make qcow
```

`make iso` / `make qcow` will download dependencies and render the config template automatically.

## Notes

1. Root users don't cache credentials for podman in RHEL. Rebooting will require re-authenticating with `quay.io` and `registry.redhat.io`.
1. Don't try to add more than one group to a user using `--groups`.
1. It's much easier if you build as root and don't use sudo.

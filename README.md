# rhel-dev

Custom RHEL 10 bootc container image for development machines.
Builds ISO installers or qcow2 VM images targeting both amd64 and arm64 (e.g. UTM on macOS).

## Why

- On macOS using UTM or similar, qcow images are painful to set up manually. An ISO installer is much easier.
- ISO simulates edge deployment requirements.

## What's included

Base: `registry.redhat.io/rhel10/rhel-bootc`

Development tools installed via dnf: Go, Java 21, Maven, podman, buildah, skopeo, and more.

Additional binaries copied into the image:

- `oc` and `oc-mirror` (OpenShift CLI)
- `openshift-install` (4.18, 4.19, 4.20)
- `direnv`
- `gomplate`
- `cosign`

## Usage

### Prerequisites

- podman (not Docker)
- Builds must run as root

### Environment variables

Set these before building (use `direnv` or similar):

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
2. Don't try to add more than one group to a user using `--groups`.
3. It's much easier if you build as root and don't use sudo.

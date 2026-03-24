# rhel-dev

Custom RHEL 10 bootc development image with ISO and qcow2 output for amd64 and arm64.

## About

This repo is a **reference implementation** meant to be forked.
The Quay repository (`quay.io/rh-ee-chbutler/rhel-dev`) is private — you cannot pull pre-built images.
Fork this repo and point it at your own registry to build your own image.

## What's included

Base: `registry.redhat.io/rhel10/rhel-bootc`

- **dnf packages**: Go, podman, skopeo, butane, coreos-installer, Tailscale, yq, jq, dnsmasq, firewalld, and more
- **CLI tools**: `oc`, `oc-mirror`, `openshift-install` (4.20–4.21), `direnv`, `gomplate`, `cosign`, `argocd`
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

1. **Set up GitHub Actions secrets** for your registry:
   - `REGISTRY_USER`, `REGISTRY_PASSWORD` — your OCI registry credentials
   - `RH_REGISTRY_USER`, `RH_REGISTRY_PASSWORD` — Red Hat registry credentials
   - `RHT_ORGID`, `RHT_ACT_KEY` — Red Hat subscription activation key
   - `COSIGN_PRIVATE_KEY`, `COSIGN_PASSWORD` — cosign signing key (see below)
   - `FG_PAT` — GitHub PAT for semantic release

1. **Generate signing keys**:
   - **Cosign**: `cosign generate-key-pair` — commit `cosign.pub` to `containers-policy/`, add `COSIGN_PRIVATE_KEY` and `COSIGN_PASSWORD` as secrets

1. **Update signing policy** — in `containers-policy/policy.json` and `containers-policy/quay.io-rhel-dev.yaml`, replace the registry path with your own.

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

## Image signing

Released images are signed with [cosign](https://github.com/sigstore/cosign) using key-based signing (not keyless/Fulcio). This is because the `containers/image` library used by `bootc switch` and `podman pull` does not support Fulcio's `subjectRegexp` field.

### Verify locally

```shell
make verify
```

### SELinux policy lockdown

Container signing policy (`/etc/containers/policy.json`) is protected by a custom SELinux type (`secure_container_policy_t`) that denies write access to all domains including root. Trust assets (cosign public key, registry config) are placed in read-only `/usr/share/` paths where bootc/ostree prevents modification.

At boot, a systemd oneshot service sets `secure_mode_policyload=1`, which prevents loading new SELinux policy modules or changing SELinux booleans/mode. Kernel args `selinux=1 enforcing=1` are set via `/usr/lib/bootc/kargs.d/` (read-only `/usr`).

### Optional GRUB password (experimental)

To prevent `selinux=0` kernel argument tampering at the GRUB menu, set a GRUB password before building the ISO:

```shell
# Generate a PBKDF2 password hash
grub2-mkpasswd-pbkdf2

# Set the hash before building
export GRUB_PASSWORD_HASH='grub.pbkdf2.sha512.10000.…'
make iso
```

This uses `grub2-setpassword` in the kickstart `%post`. Since bootupd manages `/boot`, this may be fragile across `bootc upgrade`.

## Notes

1. Root users don't cache credentials for podman in RHEL. Rebooting will require re-authenticating with `quay.io` and `registry.redhat.io`.
1. Don't try to add more than one group to a user using `--groups`.
1. It's much easier if you build as root and don't use sudo.

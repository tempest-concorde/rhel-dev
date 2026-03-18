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

## Image signing

Released images are signed with [cosign](https://github.com/sigstore/cosign) using key-based signing (not keyless/Fulcio). This is because the `containers/image` library used by `bootc switch` and `podman pull` does not support Fulcio's `subjectRegexp` field.

### Verify locally

```shell
make verify
```

### IMA file integrity enforcement

Policy files in the image (`/etc/containers/policy.json`, `/etc/pki/sigstore/cosign.pub`, registry config, `/etc/ima/ima-policy`) are signed at build time with IMA (`evmctl ima_sign`). With `ima_appraise=enforce` in the kernel args, the kernel denies access to any file whose IMA signature is invalid. This prevents local modification of the container signing policy on the writable `/etc` filesystem.

The IMA appraisal policy (`appraise fowner=0 appraise_type=imasig`) only enforces files that have IMA signatures — unsigned files are unaffected.

### MOK enrollment (ISO installs)

The IMA public key certificate must be enrolled in MOK (Machine Owner Key) so dracut can load it onto the kernel `.ima` keyring at boot.

For ISO installs with console access:
1. Set `export ENROLL_IMA_MOK=true` before `make iso`
2. On first reboot after install, MokManager appears — use root password to enroll the IMA key
3. After enrollment, verify with `mokutil --test-key /etc/keys/ima/ima-cert.der`

For headless/cloud deployments: MOK enrollment requires console access. Either arrange console access or disable Secure Boot.

### Fork instructions

If you fork this project, you need your own signing keys:

1. **Cosign keypair**: `cosign generate-key-pair` — commit `cosign.pub` to `containers-policy/`, add `COSIGN_PRIVATE_KEY` and `COSIGN_PASSWORD` as GitHub Actions secrets
2. **IMA keypair**: Generate RSA key and X.509 cert:
   ```shell
   openssl genrsa -out ima-private.pem 2048
   openssl req -new -x509 -key ima-private.pem -out ima/ima-cert.der -outform DER -days 3650 -subj "/CN=your-project IMA signing key"
   ```
   Commit `ima/ima-cert.der`, add `IMA_PRIVATE_KEY` (contents of `ima-private.pem`) as a GitHub Actions secret
3. Update `policy.json` and `quay.io-rhel-dev.yaml` with your registry path

## Notes

1. Root users don't cache credentials for podman in RHEL. Rebooting will require re-authenticating with `quay.io` and `registry.redhat.io`.
1. Don't try to add more than one group to a user using `--groups`.
1. It's much easier if you build as root and don't use sudo.

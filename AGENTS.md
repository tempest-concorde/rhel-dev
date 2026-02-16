# AGENTS.md

This file provides guidance to AI coding agents working in this repository.

## Project Overview

rhel-dev builds a custom RHEL 10 bootc container image for development machines, targeting both amd64 and arm64 deployments via UTM/qcow on macOS. The Containerfile extends `registry.redhat.io/rhel10/rhel-bootc` with development tools (Go, Java 21, Maven, podman, oc, direnv, etc.) and uses `bootc-image-builder` to produce ISO installers or qcow2 VM images.

## Build Commands

```shell
# Download all required binaries (direnv, openshift-install, oc, oc-mirror, gomplate, cosign, argocd, butane)
make get-deps

# Generate config.toml from template (requires env vars set, see below)
make toml

# Build ISO installer image (runs toml + get-deps first)
make iso

# Build qcow2 VM image (runs toml + get-deps first)
make qcow

# Install gomplate to local Go environment
make dev
```

Individual binary targets: `get-direnv`, `get-openshift-install-4{18..21}` (dynamically generated), `get-oc`, `get-oc-mirror`, `get-gomplate`, `get-cosign`, `get-argocd`, `get-butane`.

## Required Environment Variables

Set these before running `make iso` or `make qcow` (use direnv):

- `SSH_KEY_PATH` — path to SSH public key (e.g. `~/.ssh/id_rsa.pub`)
- `DOCKER_AUTH_PATH` — path to docker-auth.json for container registry auth
- `PASSWORD_HASH` — output of `openssl passwd -6` (use single quotes)
- `USERNAME` — username for the VM login

These are interpolated into `config.toml` via gomplate templating of `config.toml.tmpl`.

## Architecture

This is an infrastructure-as-code project with no application source code. The key files are:

- **versions.env** — single source of truth for OCP version range and tool versions; consumed by Makefile via `include`
- **Containerfile** — defines the bootc image: base RHEL 10, dnf packages (including coreos-installer), binary tools copied from the build context, and `update-alternatives` for openshift-install version switching
- **Makefile** — orchestrates binary downloads (architecture-aware: amd64/arm64) and image builds via podman + bootc-image-builder; uses `define`/`foreach`/`eval` to dynamically generate openshift-install targets from `versions.env`
- **config.toml.tmpl** — gomplate template producing Kickstart config for ISO/qcow2 builds (user, SSH keys, registry auth)
- **direnv.sh** — shell hook copied into the image at `/etc/profile.d/`

Build flow: `make get-deps` downloads binaries → `make toml` renders config → `make iso`/`make qcow` builds container image then runs bootc-image-builder to produce output artifacts in `./output/`.

## CI/CD

GitHub Actions workflows in `.github/workflows/`:

- **pr.yaml** — builds on PRs to main (multi-arch: amd64 + arm64), no push
- **create-release.yml** — on push to main, runs python-semantic-release to auto-version
- **build-release.yml** — on version tags (v*), multi-arch build + push to `quay.io/rh-ee-chbutler/rhel-dev`, signs with cosign
- **commitlint.yml** — validates PR titles against conventional commits

## Conventions

- **Conventional commits** required (enforced by commitlint): `feat:`, `fix:`, `chore:`, etc.
- **Pre-commit hooks**: merge conflict checks, YAML validation, no direct commits to main, mdformat for markdown
- **Semantic versioning** via python-semantic-release (auto-generates CHANGELOG.md)
- Container images are signed with cosign (keyless/OIDC)
- Builds require podman (not Docker) and must run as root

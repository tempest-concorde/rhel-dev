#!/usr/bin/env bash
set -euo pipefail

QUAY_IMAGE="quay.io/rh-ee-chbutler/rhel-dev:latest"
BUILDER_IMAGE="registry.redhat.io/rhel10/bootc-image-builder:latest"

die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "==> $*"; }

# ---- Preflight ----

[[ "$(id -u)" -ne 0 ]] || die "Do not run as root. The script uses sudo only where needed."

[[ -f config.toml.tmpl ]] || die "Run this from the repo root (config.toml.tmpl not found)."

command -v gomplate >/dev/null || die "gomplate not found on PATH."
command -v podman >/dev/null || die "podman not found on PATH."
command -v jq >/dev/null || die "jq not found on PATH."

for var in USERNAME PASSWORD_HASH SSH_KEY_PATH DOCKER_AUTH_PATH; do
    [[ -n "${!var:-}" ]] || die "$var is not set. Check your .envrc and run 'direnv allow'."
done

if [[ "$DOCKER_AUTH_PATH" == /run/containers/* ]]; then
    die "DOCKER_AUTH_PATH points to a CI-only path ($DOCKER_AUTH_PATH).
Update your .envrc:
  export DOCKER_AUTH_PATH=\$(pwd)/docker-auth.json

Then create the auth file:
  podman login --authfile \$(pwd)/docker-auth.json quay.io
  podman login --authfile \$(pwd)/docker-auth.json registry.redhat.io
  direnv allow"
fi

[[ -f "$SSH_KEY_PATH" ]] || die "SSH_KEY_PATH file not found: $SSH_KEY_PATH"

[[ -f "$DOCKER_AUTH_PATH" ]] || die "DOCKER_AUTH_PATH file not found: $DOCKER_AUTH_PATH
Create it with:
  podman login --authfile $DOCKER_AUTH_PATH quay.io
  podman login --authfile $DOCKER_AUTH_PATH registry.redhat.io"

for registry in quay.io registry.redhat.io; do
    jq -e ".auths[\"$registry\"]" "$DOCKER_AUTH_PATH" >/dev/null 2>&1 \
        || die "No credentials for $registry in $DOCKER_AUTH_PATH
Run: podman login --authfile $DOCKER_AUTH_PATH $registry"
done

AUTH_FILE="$(realpath "$DOCKER_AUTH_PATH")"

info "Preflight checks passed"

# ---- Fix ownership from previous root builds ----

info "Fixing file ownership"
sudo chown -R "$(id -u):$(id -g)" .
sudo rm -rf output

# ---- Update repo ----

info "Updating repo to latest main"
git fetch origin main
git reset --hard origin/main

# ---- Render config.toml ----

info "Rendering config.toml"
gomplate -f config.toml.tmpl -o config.toml

# ---- Pull images ----

info "Pulling $QUAY_IMAGE"
sudo podman pull --authfile "$AUTH_FILE" "$QUAY_IMAGE"

info "Pulling $BUILDER_IMAGE"
sudo podman pull --authfile "$AUTH_FILE" "$BUILDER_IMAGE"

# ---- Build ISO ----

mkdir -p output

TTY_FLAG=""
[[ -t 0 ]] && TTY_FLAG="-t"

info "Building ISO (this will take a while)"
sudo podman run \
    --rm $TTY_FLAG \
    --privileged \
    --security-opt label=type:unconfined_t \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    -v "$(pwd)/config.toml:/config.toml:ro" \
    -v "$(pwd)/output:/output" \
    "$BUILDER_IMAGE" \
    --type iso \
    "$QUAY_IMAGE"

# ---- Fix output ownership ----

sudo chown -R "$(id -u):$(id -g)" output/

info "ISO build complete:"
find output -type f -exec ls -lh {} \;

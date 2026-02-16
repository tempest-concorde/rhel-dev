FROM registry.redhat.io/rhel10/rhel-bootc@sha256:612eebb0ad918e2dd2e265e2cb9f6d75e684471600711ea615752e6c41130140

RUN dnf group install -y "Minimal Install" && dnf clean all
RUN dnf config-manager --add-repo https://pkgs.tailscale.com/stable/centos/10/tailscale.repo


RUN dnf install -y \
    qemu-guest-agent \
    podman \
    skopeo \
    git \
    vim \
    make \
    vim-enhanced \
    go \
    java-21-openjdk \
    tailscale \
    java-21-openjdk-devel \
    maven \
    coreos-installer && \
    dnf clean all

COPY direnv /usr/local/bin/direnv
RUN chmod +x /usr/local/bin/direnv

# Direnv shell hook for login shells
COPY direnv.sh /etc/profile.d/direnv.sh

# OpenShift install binaries with alternatives for version switching
COPY openshift-install-4* /usr/local/bin/
RUN chmod +x /usr/local/bin/openshift-install-4* && \
    for bin in /usr/local/bin/openshift-install-4*; do \
        ver=$(basename "$bin" | sed 's/openshift-install-//'); \
        update-alternatives --install /usr/bin/openshift-install openshift-install "$bin" "${ver##4}"; \
    done

# OC and kubectl
COPY oc /usr/local/bin/oc
COPY kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/oc /usr/local/bin/kubectl

# oc-mirror v2
COPY oc-mirror /usr/local/bin/oc-mirror
RUN chmod +x /usr/local/bin/oc-mirror

# Gomplate
COPY gomplate /usr/local/bin/gomplate
RUN chmod +x /usr/local/bin/gomplate

# Cosign
COPY cosign /usr/local/bin/cosign
RUN chmod +x /usr/local/bin/cosign

# ArgoCD CLI
COPY argocd /usr/local/bin/argocd
RUN chmod +x /usr/local/bin/argocd

# Butane (Fedora CoreOS config transpiler)
COPY butane /usr/local/bin/butane
RUN chmod +x /usr/local/bin/butane

RUN bootc container lint

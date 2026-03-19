FROM registry.redhat.io/rhel10/rhel-bootc@sha256:612eebb0ad918e2dd2e265e2cb9f6d75e684471600711ea615752e6c41130140

RUN dnf group install -y "Minimal Install" && dnf clean all
RUN dnf config-manager --add-repo https://pkgs.tailscale.com/stable/centos/10/tailscale.repo
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm

RUN dnf install -y \
    butane \
    coreos-installer \
    git \
    go \
    java-21-openjdk \
    java-21-openjdk-devel \
    make \
    maven \
    podman \
    python3 \
    python3-pip \
    qemu-guest-agent \
    skopeo \
    tailscale \
    vim \
    vim-enhanced \
    yq && \
    dnf clean all

# Bastion infrastructure services
RUN dnf install -y \
    bash-completion \
    chrony \
    dnsmasq \
    firewalld \
    jq \
    python3-cryptography \
    python3-firewall && \
    dnf clean all

# Python packages for Ansible modules (htpasswd support)
RUN pip3 install passlib

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

# Sudoers NOPASSWD for cloud-user (default VM provisioning user)
RUN echo "cloud-user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/cloud-user && \
    chmod 440 /etc/sudoers.d/cloud-user

# Bash completions for OCP tools
RUN mkdir -p /etc/bash_completion.d && \
    /usr/local/bin/oc completion bash > /etc/bash_completion.d/oc && \
    /usr/local/bin/kubectl completion bash > /etc/bash_completion.d/kubectl && \
    /usr/local/bin/argocd completion bash > /etc/bash_completion.d/argocd

# IMA tools
RUN dnf install -y ima-evm-utils && dnf clean all

# Cosign public key for image signature verification
COPY containers-policy/cosign.pub /etc/pki/sigstore/cosign.pub

# Container image signature verification policy
COPY containers-policy/policy.json /etc/containers/policy.json
COPY containers-policy/quay.io-rhel-dev.yaml /etc/containers/registries.d/quay.io-rhel-dev.yaml

# IMA public key certificate (loaded onto .ima keyring at boot by dracut)
RUN mkdir -p /etc/keys/ima
COPY ima/ima-cert.der /etc/keys/ima/ima-cert.der

# Custom IMA appraisal policy (appraise only files with IMA signatures)
RUN mkdir -p /etc/ima
COPY ima/ima-appraise-signed.policy /etc/ima/ima-policy

# IMA sign policy files (private key from build secret)
RUN --mount=type=secret,id=ima_private_key \
    evmctl ima_sign --key /run/secrets/ima_private_key /etc/containers/policy.json && \
    evmctl ima_sign --key /run/secrets/ima_private_key /etc/pki/sigstore/cosign.pub && \
    evmctl ima_sign --key /run/secrets/ima_private_key /etc/containers/registries.d/quay.io-rhel-dev.yaml && \
    evmctl ima_sign --key /run/secrets/ima_private_key /etc/ima/ima-policy

# Dracut: include integrity module for IMA key loading at boot
COPY dracut/50-integrity.conf /usr/lib/dracut/dracut.conf.d/50-integrity.conf

# Kernel args for IMA and SELinux enforcement
RUN mkdir -p /usr/lib/bootc/kargs.d
COPY kargs.d/ /usr/lib/bootc/kargs.d/

# Regenerate initramfs with integrity module
RUN set -x; kver=$(cd /usr/lib/modules && echo *); dracut -vf /usr/lib/modules/$kver/initramfs.img $kver

RUN bootc container lint

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

# SELinux policy development tools (compile module, then remove)
RUN dnf install -y selinux-policy-devel && dnf clean all

# Trust assets in /usr (read-only on bootc)
RUN mkdir -p /usr/share/pki/sigstore
COPY containers-policy/cosign.pub /usr/share/pki/sigstore/cosign.pub
RUN mkdir -p /usr/share/containers/registries.d
COPY containers-policy/quay.io-rhel-dev.yaml /usr/share/containers/registries.d/quay.io-rhel-dev.yaml

# Container image signature verification policy (protected by SELinux)
COPY containers-policy/policy.json /etc/containers/policy.json

# Compile and install custom SELinux policy module
COPY selinux/container_lockdown.te selinux/container_lockdown.fc /tmp/selinux/
RUN cd /tmp/selinux && \
    make -f /usr/share/selinux/devel/Makefile container_lockdown.pp && \
    semodule -i container_lockdown.pp && \
    rm -rf /tmp/selinux

# Restore file contexts for protected files
RUN restorecon -v /etc/containers/policy.json /etc/selinux/config

# SELinux lockdown service (sets secure_mode_policyload=1 early in boot)
COPY selinux/selinux-lockdown.service /usr/lib/systemd/system/selinux-lockdown.service
RUN systemctl enable selinux-lockdown.service

# Kernel args for SELinux enforcement (read-only /usr on bootc)
RUN mkdir -p /usr/lib/bootc/kargs.d
COPY kargs.d/01-selinux.toml /usr/lib/bootc/kargs.d/01-selinux.toml

RUN bootc container lint

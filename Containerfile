FROM registry.redhat.io/rhel10/rhel-bootc@sha256:612eebb0ad918e2dd2e265e2cb9f6d75e684471600711ea615752e6c41130140

# Consolidated package install: repos + all packages (single dnf layer)
RUN dnf group install -y "Minimal Install" && \
    dnf config-manager --add-repo https://pkgs.tailscale.com/stable/centos/10/tailscale.repo && \
    dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm && \
    dnf install -y \
        bash-completion \
        butane \
        chrony \
        coreos-installer \
        dnsmasq \
        firewalld \
        git \
        go \
        java-21-openjdk \
        java-21-openjdk-devel \
        jq \
        make \
        maven \
        openscap-scanner \
        podman \
        python3 \
        python3-cryptography \
        python3-firewall \
        python3-passlib \
        qemu-guest-agent \
        scap-security-guide \
        selinux-policy-devel \
        skopeo \
        tailscale \
        vim \
        vim-enhanced \
        yq && \
    dnf config-manager --set-disabled epel && \
    dnf clean all

# Apply CIS baseline hardening (remediate then override with our customizations)
# oscap returns non-zero when rules can't be applied, which is expected
RUN oscap xccdf eval --remediate \
        --profile xccdf_org.ssgproject.content_profile_cis \
        /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml ; \
    true

# DEFAULT crypto policy includes PQC (ML-KEM, ML-DSA) in RHEL 10.1+
RUN update-crypto-policies --set DEFAULT

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

# Bash completions for OCP tools
RUN mkdir -p /etc/bash_completion.d && \
    /usr/local/bin/oc completion bash > /etc/bash_completion.d/oc && \
    /usr/local/bin/kubectl completion bash > /etc/bash_completion.d/kubectl && \
    /usr/local/bin/argocd completion bash > /etc/bash_completion.d/argocd

# Trust assets in /usr (read-only on bootc)
RUN mkdir -p /usr/share/pki/sigstore
COPY containers-policy/cosign.pub /usr/share/pki/sigstore/cosign.pub
COPY containers-policy/quay.io-rhel-dev.yaml /etc/containers/registries.d/quay.io-rhel-dev.yaml

# Container image signature verification policy (protected by SELinux)
COPY containers-policy/policy.json /etc/containers/policy.json

# Compile and install custom SELinux policy module
COPY selinux/container_lockdown.te selinux/container_lockdown.fc /tmp/selinux/
RUN cd /tmp/selinux && \
    make -f /usr/share/selinux/devel/Makefile container_lockdown.pp && \
    semodule -i container_lockdown.pp && \
    rm -rf /tmp/selinux

# SELinux lockdown service (sets secure_mode_policyload and secure_mode_insmod at boot)
COPY selinux/selinux-lockdown.service /usr/lib/systemd/system/selinux-lockdown.service
RUN systemctl enable selinux-lockdown.service

# Restore file contexts for protected files
RUN restorecon -v /etc/containers/policy.json /etc/selinux/config /usr/lib/systemd/system/selinux-lockdown.service /etc/containers/registries.d/quay.io-rhel-dev.yaml

# Kernel args for SELinux enforcement (read-only /usr on bootc)
RUN mkdir -p /usr/lib/bootc/kargs.d
COPY kargs.d/01-selinux.toml /usr/lib/bootc/kargs.d/01-selinux.toml

RUN bootc container lint

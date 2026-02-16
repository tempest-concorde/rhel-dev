FROM registry.redhat.io/rhel10/rhel-bootc@sha256:612eebb0ad918e2dd2e265e2cb9f6d75e684471600711ea615752e6c41130140
# Install EPEL for RHEL 10

RUN dnf groupinstall -y "Server with GUI" && dnf clean all 
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
    maven && \
    dnf clean all

COPY direnv /usr/local/bin/direnv
RUN chmod +x /usr/local/bin/direnv

# Direnv shell hook for login shells
COPY direnv.sh /etc/profile.d/direnv.sh

# OpenShift install binaries
COPY openshift-install-418 /usr/local/bin/openshift-install-418
COPY openshift-install-419 /usr/local/bin/openshift-install-419
COPY openshift-install-420 /usr/local/bin/openshift-install-420
RUN chmod +x /usr/local/bin/openshift-install-*

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

RUN bootc container lint

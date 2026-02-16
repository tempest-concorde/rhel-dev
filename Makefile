# Architecture detection for multi-arch builds
UNAME_ARCH := $(shell uname -m)
ifeq ($(UNAME_ARCH),x86_64)
    BINARY_ARCH := amd64
else ifeq ($(UNAME_ARCH),aarch64)
    BINARY_ARCH := arm64
else
    BINARY_ARCH := $(UNAME_ARCH)
endif

include versions.env

# Dynamic OpenShift installer targets
OCP_VERSIONS := $(shell seq $(OCP_VERSION_MIN) $(OCP_VERSION_MAX))

define ocp-install-target
get-openshift-install-4$(1):
	wget https://mirror.openshift.com/pub/openshift-v4/multi/clients/ocp/stable-4.$(1)/$$(BINARY_ARCH)/openshift-install-linux.tar.gz -O openshift-install-4$(1).tar.gz
	tar -xzf openshift-install-4$(1).tar.gz openshift-install
	mv openshift-install openshift-install-4$(1)
	rm openshift-install-4$(1).tar.gz
endef

$(foreach ver,$(OCP_VERSIONS),$(eval $(call ocp-install-target,$(ver))))

OCP_TARGETS := $(foreach ver,$(OCP_VERSIONS),get-openshift-install-4$(ver))

get_vma:
	echo "Not implemented"
	# wget https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v1.115.0/vmutils-linux-$(BINARY_ARCH)-v1.115.0.tar.gz -O vmutils.tar.gz
	# tar -xvzf ./vmutils.tar.gz
	# mv vmagent-prod vmagent
	# rm *-prod vmutils.tar.gz
get_node:
	echo "Not implemented"
	# wget https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-$(BINARY_ARCH).tar.gz -O node-exporter.tar.gz
	# tar -xvzf ./node-exporter.tar.gz
	# mv node_exporter-1.9.1.linux-$(BINARY_ARCH)/node_exporter node_exporter
	# rm -r node-exporter.tar.gz node_exporter-1.9.1.linux-$(BINARY_ARCH)

get-direnv:
	wget https://github.com/direnv/direnv/releases/download/v$(DIRENV_VERSION)/direnv.linux-$(BINARY_ARCH) -O direnv

# OC and kubectl (latest stable)
get-oc:
	wget https://mirror.openshift.com/pub/openshift-v4/$(UNAME_ARCH)/clients/ocp/stable/openshift-client-linux.tar.gz -O oc.tar.gz
	tar -xzf oc.tar.gz oc kubectl
	rm oc.tar.gz

# Gomplate binary
get-gomplate:
	wget https://github.com/hairyhenderson/gomplate/releases/download/v$(GOMPLATE_VERSION)/gomplate_linux-$(BINARY_ARCH) -O gomplate
	chmod +x gomplate

# oc-mirror v2
get-oc-mirror:
	wget https://mirror.openshift.com/pub/openshift-v4/$(UNAME_ARCH)/clients/ocp/stable/oc-mirror.rhel9.tar.gz -O oc-mirror.tar.gz
	tar -xzf oc-mirror.tar.gz oc-mirror
	rm oc-mirror.tar.gz

# Cosign
get-cosign:
	wget https://github.com/sigstore/cosign/releases/download/v$(COSIGN_VERSION)/cosign-linux-$(BINARY_ARCH) -O cosign
	chmod +x cosign

# ArgoCD CLI
get-argocd:
	wget https://github.com/argoproj/argo-cd/releases/download/v$(ARGOCD_VERSION)/argocd-linux-$(BINARY_ARCH) -O argocd
	chmod +x argocd

get-deps: get-direnv $(OCP_TARGETS) get-oc get-oc-mirror get-gomplate get-cosign get-argocd


dev:
	go install github.com/hairyhenderson/gomplate/v4/cmd/gomplate@latest

toml:
	gomplate -f config.toml.tmpl -o config.toml

iso: toml get-deps
	rm -rf output
	mkdir output
	podman pull quay.io/rh-ee-chbutler/rhel-dev:latest
	podman pull registry.redhat.io/rhel10/bootc-image-builder:latest
	podman run --rm -it --privileged --pull=newer --security-opt label=type:unconfined_t -v /var/lib/containers/storage:/var/lib/containers/storage -v $(CURDIR)/config.toml:/config.toml -v $(CURDIR)/output:/output registry.redhat.io/rhel10/bootc-image-builder:latest --type iso quay.io/rh-ee-chbutler/rhel-dev:latest


qcow: toml get-deps
	rm -rf output
	mkdir output
	podman pull quay.io/rh-ee-chbutler/rhel-dev:latest
	podman pull registry.redhat.io/rhel10/bootc-image-builder:latest
	podman run \
			--rm \
			-it \
			--privileged \
			--pull=newer \
			--security-opt label=type:unconfined_t \
			-v $(CURDIR)/config.toml:/config.toml:ro \
			-v $(CURDIR)/output:/output \
			-v /var/lib/containers/storage:/var/lib/containers/storage \
			registry.redhat.io/rhel10/bootc-image-builder:latest \
			--local \
			--type qcow2 \
			quay.io/rh-ee-chbutler/rhel-dev:latest

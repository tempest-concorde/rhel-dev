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

OCP_MIRROR := https://mirror.openshift.com/pub/openshift-v4

# Dynamic OpenShift installer targets
OCP_VERSIONS := $(shell seq $(OCP_VERSION_MIN) $(OCP_VERSION_MAX))

define ocp-install-target
get-openshift-install-4$(1):
	@if [ -f openshift-install-4$(1) ]; then \
		echo "openshift-install-4$(1): cached"; \
	else \
		wget -q $(OCP_MIRROR)/multi/clients/ocp/stable-4.$(1)/$$(BINARY_ARCH)/sha256sum.txt -O oi-4$(1)-sha256sum.txt; \
		wget -q $(OCP_MIRROR)/multi/clients/ocp/stable-4.$(1)/$$(BINARY_ARCH)/openshift-install-linux.tar.gz -O openshift-install-4$(1).tar.gz; \
		grep 'openshift-install-linux.tar.gz' oi-4$(1)-sha256sum.txt | sed 's/openshift-install-linux.tar.gz/openshift-install-4$(1).tar.gz/' | sha256sum -c -; \
		tar -xzf openshift-install-4$(1).tar.gz openshift-install; \
		mv openshift-install openshift-install-4$(1); \
		rm openshift-install-4$(1).tar.gz oi-4$(1)-sha256sum.txt; \
	fi
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
	@if [ -f direnv ]; then \
		echo "direnv: cached"; \
	else \
		wget -q https://github.com/direnv/direnv/releases/download/v$(DIRENV_VERSION)/direnv.linux-$(BINARY_ARCH) -O direnv; \
		EXPECTED=$$(curl -sf "https://api.github.com/repos/direnv/direnv/releases/tags/v$(DIRENV_VERSION)" | jq -r '.assets[] | select(.name == "direnv.linux-$(BINARY_ARCH)") | .digest' | sed 's/sha256://'); \
		echo "$$EXPECTED  direnv" | sha256sum -c -; \
	fi

# OC and kubectl (latest stable)
get-oc:
	@if [ -f oc ] && [ -f kubectl ]; then \
		echo "oc/kubectl: cached"; \
	else \
		wget -q $(OCP_MIRROR)/$(UNAME_ARCH)/clients/ocp/stable/sha256sum.txt -O oc-sha256sum.txt; \
		wget -q $(OCP_MIRROR)/$(UNAME_ARCH)/clients/ocp/stable/openshift-client-linux.tar.gz -O oc.tar.gz; \
		grep 'openshift-client-linux.tar.gz' oc-sha256sum.txt | sha256sum -c -; \
		tar -xzf oc.tar.gz oc kubectl; \
		rm oc.tar.gz oc-sha256sum.txt; \
	fi

# Gomplate binary
get-gomplate:
	@if [ -f gomplate ]; then \
		echo "gomplate: cached"; \
	else \
		wget -q https://github.com/hairyhenderson/gomplate/releases/download/v$(GOMPLATE_VERSION)/gomplate_linux-$(BINARY_ARCH) -O gomplate; \
		wget -q https://github.com/hairyhenderson/gomplate/releases/download/v$(GOMPLATE_VERSION)/checksums-v$(GOMPLATE_VERSION)_sha256.txt -O gomplate-checksums.txt; \
		grep 'gomplate_linux-$(BINARY_ARCH)' gomplate-checksums.txt | sed 's/gomplate_linux-$(BINARY_ARCH)/gomplate/' | sha256sum -c -; \
		rm gomplate-checksums.txt; \
		chmod +x gomplate; \
	fi

# oc-mirror v2
get-oc-mirror:
	@if [ -f oc-mirror ]; then \
		echo "oc-mirror: cached"; \
	else \
		wget -q $(OCP_MIRROR)/$(UNAME_ARCH)/clients/ocp/stable/sha256sum.txt -O oc-mirror-sha256sum.txt; \
		wget -q $(OCP_MIRROR)/$(UNAME_ARCH)/clients/ocp/stable/oc-mirror.rhel9.tar.gz -O oc-mirror.tar.gz; \
		grep 'oc-mirror.rhel9.tar.gz' oc-mirror-sha256sum.txt | sha256sum -c -; \
		tar -xzf oc-mirror.tar.gz oc-mirror; \
		rm oc-mirror.tar.gz oc-mirror-sha256sum.txt; \
	fi

# Cosign
get-cosign:
	@if [ -f cosign ]; then \
		echo "cosign: cached"; \
	else \
		wget -q https://github.com/sigstore/cosign/releases/download/v$(COSIGN_VERSION)/cosign-linux-$(BINARY_ARCH) -O cosign; \
		wget -q https://github.com/sigstore/cosign/releases/download/v$(COSIGN_VERSION)/cosign_checksums.txt -O cosign-checksums.txt; \
		grep 'cosign-linux-$(BINARY_ARCH)$$' cosign-checksums.txt | sed 's/cosign-linux-$(BINARY_ARCH)/cosign/' | sha256sum -c -; \
		rm cosign-checksums.txt; \
		chmod +x cosign; \
	fi

# ArgoCD CLI
get-argocd:
	@if [ -f argocd ]; then \
		echo "argocd: cached"; \
	else \
		wget -q https://github.com/argoproj/argo-cd/releases/download/v$(ARGOCD_VERSION)/argocd-linux-$(BINARY_ARCH) -O argocd; \
		wget -q https://github.com/argoproj/argo-cd/releases/download/v$(ARGOCD_VERSION)/cli_checksums.txt -O argocd-checksums.txt; \
		grep 'argocd-linux-$(BINARY_ARCH)$$' argocd-checksums.txt | sed 's/argocd-linux-$(BINARY_ARCH)/argocd/' | sha256sum -c -; \
		rm argocd-checksums.txt; \
		chmod +x argocd; \
	fi

get-deps: get-direnv $(OCP_TARGETS) get-oc get-oc-mirror get-gomplate get-cosign get-argocd

verify:
	cosign verify \
		--key containers-policy/cosign.pub \
		quay.io/rh-ee-chbutler/rhel-dev:prod

dev:
	go install github.com/hairyhenderson/gomplate/v4/cmd/gomplate@latest

toml:
	gomplate -f config.toml.tmpl -o config.toml

iso: toml
	rm -rf output
	mkdir output
	podman pull quay.io/rh-ee-chbutler/rhel-dev:latest
	podman pull registry.redhat.io/rhel10/bootc-image-builder:latest
	podman run --rm -it --privileged --pull=newer --security-opt label=type:unconfined_t -v /var/lib/containers/storage:/var/lib/containers/storage -v $(CURDIR)/config.toml:/config.toml -v $(CURDIR)/output:/output registry.redhat.io/rhel10/bootc-image-builder:latest --type iso quay.io/rh-ee-chbutler/rhel-dev:latest


qcow: toml
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

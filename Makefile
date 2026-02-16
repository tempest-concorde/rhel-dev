# Architecture detection for multi-arch builds
UNAME_ARCH := $(shell uname -m)
ifeq ($(UNAME_ARCH),x86_64)
    BINARY_ARCH := amd64
else ifeq ($(UNAME_ARCH),aarch64)
    BINARY_ARCH := arm64
else
    BINARY_ARCH := $(UNAME_ARCH)
endif

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
	wget https://github.com/direnv/direnv/releases/download/v2.37.1/direnv.linux-$(BINARY_ARCH) -O direnv

# OpenShift Install binaries (versions 4.18, 4.19, 4.20)
get-openshift-install-418:
	wget https://mirror.openshift.com/pub/openshift-v4/$(UNAME_ARCH)/clients/ocp/stable-4.18/openshift-install-linux.tar.gz -O openshift-install-418.tar.gz
	tar -xzf openshift-install-418.tar.gz openshift-install
	mv openshift-install openshift-install-418
	rm openshift-install-418.tar.gz

get-openshift-install-419:
	wget https://mirror.openshift.com/pub/openshift-v4/$(UNAME_ARCH)/clients/ocp/stable-4.19/openshift-install-linux.tar.gz -O openshift-install-419.tar.gz
	tar -xzf openshift-install-419.tar.gz openshift-install
	mv openshift-install openshift-install-419
	rm openshift-install-419.tar.gz

get-openshift-install-420:
	wget https://mirror.openshift.com/pub/openshift-v4/$(UNAME_ARCH)/clients/ocp/stable-4.20/openshift-install-linux.tar.gz -O openshift-install-420.tar.gz
	tar -xzf openshift-install-420.tar.gz openshift-install
	mv openshift-install openshift-install-420
	rm openshift-install-420.tar.gz

# OC and kubectl (latest stable)
get-oc:
	wget https://mirror.openshift.com/pub/openshift-v4/$(UNAME_ARCH)/clients/ocp/stable/openshift-client-linux.tar.gz -O oc.tar.gz
	tar -xzf oc.tar.gz oc kubectl
	rm oc.tar.gz

# Gomplate binary
get-gomplate:
	wget https://github.com/hairyhenderson/gomplate/releases/download/v4.3.3/gomplate_linux-$(BINARY_ARCH) -O gomplate
	chmod +x gomplate

# oc-mirror v2
get-oc-mirror:
	wget https://mirror.openshift.com/pub/openshift-v4/$(UNAME_ARCH)/clients/ocp/stable/oc-mirror.rhel9.tar.gz -O oc-mirror.tar.gz
	tar -xzf oc-mirror.tar.gz oc-mirror
	rm oc-mirror.tar.gz

# Cosign
get-cosign:
	wget https://github.com/sigstore/cosign/releases/download/v3.0.4/cosign-linux-$(BINARY_ARCH) -O cosign
	chmod +x cosign

get-deps: get-direnv get-openshift-install-418 get-openshift-install-419 get-openshift-install-420 get-oc get-oc-mirror get-gomplate get-cosign


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
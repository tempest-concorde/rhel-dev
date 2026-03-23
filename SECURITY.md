# Security Policy

## FOR DEMONSTRATION USE ONLY

Do NOT presume this is security maintained. It's meant for a single user. The binaries are not released due to subscription concerns.

## Security Practices

This project follows container supply chain security best practices:

- **Signed images**: All released container images are signed with [cosign](https://github.com/sigstore/cosign) using key-based signing. The public key is committed at `containers-policy/cosign.pub`.
- **SELinux policy lockdown**: Container signing policy (`policy.json`) is protected by a custom SELinux type (`secure_container_policy_t`) that denies write access to all domains including root. `secure_mode_policyload` and `secure_mode_insmod` are set at boot via `selinux-lockdown.service`. Trust assets (cosign public key, registry config) are placed in read-only `/usr`.
- **Optional GRUB protection**: Bootloader can be password-protected at install time to prevent `selinux=0` kernel argument tampering. Set `GRUB_PASSWORD_HASH` before `make iso`.
- **Build provenance**: SLSA build provenance attestations are generated and pushed to the container registry.
- **SBOM**: SPDX Software Bill of Materials is generated and attested for each release.
- **Vulnerability scanning**: Images are scanned with [Trivy](https://github.com/aquasecurity/trivy) on each release; results are uploaded to GitHub Security.
- **Pinned dependencies**: All GitHub Actions are pinned to full SHA commits. Base images are pinned by digest.
- **Dependabot**: Automated dependency updates are enabled for GitHub Actions.
- **OpenSSF Scorecard**: The project is monitored via the [OpenSSF Scorecard](https://securityscorecards.dev/).

## Accepted Risks

### NOPASSWD sudo (opt-in)

Passwordless sudo is **not** baked into the image. It can be enabled at
install time by setting `NOPASSWD_SUDO=1` before running `make iso` or
`make qcow`. This adds a sudoers entry for the provisioning user via the
kickstart `%post` script. Disabled by default for CIS compliance.

## SCAP CIS Hardening

The image applies the CIS baseline profile from `scap-security-guide` at build
time using an "apply then override" strategy:

1. `oscap xccdf eval --remediate --profile cis` runs against the RHEL 10
   datastream
2. Subsequent Containerfile layers re-apply customizations that conflict with
   CIS defaults (sudoers, services, SELinux policy, firewalld)

This means the image starts from a hardened baseline and explicitly opts out
only where required by the use case. To check the current compliance score,
run inside a deployed instance:

```bash
oscap xccdf eval \
    --profile xccdf_org.ssgproject.content_profile_cis \
    /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml
```

## Cryptographic Policy

The image uses the `DEFAULT` crypto policy, which in RHEL 10.1+ includes
post-quantum cryptographic algorithms (ML-KEM for key encapsulation, ML-DSA
for digital signatures) via hybrid key exchange.

`FIPS` is intentionally not used because PQC algorithms are not yet
FIPS-validated. This prioritizes forward secrecy via hybrid post-quantum
key exchange over compliance certification.

To verify:

```bash
update-crypto-policies --show  # should output DEFAULT
```

## SELinux

SELinux is enforced via multiple mechanisms:

- **Kernel args:** `enforcing=1` set via `kargs.d/01-selinux.toml`
- **Policy booleans:** `secure_mode_policyload` and `secure_mode_insmod` are
  set at boot via `selinux-lockdown.service` (cannot be baked at build time
  due to container build environment limitations)
- **Custom policy module:** `container_lockdown.pp` protects
  `/etc/containers/policy.json` from runtime modification

## Binary Integrity

All downloaded binaries are checksum-verified at build time:

- **direnv:** SHA-256 digest from GitHub Releases API
- **gomplate, cosign, argocd:** SHA-256 from project-published checksum files
- **OCP tools (oc, oc-mirror, openshift-install):** `sha256sum.txt` from the
  Red Hat mirror

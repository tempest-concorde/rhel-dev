# Security Policy

## FOR DEMONSTRATION USE ONLY

Do NOT presume this is security maintained. It's meant for a single user. The binaries are not released due to subscription concerns.

## Security Practices

This project follows container supply chain security best practices:

- **Signed images**: All released container images are signed with [cosign](https://github.com/sigstore/cosign) using key-based signing. The public key is committed at `containers-policy/cosign.pub`.
- **SELinux policy lockdown**: Container signing policy (`policy.json`) is protected by a custom SELinux type (`secure_container_policy_t`) that denies write access to all domains including root. `secure_mode_policyload` is set at boot to prevent policy module changes or mode switching. Trust assets (cosign public key, registry config) are placed in read-only `/usr`.
- **Optional GRUB protection**: Bootloader can be password-protected at install time to prevent `selinux=0` kernel argument tampering. Set `GRUB_PASSWORD_HASH` before `make iso`.
- **Build provenance**: SLSA build provenance attestations are generated and pushed to the container registry.
- **SBOM**: SPDX Software Bill of Materials is generated and attested for each release.
- **Vulnerability scanning**: Images are scanned with [Trivy](https://github.com/aquasecurity/trivy) on each release; results are uploaded to GitHub Security.
- **Pinned dependencies**: All GitHub Actions are pinned to full SHA commits. Base images are pinned by digest.
- **Dependabot**: Automated dependency updates are enabled for GitHub Actions.
- **OpenSSF Scorecard**: The project is monitored via the [OpenSSF Scorecard](https://securityscorecards.dev/).

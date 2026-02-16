# Security Policy

## FOR DEMONSTRATION USE ONLY

Do NOT presume this is security maintained. It's meant for a single user. The binaries are not released due to subscription concerns.

## Security Practices

This project follows container supply chain security best practices:

- **Signed images**: All released container images are signed with [cosign](https://github.com/sigstore/cosign) using keyless OIDC (Sigstore).
- **Build provenance**: SLSA build provenance attestations are generated and pushed to the container registry.
- **SBOM**: SPDX Software Bill of Materials is generated and attested for each release.
- **Vulnerability scanning**: Images are scanned with [Trivy](https://github.com/aquasecurity/trivy) on each release; results are uploaded to GitHub Security.
- **Pinned dependencies**: All GitHub Actions are pinned to full SHA commits. Base images are pinned by digest.
- **Dependabot**: Automated dependency updates are enabled for GitHub Actions.
- **OpenSSF Scorecard**: The project is monitored via the [OpenSSF Scorecard](https://securityscorecards.dev/).

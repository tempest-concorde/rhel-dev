# Security Policy

## Supported Versions

Only the latest release is supported with security updates.

| Version | Supported |
|---------|-----------|
| Latest  | Yes       |
| Older   | No        |

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly:

1. **Do not** open a public GitHub issue for security vulnerabilities.
2. Email the maintainer at the address listed in the repository profile, or use [GitHub private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability).
3. Include a description of the vulnerability, steps to reproduce, and any potential impact.
4. You should receive an acknowledgment within 72 hours.

## Security Practices

This project follows container supply chain security best practices:

- **Signed images**: All released container images are signed with [cosign](https://github.com/sigstore/cosign) using keyless OIDC (Sigstore).
- **Build provenance**: SLSA build provenance attestations are generated and pushed to the container registry.
- **SBOM**: SPDX Software Bill of Materials is generated and attested for each release.
- **Vulnerability scanning**: Images are scanned with [Trivy](https://github.com/aquasecurity/trivy) on each release; results are uploaded to GitHub Security.
- **Pinned dependencies**: All GitHub Actions are pinned to full SHA commits. Base images are pinned by digest.
- **Dependabot**: Automated dependency updates are enabled for GitHub Actions.
- **OpenSSF Scorecard**: The project is monitored via the [OpenSSF Scorecard](https://securityscorecards.dev/).

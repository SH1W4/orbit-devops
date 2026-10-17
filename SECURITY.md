# Security Policy

## Supported Versions

Security fixes are developed against the current repository branch. Release-specific support commitments will be documented when a release policy is established.

## Reporting a Vulnerability

Please report vulnerabilities through GitHub's private security advisory feature for this repository. Do not publish exploit details or sensitive logs in public issues.

When reporting, include:
- A concise description and potential impact
- Affected version, operating system, and relevant configuration
- Minimal reproduction steps, with secrets and personal data removed
- Any known mitigation

Do not include API tokens, passwords, private keys, seed phrases, or unredacted diagnostic reports.

## Security Practices

Orbit-DevOps includes scripts that can inspect or modify the host environment. Treat diagnostic outputs as potentially sensitive and review them before sharing. Review all cleanup, synchronization, and disk-management plans before authorizing actions.

The presence of a script or an agent capability does not itself authorize execution. Do not assume a command is safe unless its current implementation and effects have been reviewed.

## Disclosure

Coordinate public disclosure through the private security advisory process after maintainers have assessed and addressed the report.

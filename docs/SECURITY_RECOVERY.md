# Security recovery — October 2026

## Scope

This change reduces exposure in the current repository snapshot and disables unsafe automation. It is a containment/remediation step, not a claim that all historical Git data has been erased or that the repository has received a complete security audit.

## Changes in this branch

- Removed machine-specific diagnostic reports and replaced local setup snapshots with generic documentation.
- Removed the tracked `node_modules/` tree from the current repository snapshot (2,699 paths); dependencies remain reproducible from the package manifests.
- Made the normal cleanup command a dry-run by default; removed Downloads and the broad user `.cache` directory from its targets.
- Required an explicit `-Execute` switch and interactive confirmation for the PowerShell cleanup script.
- Disabled legacy cleanup scripts that could stop Docker containers, prune volumes/images, disable hibernation, remove Anaconda, delete editor backups, delete project backups, or empty the Recycle Bin.
- Disabled destructive cleanup execution through the MCP tool.
- Changed stack sync and environment snapshots to generate local inventories only; they no longer stage, commit, or push.
- Removed the hardcoded workstation path and stopped persisting `PYTHONPATH` at user scope.
- Generalized diagnostic scripts that previously named specific local projects and paths.
- Disabled all four legacy forensic RAM audit scripts because they collected broad process, company, description, and Windows service inventories.
- Disabled the legacy token-based push helper that embedded a GitHub token in a remote URL.
- Disabled automatic Downloads organization and changed WSL compaction to preview-only unless explicitly executed.
- Added regression tests for the security guardrails, including an explicit test that the four broad forensic RAM audit scripts remain disabled.
- Changed agent-stack template defaults to supervised operation with cleanup, sync, and network access disabled.
- Aligned CLI and lockfile root version metadata with `package.json` 1.4.1.
- Added ignore rules for local reports and inventories.

## Validation status

- GitHub Actions CI passed on the current PR head `2cd7a11c3692af88a47460986df2285d7617d081` (run 39062905242): dependency installation, the tracked-`node_modules` guard, lint, and tests succeeded.
- A local installation and test run has not been performed from this environment.
- No cleanup script has been executed against a user's machine as part of this recovery.

## Remaining remediation

- Before this PR is merged, the default `main` branch still contains the prior machine-specific files and tracked `node_modules/`; this PR removes them from the proposed current snapshot.
- Sensitive-looking local reports, project paths, and older versions of disabled scripts remain in earlier Git commits. A normal merge does not erase those historical copies.
- Secret-pattern searches so far were preliminary and inconclusive. No credential was confirmed, but a complete historical secret scan has not been completed.
- A historical version of `scripts/legacy/ForcePush.ps1` retrieved `gh auth token` and embedded it in a remote URL used by Git. No literal token was found in the inspected script. Whether it was executed and whether a credential was exposed in process arguments or logs remain unverified.
- If there is evidence that a credential was exposed, revoke/rotate it and review relevant account activity.
- Historical remediation may require a coordinated Git history rewrite and force-push. That action has not been performed and should be planned separately because it affects clones, forks, and collaborators.
- Review dependency provenance and compare the published npm package with the reviewed source before publishing another release.

## Safety boundary

This PR is intended to remediate the current repository snapshot and disable unsafe behavior. Merging it does **not** certify that historical data has been erased, that all secrets have been ruled out, or that the package is ready for a new release. No history rewrite or force-push has been performed.

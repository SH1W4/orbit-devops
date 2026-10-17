# Security recovery — October 2026

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
- Added regression tests for the security guardrails.
- Changed agent-stack template defaults to supervised operation with cleanup, sync, and network access disabled.
- Aligned CLI and lockfile root version metadata with `package.json` 1.4.1.
- Added ignore rules for local reports and inventories.

## Validation status

- GitHub Actions CI passed on commit `8fda45a862703d41b4d76d3d3c828b180b74101e` before the latest forensic-script changes.
- The four legacy forensic RAM audit scripts were subsequently replaced with fail-closed stubs; CI must pass again on the latest PR head.
- A local installation and test run has not been performed from this environment.
- A local installation and test run has not been performed from this environment.

## Remaining remediation

- The `main` branch still contains the prior machine-specific files and tracked `node_modules/` until the PR is integrated.
- The sensitive-looking local reports and project paths were present in earlier commits. Removing them from the current tree does not erase historical copies.
- The legacy forensic RAM scripts no longer collect or write process/service inventories in this branch; old versions remain in Git history until history remediation is explicitly approved and performed.
- Full Git history remediation requires a separately planned history rewrite and coordinated force-push; this has not been performed.
- Secret-pattern searches were preliminary and inconclusive. No credential was confirmed, but a complete secret/history scan remains outstanding.
- Review dependency provenance and compare the published npm package with the reviewed source before publishing another release.

## Safety boundary

No cleanup script has been executed against a user's machine. No branch has been merged into `main`. No history rewrite or force push has been performed.

# Security recovery — October 2026

## Changes in this branch

- Removed machine-specific diagnostic reports and replaced local setup notes with a generic guide.
- Made the normal cleanup command a dry-run by default; removed Downloads and the broad user `.cache` directory from its targets.
- Required an explicit `-Execute` switch and interactive confirmation for the PowerShell cleanup script.
- Disabled legacy cleanup scripts that could stop Docker containers, prune volumes/images, disable hibernation, remove Anaconda, or delete editor backups.
- Disabled destructive cleanup execution through the MCP tool.
- Changed stack sync to generate a local inventory only; it no longer stages, commits, or pushes.
- Removed the hardcoded workstation path and stopped persisting `PYTHONPATH` at user scope.
- Changed agent-stack template defaults to supervised operation with cleanup, sync, and network access disabled.
- Aligned CLI and lockfile root version metadata with `package.json` 1.4.1.
- Added ignore rules for local reports and inventories.

## Validation status

This branch has been changed through the GitHub API. A local install and test run has not yet been performed in this environment. CI results and a final review are required before merging.

## Remaining remediation

- Remove already tracked `node_modules/` content from Git; `.gitignore` alone does not untrack existing files.
- Audit the complete Git history for machine-specific data and secrets. Deleting files from the current tree does not remove old copies from history.
- Complete a full secret scan and dependency review.
- Verify the package published to npm against the reviewed source before publishing another release.

## Safety boundary

No cleanup script has been executed against a user's machine. No branch has been merged into `main`. No history rewrite or force push has been performed.

# DISABLED: legacy total cleanup was unsafe.
# It disabled hibernation, stopped all Docker containers, pruned volumes/images,
# and could force-delete the user's Anaconda installation.
Write-Error "This legacy destructive cleanup script is disabled. No changes were made."
Write-Host "Use AdditionalCleanup.ps1 for a dry-run preview of narrowly scoped cache/temp targets." -ForegroundColor Yellow
exit 2

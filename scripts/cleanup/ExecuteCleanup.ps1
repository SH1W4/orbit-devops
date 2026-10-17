# DISABLED: legacy cleanup had side effects (Cursor backup deletion and Docker prune).
# No deletion or Docker operation is performed by this replacement.
Write-Error "This legacy cleanup script is disabled. No changes were made."
Write-Host "Review the cleanup plan with AdditionalCleanup.ps1 instead." -ForegroundColor Yellow
exit 2

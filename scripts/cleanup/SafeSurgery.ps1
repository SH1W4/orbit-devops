# DISABLED: this legacy script deleted named project backups and shut down WSL
# before attempting Docker virtual-disk compaction.
Write-Error "This legacy surgery script is disabled. No files or virtual disks were changed."
Write-Host "Use a dedicated, reviewed backup/compaction procedure instead." -ForegroundColor Yellow
exit 2

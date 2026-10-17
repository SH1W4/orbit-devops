# DISABLED: this legacy script moved files from Downloads by extension and could
# overwrite existing destination files.
Write-Error "This legacy Downloads organizer is disabled. No files were moved."
Write-Host "Downloads are intentionally excluded from automated organization during security recovery." -ForegroundColor Yellow
exit 2

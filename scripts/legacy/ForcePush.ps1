# DISABLED: this legacy script retrieved a GitHub token and embedded it in a remote URL.
# Never place access tokens in command-line arguments or remote URLs.
Write-Error "This legacy token-based push script is disabled. No Git operation was performed."
Write-Host "Use GitHub CLI's normal credential integration and review the diff before pushing." -ForegroundColor Yellow
exit 2

# Orbit-DevOps: Environment Snapshot
# Exports installed package metadata to a local JSON file for review only.
# This script never stages, commits, or pushes the resulting inventory.

param (
    [string]$OutputPath = (Join-Path $env:TEMP "orbit-dev-stack-snapshot.json")
)

Write-Host "Orbit-DevOps: Environment Snapshot" -ForegroundColor Cyan
Write-Warning "The inventory may disclose installed software and versions. Review it before sharing."
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "Winget is not installed or not in PATH."
    exit 1
}

try {
    winget export -o $OutputPath --include-versions --ignore-unavailable
    if ($LASTEXITCODE -ne 0) {
        throw "winget export failed with exit code $LASTEXITCODE"
    }
    Write-Host "Snapshot saved locally to: $OutputPath" -ForegroundColor Green
    Write-Host "No Git operations were performed. Do not publish the file without reviewing it." -ForegroundColor Yellow
} catch {
    Write-Error "Failed to export packages: $_"
    exit 1
}

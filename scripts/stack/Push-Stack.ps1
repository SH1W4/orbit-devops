# Orbit-DevOps: Generate a local stack inventory for manual review.
# This script intentionally does not git add, commit, or push anything.

$stackRepoPath = $env:ORBIT_STACK_PATH
if (-not $stackRepoPath -or -not (Test-Path -LiteralPath $stackRepoPath)) {
    Write-Error "Stack repository not found. Set ORBIT_STACK_PATH to a local review directory."
    exit 1
}
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "Winget is not installed."
    exit 1
}

$outputPath = Join-Path $stackRepoPath "dev-stack.json"
Write-Warning "The exported inventory can reveal installed software and versions. Keep it private until reviewed."
winget export -o $outputPath --include-versions --ignore-unavailable
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $outputPath)) {
    Write-Error "Inventory export failed; no Git operation was performed."
    exit 1
}

Write-Host "Inventory generated at: $outputPath" -ForegroundColor Green
Write-Host "No files were staged, committed, or pushed. Review and redact the inventory before any manual publication." -ForegroundColor Yellow

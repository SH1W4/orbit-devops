# Portable local environment setup. No persistent user-level environment changes.
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$env:PYTHONPATH = $repoRoot

$venvPath = Join-Path $repoRoot ".venv"
if (-not (Test-Path -LiteralPath $venvPath)) {
    Write-Host "Creating Python virtual environment..." -ForegroundColor Cyan
    python -m venv $venvPath
    if ($LASTEXITCODE -ne 0) {
        throw "Python virtual environment creation failed."
    }
    Write-Host "Virtual environment created." -ForegroundColor Green
}

Write-Host "Environment configured for this PowerShell process only." -ForegroundColor Green
Write-Host "Repository root: $repoRoot"
Write-Host "PYTHONPATH will not be persisted to the Windows user profile."
Write-Host "Activate the environment with: .\.venv\Scripts\Activate.ps1"

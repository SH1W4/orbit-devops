# Orbit-DevOps: Sync Stack to GitHub
# Generates a fresh dev-stack.json and pushes it to the remote repository

$stackRepoPath = "c:\Users\João\Desktop\PROJETOS\stack"
$orbitStackPath = "$env:USERPROFILE\Desktop\PROJETOS\04_DEVELOPER_TOOLS\orbit-devops\dev-stack.json"

Write-Host "🪐 Orbit-DevOps: Stack Sync" -ForegroundColor Cyan

# 1. Generate Fresh Snapshot
Write-Host "Generating fresh environment snapshot..." -ForegroundColor Yellow
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "Winget is not installed."
    exit 1
}

# Export temporarily to orbit folder then move (safest way to ensure it exists)
winget export -o "$stackRepoPath\dev-stack.json" --include-versions --force

if (Test-Path "$stackRepoPath\dev-stack.json") {
    Write-Host "Snapshot successfully generated in stack repo." -ForegroundColor Green
}
else {
    Write-Error "Failed to generate snapshot."
    exit 1
}

# 2. Git Sync
Write-Host "Syncing with GitHub..." -ForegroundColor Yellow
Set-Location -Path $stackRepoPath

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
git add .
git commit -m "Auto-sync: Environment update ($timestamp)"
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n🚀 Environment Stack successfully synced to GitHub!" -ForegroundColor Green
}
else {
    Write-Error "Git sync failed. Check your internet connection and permissions."
}

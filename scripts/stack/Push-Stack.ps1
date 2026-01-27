# Orbit-DevOps: Sync Stack to GitHub
# Generates a fresh dev-stack.json and pushes it to the remote repository

# Determine the Stack Repository Path
# 1. Check Environment Variable
# 2. Try to find a 'stack' directory in the parent folder of the project
$stackRepoPath = $env:ORBIT_STACK_PATH

if (-not $stackRepoPath) {
    # Calculate likely path (neighbor to orbit-devops directory)
    # We use $PSScriptRoot and go up to the workspace root
    $currentScriptDir = $PSScriptRoot
    $parentDir = Split-Path (Split-Path $currentScriptDir -Parent) -Parent
    $candidate = Join-Path $parentDir "stack"
    
    if (Test-Path $candidate) {
        $stackRepoPath = $candidate
    }
}

if (-not $stackRepoPath -or -not (Test-Path $stackRepoPath)) {
    Write-Host "⚠️  Stack repository not found!" -ForegroundColor Red
    Write-Host "To use 'orbit sync', please:" -ForegroundColor Yellow
    Write-Host "1. Create a repository for your environment DNA (e.g., 'stack')."
    Write-Host "2. Set the environment variable ORBIT_STACK_PATH to that folder."
    Write-Host "   Example: [System.Environment]::SetEnvironmentVariable('ORBIT_STACK_PATH', 'C:\Path\To\Stack', 'User')"
    exit 1
}

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

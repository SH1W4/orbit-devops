$ErrorActionPreference = "SilentlyContinue"

function Get-FriendlySize {
    param($Bytes)
    if ($Bytes -gt 1GB) {
        return "$([math]::Round($Bytes / 1GB, 2)) GB"
    }
    elseif ($Bytes -gt 1MB) {
        return "$([math]::Round($Bytes / 1MB, 2)) MB"
    }
    else {
        return "$Bytes Bytes"
    }
}

Write-Host "=== DEEP STORAGE ANALYSIS ===" -ForegroundColor Cyan
Write-Host ""

# 1. Check WSL Virtual Disks
Write-Host "[1] Checking for WSL Virtual Disks (*.vhdx)..." -ForegroundColor Yellow
$vhdxFiles = Get-ChildItem -Path "$env:USERPROFILE\AppData\Local\Packages" -Filter "*.vhdx" -Recurse -ErrorAction SilentlyContinue
if ($vhdxFiles) {
    foreach ($file in $vhdxFiles) {
        Write-Host "  FOUND: $($file.FullName)" -ForegroundColor Red
        Write-Host "  SIZE:  $(Get-FriendlySize $file.Length)" -ForegroundColor Red
    }
}
else {
    Write-Host "  No huge WSL disks found in standard location." -ForegroundColor Green
}

# 2. Check Specific Dev Folders
Write-Host ""
Write-Host "[2] Checking Key Developer Folders..." -ForegroundColor Yellow
$targets = @(
    "$env:USERPROFILE\AppData\Local\Docker",
    "$env:ProgramData\Docker",
    "$env:USERPROFILE\.docker",
    "$env:USERPROFILE\anaconda3",
    "$env:USERPROFILE\AppData\Local\Temp",
    "$env:USERPROFILE\AppData\Local\NVIDIA",
    "$env:USERPROFILE\AppData\Roaming\Code\User\workspaceStorage",
    "$env:USERPROFILE\AppData\Roaming\Slack"
)

foreach ($path in $targets) {
    if (Test-Path $path) {
        Write-Host "  Measuring: $path ..."
        $size = Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
        Write-Host "  RESULT: $(Get-FriendlySize $size.Sum)" -ForegroundColor Cyan
    }
}

# 3. Top 20 Largest Files in User Profile
Write-Host ""
Write-Host "[3] Top 20 Largest Files in User Profile (Standard Folders)..." -ForegroundColor Yellow
$searchPaths = @(
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\Videos"
)

$largeFiles = foreach ($path in $searchPaths) {
    if (Test-Path $path) {
        Get-ChildItem $path -Recurse -File -ErrorAction SilentlyContinue | Select-Object Name, FullName, Length
    }
}

$largeFiles | Sort-Object Length -Descending | Select-Object -First 20 | ForEach-Object {
    Write-Host "  $(Get-FriendlySize $_.Length) - $($_.FullName)"
}

Write-Host ""
Write-Host "=== ANALYSIS COMPLETE ===" -ForegroundColor Cyan
exit 0

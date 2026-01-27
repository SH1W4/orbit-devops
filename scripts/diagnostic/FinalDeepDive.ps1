$ErrorActionPreference = "SilentlyContinue"
$user = $env:USERPROFILE

Write-Host "=== FINAL DEEP DIVE AUDIT ===" -ForegroundColor Cyan

# 1. Media Folders
$media = @("Videos", "Pictures", "Music", "Documents")
foreach ($m in $media) {
    $path = Join-Path $user $m
    if (Test-Path $path) {
        $size = Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
        Write-Host "$m : $([math]::Round($size.Sum / 1GB, 2)) GB"
    }
}

# 2. Other Users
Write-Host "`n--- Checking Other Users ---"
Get-ChildItem "C:\Users" -Directory | ForEach-Object {
    if ($_.Name -ne "User" -and $_.Name -ne "Public") {
        $size = Get-ChildItem $_.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
        Write-Host "User $($_.Name) : $([math]::Round($size.Sum / 1GB, 2)) GB"
    }
}

# 3. Windows Directory
Write-Host "`n--- Checking Windows Directory ---"
$winSize = Get-ChildItem "C:\Windows" -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
Write-Host "Windows : $([math]::Round($winSize.Sum / 1GB, 2)) GB"

# 4. Hidden Large Files in Root
Write-Host "`n--- Checking Root Virtual Disks ---"
Get-ChildItem "C:\" -File -Force -ErrorAction SilentlyContinue | Where-Object { $_.Length -gt 1GB } | ForEach-Object {
    Write-Host "ROOT FILE: $($_.Name) : $([math]::Round($_.Length / 1GB, 2)) GB"
}

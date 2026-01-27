
$ErrorActionPreference = "SilentlyContinue"

function Get-FolderSize {
    param($Path)
    if (Test-Path $Path) {
        $measure = Get-ChildItem $Path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
        $sizeGB = [math]::Round($measure.Sum / 1GB, 2)
        Write-Host "Folder: $Path - Size: $sizeGB GB"
        return $measure.Sum
    }
    return 0
}

Write-Host "=== SCANNING STORAGE ==="
Write-Host "Checking main user folders..."

$folders = @(
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\AppData\Local\Temp",
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Pictures",
    "$env:USERPROFILE\Videos"
)

foreach ($f in $folders) {
    Get-FolderSize -Path $f
}

Write-Host "`n=== TOP 20 LARGEST FILES (User Home) ==="
# This might take a while, so we limit depth or scope if needed. 
# For now, let's look at the root of User home and 2 levels deep to avoid massive scan times, 
# or just scan Downloads and Documents specifically for large files.
Get-ChildItem "$env:USERPROFILE" -Recurse -File -ErrorAction SilentlyContinue | 
Sort-Object Length -Descending | 
Select-Object -First 20 | 
ForEach-Object {
    $sizeMB = [math]::Round($_.Length / 1MB, 2)
    Write-Host "File: $($_.FullName) - $sizeMB MB"
}

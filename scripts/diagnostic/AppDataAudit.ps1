$ErrorActionPreference = "SilentlyContinue"
$path = "$env:USERPROFILE\AppData\Local"
$folders = Get-ChildItem -Path $path -Directory

Write-Host "=== APPDATA\LOCAL AUDIT ===" -ForegroundColor Cyan
$results = foreach ($f in $folders) {
    $size = Get-ChildItem $f.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
    if ($size.Sum -gt 100MB) {
        [PSCustomObject]@{
            Folder = $f.Name
            SizeGB = [math]::Round($size.Sum / 1GB, 2)
        }
    }
}

$results | Sort-Object SizeGB -Descending | Format-Table -AutoSize

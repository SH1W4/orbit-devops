$ErrorActionPreference = "SilentlyContinue"
$root = "C:\"
$items = Get-ChildItem -Path $root

Write-Host "=== C: DRIVE ROOT AUDIT ===" -ForegroundColor Cyan
foreach ($item in $items) {
    if ($item.PSIsContainer) {
        $size = Get-ChildItem $item.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
        Write-Host "$($item.Name) : $([math]::Round($size.Sum / 1GB, 2)) GB"
    }
    else {
        Write-Host "$($item.Name) (File) : $([math]::Round($item.Length / 1GB, 2)) GB"
    }
}

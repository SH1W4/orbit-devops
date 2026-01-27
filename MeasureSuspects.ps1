$ErrorActionPreference = "SilentlyContinue"
$targets = @(
    "$env:USERPROFILE\Desktop\PROJETOS",
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\AppData",
    "C:\Program Files",
    "C:\Program Files (x86)"
)

Write-Host "=== TARGETED SIZE ANALYSIS ===" -ForegroundColor Cyan
foreach ($t in $targets) {
    if (Test-Path $t) {
        Write-Host "Measuring $t ..."
        $size = Get-ChildItem $t -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
        Write-Host "$t : $([math]::Round($size.Sum / 1GB, 2)) GB"
    }
}

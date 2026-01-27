$paths = @(
    "$env:USERPROFILE\Desktop\PROJETOS\02_ORGANIZATIONS\MOBILIDADE\guardrive-core-backup",
    "$env:USERPROFILE\Desktop\PROJETOS\05_PLATFORMS\SYMBEON-AI\SYMBEON\backup",
    "$env:USERPROFILE\Desktop\PROJETOS\04_DEVELOPER_TOOLS\GITHUB_PROFILE_NEO_SH1W4\backups"
)

Write-Host "=== BACKUP SIZE ANALYSIS ==="
foreach ($p in $paths) {
    if (Test-Path $p) {
        Write-Host "Measuring $p ..."
        $size = Get-ChildItem $p -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
        Write-Host "SIZE: $([math]::Round($size.Sum / 1GB, 2)) GB"
    }
    else {
        Write-Host "Not found: $p"
    }
}

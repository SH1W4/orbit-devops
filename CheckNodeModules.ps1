$paths = @(
    "$env:USERPROFILE\Desktop\PROJETOS\05_PLATFORMS\SYMBEON-ECOSYSTEM\node_modules",
    "$env:USERPROFILE\Desktop\PROJETOS\03_AI_AGENTS\VIREON\frontend\node_modules",
    "$env:USERPROFILE\Desktop\PROJETOS\04_DEVELOPER_TOOLS\SynPhytica\web\node_modules",
    "$env:USERPROFILE\Desktop\PROJETOS\04_DEVELOPER_TOOLS\GITHUB_MASTERY\node_modules",
    "$env:USERPROFILE\Desktop\PROJETOS\00_ECOSYSTEM_COMERCIAL\SEVE-FRAMEWORK\SEVE-FRAMEWORK\node_modules",
    "$env:USERPROFILE\Desktop\PROJETOS\02_ORGANIZATIONS\VAREJO\GuardFlow\frontend\node_modules"
)

Write-Host "=== NODE_MODULES SIZE ANALYSIS ==="
foreach ($p in $paths) {
    if (Test-Path $p) {
        Write-Host "Measuring $p ..."
        $size = Get-ChildItem $p -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
        Write-Host "SIZE: $([math]::Round($size.Sum / 1MB, 2)) MB"
    }
}

$ErrorActionPreference = "SilentlyContinue"
$userPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop", "PROJETOS")
$targets = @(
    "03_AI_AGENTS\VIREON\target",
    "04_DEVELOPER_TOOLS\ARKITECT\orchestrator_core\target",
    "02_ORGANIZATIONS\VAREJO\GuardFlow\backend\target",
    "05_PLATFORMS\SYMBEON-ECOSYSTEM\node_modules",
    "02_ORGANIZATIONS\VAREJO\GuardFlow\frontend\node_modules",
    "00_ECOSYSTEM_COMERCIAL\SEVE-FRAMEWORK\SEVE-FRAMEWORK\node_modules",
    "00_ECOSYSTEM_COMERCIAL\OPTIMUS\core\node_modules",
    "01_CORE_SYSTEMS\mcp-ecosystem\node_modules"
)

Write-Host "=== SURGICAL BLOAT REPORT (v2) ==="
foreach ($t in $targets) {
    $full = Join-Path $userPath $t
    if (Test-Path $full) {
        $size = (Get-ChildItem $full -Recurse -File -Force | Measure-Object -Property Length -Sum).Sum
        $gb = [math]::Round($size / 1GB, 2)
        Write-Host "$t : $gb GB"
    }
}

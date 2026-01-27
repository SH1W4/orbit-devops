$ErrorActionPreference = "SilentlyContinue"
$userPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop", "PROJETOS")

# Confirmed heavy hitters from find_by_name
$targets = @(
    "03_AI_AGENTS\VIREON\target",
    "04_DEVELOPER_TOOLS\ARKITECT\orchestrator_core\target",
    "02_ORGANIZATIONS\VAREJO\GuardFlow\backend\target",
    "05_PLATFORMS\SYMBEON-ECOSYSTEM\node_modules",
    "02_ORGANIZATIONS\VAREJO\GuardFlow\frontend\node_modules",
    "00_ECOSYSTEM_COMERCIAL\OPTIMUS\core\node_modules",
    "00_ECOSYSTEM_COMERCIAL\SEVE-FRAMEWORK\SEVE-FRAMEWORK\node_modules",
    "01_CORE_SYSTEMS\mcp-ecosystem\node_modules",
    "02_ORGANIZATIONS\SAGE-X\node_modules",
    "03_AI_AGENTS\AIDEN_PROJECT\venv"
)

Write-Host "=== SURGICAL BLOAT AUDIT ===" -ForegroundColor Cyan
$report = @()
foreach ($t in $targets) {
    $full = Join-Path $userPath $t
    if (Test-Path $full) {
        Write-Host "Measuring $t ..." -NoNewline
        $size = (Get-ChildItem $full -Recurse -File -Force | Measure-Object -Property Length -Sum).Sum
        $report += [PSCustomObject]@{
            Categoria  = $t.Split('\')[0]
            Projeto    = $t.Split('\')[1]
            Tipo       = $t.Split('\')[-1]
            "Size(GB)" = [math]::Round($size / 1GB, 2)
        }
        Write-Host " Done."
    }
}

$report | Sort-Object "Size(GB)" -Descending | Format-Table -AutoSize

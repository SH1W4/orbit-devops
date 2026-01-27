$ErrorActionPreference = "SilentlyContinue"
$root = "c:\Users\João\Desktop\PROJETOS"
$targets = @(
    "03_AI_AGENTS\VIREON\target",
    "02_ORGANIZATIONS\VAREJO\GuardFlow\backend\target",
    "05_PLATFORMS\SYMBEON-ECOSYSTEM\node_modules",
    "02_ORGANIZATIONS\VAREJO\GuardFlow\frontend\node_modules",
    "00_ECOSYSTEM_COMERCIAL\SEVE-FRAMEWORK\SEVE-FRAMEWORK\node_modules",
    "00_ECOSYSTEM_COMERCIAL\OPTIMUS\core\node_modules",
    "01_CORE_SYSTEMS\mcp-ecosystem\node_modules"
)

Write-Host "=== SURGICAL BLOAT REPORT ===" -ForegroundColor Cyan
$report = @()

foreach ($t in $targets) {
    $full = "$root\$t"
    if (Test-Path $full) {
        # Fast size check
        $size = Get-ChildItem $full -Recurse -Force | Measure-Object -Property Length -Sum
        $report += [PSCustomObject]@{
            Path       = $t
            "Size(GB)" = [math]::Round($size.Sum / 1GB, 2)
        }
    }
}

$report | Sort-Object "Size(GB)" -Descending | Format-Table -AutoSize

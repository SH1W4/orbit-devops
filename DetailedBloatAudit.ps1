$ErrorActionPreference = "SilentlyContinue"
$root = "c:\Users\João\Desktop\PROJETOS"
$categories = @("00_ECOSYSTEM_COMERCIAL", "01_CORE_SYSTEMS", "02_ORGANIZATIONS", "03_AI_AGENTS", "04_DEVELOPER_TOOLS", "05_PLATFORMS", "06_UTILITIES", "07_RESEARCH", "08_PROFILE", "GUARDRIVE", "_SCRIPTS")

Write-Host "=== RELATORIO DETALHADO DE RESQUICIOS DEV ===" -ForegroundColor Cyan
Write-Host "Analisando categorias em $root..."

$finalReport = @()
$totalSize = 0

foreach ($cat in $categories) {
    $catPath = "$root\$cat"
    if (-not (Test-Path $catPath)) { continue }
    
    $catNode = 0
    $catRust = 0
    $catPy = 0
    
    # 1. node_modules (Excluindo aninhados)
    $nodes = Get-ChildItem -Path $catPath -Filter "node_modules" -Recurse -Directory -Force | Where-Object { $_.FullName -notmatch "node_modules.*node_modules" }
    foreach ($n in $nodes) {
        $s = Get-ChildItem $n.FullName -Recurse -Force | Measure-Object -Property Length -Sum
        $catNode += $s.Sum
    }
    
    # 2. target (Rust builds)
    $targets = Get-ChildItem -Path $catPath -Filter "target" -Recurse -Directory -Force
    foreach ($t in $targets) {
        $s = Get-ChildItem $t.FullName -Recurse -Force | Measure-Object -Property Length -Sum
        $catRust += $s.Sum
    }
    
    # 3. venv / .venv (Python environments)
    $venvs = Get-ChildItem -Path $catPath -Include "venv", ".venv" -Recurse -Directory -Force
    foreach ($v in $venvs) {
        $s = Get-ChildItem $v.FullName -Recurse -Force | Measure-Object -Property Length -Sum
        $catPy += $s.Sum
    }
    
    $subTotal = $catNode + $catRust + $catPy
    $totalSize += $subTotal
    
    if ($subTotal -gt 0) {
        $finalReport += [PSCustomObject]@{
            Categoria         = $cat
            "JS/Node(GB)"     = [math]::Round($catNode / 1GB, 2)
            "Rust/Target(GB)" = [math]::Round($catRust / 1GB, 2)
            "Python/Venv(GB)" = [math]::Round($catPy / 1GB, 2)
            "SUBTOTAL(GB)"    = [math]::Round($subTotal / 1GB, 3)
        }
    }
}

$finalReport | Sort-Object "SUBTOTAL(GB)" -Descending | Format-Table -AutoSize
Write-Host "`nTOTAL ACUMULADO EM RESQUICIOS: $([math]::Round($totalSize / 1GB, 2)) GB" -ForegroundColor Green

$ErrorActionPreference = "SilentlyContinue"
$root = "$HOME\Desktop\PROJETOS"
$categories = @("00_ECOSYSTEM_COMERCIAL", "01_CORE_SYSTEMS", "02_ORGANIZATIONS", "03_AI_AGENTS", "04_DEVELOPER_TOOLS", "05_PLATFORMS", "06_UTILITIES", "07_RESEARCH", "08_PROFILE", "GUARDRIVE")

Write-Host "=== PROJECT BLOAT AUDIT (BY CATEGORY) ===" -ForegroundColor Cyan
$finalReport = @()

foreach ($cat in $categories) {
    $catPath = "$root\$cat"
    if (-not (Test-Path $catPath)) { continue }
    
    $nodeSize = 0
    $targetSize = 0
    $venvSize = 0
    
    # 1. node_modules
    $nodes = Get-ChildItem -Path $catPath -Filter "node_modules" -Recurse -Directory -Force -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch "node_modules.*node_modules" }
    foreach ($n in $nodes) {
        $s = Get-ChildItem $n.FullName -Recurse -Force | Measure-Object -Property Length -Sum
        $nodeSize += $s.Sum
    }
    
    # 2. target (Rust)
    $targets = Get-ChildItem -Path $catPath -Filter "target" -Recurse -Directory -Force -ErrorAction SilentlyContinue
    foreach ($t in $targets) {
        $s = Get-ChildItem $t.FullName -Recurse -Force | Measure-Object -Property Length -Sum
        $targetSize += $s.Sum
    }
    
    # 3. venv / .venv
    $venvs = Get-ChildItem -Path $catPath -Include "venv", ".venv" -Recurse -Directory -Force -ErrorAction SilentlyContinue
    foreach ($v in $venvs) {
        $s = Get-ChildItem $v.FullName -Recurse -Force | Measure-Object -Property Length -Sum
        $venvSize += $s.Sum
    }
    
    $total = $nodeSize + $targetSize + $venvSize
    if ($total -gt 1MB) {
        $finalReport += [PSCustomObject]@{
            Category     = $cat
            "Node(GB)"   = [math]::Round($nodeSize / 1GB, 2)
            "Rust(GB)"   = [math]::Round($targetSize / 1GB, 2)
            "PyVenv(GB)" = [math]::Round($venvSize / 1GB, 2)
            "TOTAL(GB)"  = [math]::Round($total / 1GB, 2)
        }
    }
}

$finalReport | Sort-Object "TOTAL(GB)" -Descending | Format-Table -AutoSize

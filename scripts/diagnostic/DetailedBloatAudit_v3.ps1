$ErrorActionPreference = "SilentlyContinue"
# Using environment variable to avoid encoding issues with 'João'
$userPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop", "PROJETOS")
$categories = @("00_ECOSYSTEM_COMERCIAL", "01_CORE_SYSTEMS", "02_ORGANIZATIONS", "03_AI_AGENTS", "04_DEVELOPER_TOOLS", "05_PLATFORMS", "06_UTILITIES", "07_RESEARCH", "08_PROFILE", "GUARDRIVE", "_SCRIPTS")

Write-Host "=== RELATORIO DETALHADO DE RESQUICIOS DEV (v3) ===" -ForegroundColor Cyan
Write-Host "Analisando projetos em: $userPath"

$report = @()
$grandTotal = 0

foreach ($cat in $categories) {
    $catPath = Join-Path $userPath $cat
    if (-not (Test-Path $catPath)) { continue }
    
    $jsSize = 0
    $rustSize = 0
    $pySize = 0
    
    # Fast search for directories
    $folders = Get-ChildItem -Path $catPath -Recurse -Directory -Force -ErrorAction SilentlyContinue | Where-Object {
        $_.Name -eq "node_modules" -or $_.Name -eq "target" -or $_.Name -eq "venv" -or $_.Name -eq ".venv"
    }

    foreach ($f in $folders) {
        # Avoid counting internal node_modules (e.g. node_modules/somepkg/node_modules)
        if ($f.Name -eq "node_modules" -and $f.FullName -match "node_modules.*node_modules") { continue }
        
        $size = (Get-ChildItem $f.FullName -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        if ($f.Name -eq "node_modules") { $jsSize += $size }
        elseif ($f.Name -eq "target") { $rustSize += $size }
        else { $pySize += $size }
    }
    
    $subTotal = $jsSize + $rustSize + $pySize
    $grandTotal += $subTotal
    
    if ($subTotal -gt 0) {
        $report += [PSCustomObject]@{
            Categoria        = $cat
            "Node_JS(GB)"    = [math]::Round($jsSize / 1GB, 2)
            "Rust_Build(GB)" = [math]::Round($rustSize / 1GB, 2)
            "Py_Venv(GB)"    = [math]::Round($pySize / 1GB, 2)
            "TOTAL(GB)"      = [math]::Round($subTotal / 1GB, 2)
        }
    }
}

$report | Sort-Object "TOTAL(GB)" -Descending | Format-Table -AutoSize
Write-Host "GANHO TOTAL POSSIVEL: $([math]::Round($grandTotal / 1GB, 2)) GB" -ForegroundColor Green

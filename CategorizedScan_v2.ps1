$ErrorActionPreference = "SilentlyContinue"
$root = "c:\Users\João\Desktop\PROJETOS"
$categories = @("00_ECOSYSTEM_COMERCIAL", "01_CORE_SYSTEMS", "02_ORGANIZATIONS", "03_AI_AGENTS", "04_DEVELOPER_TOOLS", "05_PLATFORMS", "06_UTILITIES", "07_RESEARCH", "08_PROFILE", "GUARDRIVE", "_SCRIPTS")

Write-Host "=== CATEGORIZED DEV-BLOAT SCAN (v2) ===" -ForegroundColor Cyan
$report = @()

foreach ($catName in $categories) {
    # Manual path joining to avoid Join-JoinPath typo or other issues
    $catPath = "$root\$catName"
    if (-not (Test-Path $catPath)) { continue }
    
    Write-Host "Scanning $catName ..."
    $bloat = Get-ChildItem -Path $catPath -Recurse -Directory -Force -ErrorAction SilentlyContinue | Where-Object { 
        $_.Name -eq "node_modules" -or 
        $_.Name -eq "target" -or 
        $_.Name -eq "venv" -or
        $_.Name -eq ".venv" -or
        $_.Name -eq "dist" -or
        $_.Name -eq "build"
    }
    
    foreach ($b in $bloat) {
        if ($b.FullName -notmatch "node_modules.*node_modules") {
            $size = Get-ChildItem $b.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
            if ($size.Sum -gt 1MB) {
                $report += [PSCustomObject]@{
                    Category = $catName
                    Project  = $b.Parent.Name
                    Type     = $b.Name
                    SizeMB   = [math]::Round($size.Sum / 1MB, 2)
                }
            }
        }
    }
}

$report | Sort-Object SizeMB -Descending | Format-Table -AutoSize

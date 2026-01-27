$ErrorActionPreference = "SilentlyContinue"
$root = "c:\Users\João\Desktop\PROJETOS"
$categories = Get-ChildItem $root -Directory | Where-Object { $_.Name -match "^\d+|GUARDRIVE|_SCRIPTS" }

Write-Host "=== CATEGORIZED DEV-BLOAT SCAN ===" -ForegroundColor Cyan
$report = @()

foreach ($cat in $categories) {
    Write-Host "Scanning $($cat.Name)..." -NoNewline
    $bloat = Get-ChildItem $cat.FullName -Recurse -Directory -Force -ErrorAction SilentlyContinue | Where-Object { 
        $_.Name -eq "node_modules" -or 
        $_.Name -eq "target" -or 
        $_.Name -eq "venv" -or
        $_.Name -eq ".venv" -or
        $_.Name -eq "dist" -or
        $_.Name -eq "build"
    }
    
    foreach ($b in $bloat) {
        # Only count if it's not nested inside another bloat folder (like node_modules/something/node_modules)
        if ($b.FullName -notmatch "node_modules.*node_modules") {
            $size = Get-ChildItem $b.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
            if ($size.Sum -gt 1MB) {
                $report += [PSCustomObject]@{
                    Category = $cat.Name
                    Project  = $b.Parent.Name
                    Type     = $b.Name
                    SizeMB   = [math]::Round($size.Sum / 1MB, 2)
                    FullPath = $b.FullName
                }
            }
        }
    }
    Write-Host " Done."
}

$report | Sort-Object SizeMB -Descending | Format-Table -AutoSize

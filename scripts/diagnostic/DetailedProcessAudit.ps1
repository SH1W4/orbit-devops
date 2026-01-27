$ErrorActionPreference = "SilentlyContinue"

Write-Host "=== ANALISE CIRURGICA DE PROCESSOS (8GB RAM) ===" -ForegroundColor Cyan
$report = @()

# Pegar todos os processos com informacoes de empresa e titulo
$procs = Get-Process | Select-Object Name, Id, WorkingSet, @{Name = 'Company'; Expression = { $_.Company } }, @{Name = 'Description'; Expression = { $_.Description } } | Sort-Object WorkingSet -Descending

Write-Host "--- TOP 30 CONSUMIDORES DETALHADOS ---" -ForegroundColor Yellow
$p30 = $procs | Select-Object -First 30
foreach ($p in $p30) {
    $mb = [math]::Round($p.WorkingSet / 1MB, 2)
    Write-Host "- $($p.Name) [$mb MB] : $($p.Description) ($($p.Company))"
}

Write-Host "`n--- FOCO: CLUSTER ACER (MANUTENCAO/BLOATWARE) ---" -ForegroundColor Yellow
$acer = $procs | Where-Object { $_.Name -match "Acer" -or $_.Company -match "Acer" -or $_.Description -match "Acer" }
if ($acer) {
    foreach ($a in $acer) {
        $mb = [math]::Round($a.WorkingSet / 1MB, 2)
        Write-Host "- $($a.Name) [$mb MB] : $($a.Description)"
    }
}
else {
    Write-Host "Nenhum processo Acer encontrado nos top ativos."
}

Write-Host "`n--- FOCO: PROCESSOS DO WINDOWS (SISTEMA) ---" -ForegroundColor Yellow
$winTargets = @("wsappx", "System", "ShellExperienceHost", "SearchHost", "SgrmBroker", "MsMpEng")
foreach ($t in $winTargets) {
    $matched = $procs | Where-Object { $_.Name -eq $t }
    if ($matched) {
        $mb = [math]::Round(($matched | Measure-Object WorkingSet -Sum).Sum / 1MB, 2)
        Write-Host "- $t : $mb MB (Essencial para o SO)"
    }
}

Write-Host "`n--- FOCO: DESENVOLVIMENTO (NODE/PYTHON/LANGUAGE) ---" -ForegroundColor Yellow
$dev = $procs | Where-Object { $_.Name -match "node|python|language_server|code" }
foreach ($d in $dev) {
    $mb = [math]::Round($d.WorkingSet / 1MB, 2)
    Write-Host "- $($d.Name) [$mb MB] : $($d.Description)"
}

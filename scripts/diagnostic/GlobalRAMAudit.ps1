$ErrorActionPreference = "SilentlyContinue"

Write-Host "=== AUDITORIA GLOBAL DE MEMORIA (360 GRAUS) ===" -ForegroundColor Cyan
Write-Host "Iniciando varredura profunda em Processos, Servicos e Bloatware...`n"

# 1. Total de Processos por Empresa/Fabricante (Cluster de Bloatware)
Write-Host "--- Consumo por Fabricante/Cluster ---" -ForegroundColor Yellow
$allProcs = Get-Process
$clusters = @{
    "ACER (Fabricante)"            = "Acer*"
    "MICROSOFT (System/Edge)"      = "msedge*", "Search*", "Shell*", "Explorer*"
    "DEVELOPER (VSCode/Node/Git)"  = "code*", "node*", "git*", "language_server*"
    "SEGURANCA (Windows Defender)" = "MsMpEng*", "NisSrv*"
    "DOCKER/WSL"                   = "docker*", "vmmem*"
}

foreach ($c in $clusters.Keys) {
    $matched = Get-Process -Name $clusters[$c]
    if ($matched) {
        $size = ($matched | Measure-Object WorkingSet -Sum).Sum / 1MB
        Write-Host "$c : $([math]::Round($size, 2)) MB ($($matched.Count) processos)"
    }
}

# 2. Servicos do Windows Ativos (Top 10 por Memoria via Svchost)
Write-Host "`n--- Servicos Pesados (Backstage) ---" -ForegroundColor Yellow
# Nota: Svchosts agrupam servicos, vamos ver os maiores
Get-Process svchost | Sort-Object WorkingSet -Descending | Select-Object -First 5 | 
ForEach-Object {
    $mb = [math]::Round($_.WorkingSet / 1MB, 2)
    Write-Host "Host de Servico (PID $($_.Id)): $mb MB"
}

# 3. Processos "Fantasmas" (Muitas Threads ou Handles)
# Processos que nao usam muita RAM mas 'poluem' o agendador e kernel
Write-Host "`n--- Processos com Alta Atividade Interna (Threads/Handles) ---" -ForegroundColor Yellow
Get-Process | Sort-Object Handles -Descending | Select-Object -First 5 | 
Select-Object Name, Handles, Threads | Format-Table -AutoSize

# 4. Detalhamento de TODOS os Processos (Resumo estatistico)
Write-Host "`n--- Estatistica de Processos ---" -ForegroundColor Yellow
$totalCount = (Get-Process).Count
$systemCount = (Get-Process | Where-Object { $_.Company -match "Microsoft" }).Count
$otherCount = $totalCount - $systemCount
Write-Host "Total de Processos Rodando: $totalCount"
Write-Host "Processos Microsoft/Sistema: $systemCount"
Write-Host "Processos de Terceiros/Apps: $otherCount"

# 5. Estado da Memoria Virtual (Commit Charge)
Write-Host "`n--- Memoria Virtual (Commit Charge) ---" -ForegroundColor Yellow
$os = Get-CimInstance Win32_OperatingSystem
$totalPaging = [math]::Round($os.SizeStoredInPagingFiles / 1024, 2)
$freePaging = [math]::Round($os.FreeSpaceInPagingFiles / 1024, 2)
Write-Host "Arquivo de Pagina (Virtual): $totalPaging MB"
Write-Host "Espaco Livre em Disco para RAM Virtual: $freePaging MB"

Write-Host "`n================================================"

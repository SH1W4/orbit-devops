$ErrorActionPreference = "SilentlyContinue"

Write-Host "=== AUDITORIA DE CONSUMO DE RAM ===" -ForegroundColor Cyan
Write-Host "Coletando dados de memória em tempo real...`n"

# 1. Top 15 processos por Working Set (RAM Física)
Write-Host "--- Top 15 Processos (RAM Fisica) ---" -ForegroundColor Yellow
Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 15 | 
Select-Object Name, @{Name = 'RAM(MB)'; Expression = { [math]::Round($_.WorkingSet / 1MB, 2) } }, Id | 
Format-Table -AutoSize

# 2. Resumo por Categoria (Navegador, VSCode, Docker)
Write-Host "`n--- Resumo por Grandes Grupos ---" -ForegroundColor Yellow
$groups = @("chrome", "msedge", "code", "docker", "vmmem", "node", "python")
foreach ($g in $groups) {
    $p = Get-Process -Name "$g*" -ErrorAction SilentlyContinue
    if ($p) {
        $total = ($p | Measure-Object WorkingSet -Sum).Sum
        Write-Host "$($g.ToUpper()): $([math]::Round($total / 1MB, 2)) MB ($($p.Count) processos)"
    }
}

# 3. Status de Memoria do Sistema
Write-Host "`n--- Status Geral da Memoria ---" -ForegroundColor Yellow
$mem = Get-CimInstance Win32_OperatingSystem
$total = [math]::Round($mem.TotalVisibleMemorySize / 1KB, 2)
$free = [math]::Round($mem.FreePhysicalMemory / 1KB, 2)
$used = $total - $free
$percent = [math]::Round(($used / $total) * 100, 1)

Write-Host "Total Instalada: $total MB"
Write-Host "Em Uso: $used MB ($percent%)"
Write-Host "Livre: $free MB"

# 4. Verificar se o WSL/Docker esta comendo RAM (vmmem)
$vmmem = Get-Process -Name vmmem* -ErrorAction SilentlyContinue
if ($vmmem) {
    Write-Host "`n[AVISO] Docker/WSL (vmmem) está usando $([math]::Round(($vmmem | Measure-Object WorkingSet -Sum).Sum / 1MB, 2)) MB" -ForegroundColor Cyan
}

Write-Host "`n=================================="

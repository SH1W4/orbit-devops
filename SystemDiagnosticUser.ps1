
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$reportPath = ".\diagnostico_sistema_$timestamp.txt"

function Write-Log {
    param($Message)
    $line = "[$(Get-Date -Format 'HH:mm:ss')] $Message"
    Write-Output $line
    $line | Out-File -FilePath $reportPath -Append -Encoding utf8
}

Write-Log "=== INICIANDO DIAGNÓSTICO COMPLETO (USER MODE) ==="

# 1. OS & Uptime
$os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
if ($os) {
    Write-Log "OS: $($os.Caption) ($($os.OSArchitecture))"
    Write-Log "Versão: $($os.Version)"
    Write-Log "Último Boot: $($os.LastBootUpTime)"
}

# 2. CPU & Memory
try {
    $cpu = Get-CimInstance Win32_Processor -ErrorAction Stop
    Write-Log "CPU: $($cpu.Name)"
    
    $mem = Get-CimInstance Win32_ComputerSystem
    $totalMem = [math]::Round($mem.TotalPhysicalMemory / 1GB, 2)
    
    # Get free memory
    $osInfo = Get-CimInstance Win32_OperatingSystem
    $freeMem = [math]::Round($osInfo.FreePhysicalMemory / 1024 / 1024, 2) # GB
    $usedMemPct = [math]::Round((($totalMem - $freeMem) / $totalMem) * 100, 1)
    
    Write-Log "Memória: Total $totalMem GB | Livre $freeMem GB | Uso: $usedMemPct%"
}
catch {
    Write-Log "Erro ao verificar Hardware: $_"
}

# 3. Disk Space
Write-Log "`n--- DISCOS ---"
Get-Volume | Where-Object { $_.DriveLetter } | ForEach-Object {
    $free = [math]::Round($_.SizeRemaining / 1GB, 2)
    $total = [math]::Round($_.Size / 1GB, 2)
    $pctFree = [math]::Round(($free / $total) * 100, 1)
    
    $status = "OK"
    if ($pctFree -lt 10) { $status = "CRÍTICO (<10% livre)" }
    elseif ($pctFree -lt 20) { $status = "ALERTA (<20% livre)" }
    
    Write-Log "Drive $($_.DriveLetter): $free GB livres de $total GB ($pctFree%) - $status"
}

# 4. Network
Write-Log "`n--- REDE ---"
try {
    $test = Test-Connection -TargetName "google.com" -Count 1 -Quiet
    Write-Log ("Internet (google.com): " + (if ($test) { 'Conectado' }else { 'Falha' }))
}
catch {
    Write-Log ("Erro no teste de rede: " + $_)
}

# 5. Top Consumers
Write-Log "`n--- TOP PROCESSOS (CPU) ---"
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | ForEach-Object {
    Write-Log ("$($_.ProcessName): " + [math]::Round($_.CPU, 1) + "s CPU")
}

Write-Log "`n--- TOP PROCESSOS (RAM) ---"
Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5 | ForEach-Object {
    Write-Log ("$($_.ProcessName): " + [math]::Round($_.WorkingSet / 1MB, 0) + " MB")
}

# 6. Dev Tools
Write-Log "`n--- AMBIENTE DEV ---"
$tools = @("git", "python", "node", "docker", "code", "rustc")
foreach ($t in $tools) {
    try {
        $cmd = Get-Command $t -ErrorAction SilentlyContinue
        if ($cmd) {
            Write-Log ("${t}: Instalado (" + $cmd.Source + ")")
        }
        else {
            Write-Log ("${t}: NÃO encontrado")
        }
    }
    catch {}
}

Write-Log "`nDiagnostico Concluido."

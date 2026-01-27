# Diagnóstico do Sistema Windows
# Versão: 1.0

# Verificar se está rodando como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Elevando privilégios para administrador..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Configuração de codificação
$null = cmd /c chcp 65001
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Configuração do relatório
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$reportPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "diagnostico_sistema_$timestamp.txt"

# Função para escrever log
function Write-Log {
    param(
        [string]$Message,
        [string]$Type = "INFO"
    )
    
    $time = Get-Date -Format "HH:mm:ss"
    $line = "[$time] [$Type] $Message"
    
    # Escrever no arquivo
    try {
        Add-Content -Path $reportPath -Value $line -Encoding UTF8
    }
    catch {
        Write-Warning "Erro ao escrever no arquivo: $_"
    }
    
    # Mostrar na tela com cores
    switch ($Type) {
        "ERRO"    { Write-Host $line -ForegroundColor Red }
        "AVISO"   { Write-Host $line -ForegroundColor Yellow }
        "SUCESSO" { Write-Host $line -ForegroundColor Green }
        default   { Write-Host $line }
    }
}

# Início do diagnóstico
Clear-Host
Write-Log "Iniciando diagnóstico do sistema" -Type "SUCESSO"
Write-Log "Relatório será salvo em: $reportPath" -Type "INFO"

# 1. Sistema Operacional
Write-Log "`nVerificando Sistema Operacional..." -Type "INFO"
try {
    $os = Get-CimInstance Win32_OperatingSystem
    Write-Log "Sistema: $($os.Caption)" -Type "SUCESSO"
    Write-Log "Versão: $($os.Version)" -Type "SUCESSO"
    Write-Log "Arquitetura: $($os.OSArchitecture)" -Type "SUCESSO"
    Write-Log "Último Boot: $($os.LastBootUpTime)" -Type "SUCESSO"
}
catch {
    Write-Log "Erro ao verificar sistema operacional: $_" -Type "ERRO"
}

# 2. Hardware
Write-Log "`nVerificando Hardware..." -Type "INFO"
try {
    # CPU
    $cpu = Get-CimInstance Win32_Processor
    Write-Log "Processador: $($cpu.Name)" -Type "SUCESSO"
    Write-Log "Núcleos Físicos: $($cpu.NumberOfCores)" -Type "SUCESSO"
    Write-Log "Threads: $($cpu.NumberOfLogicalProcessors)" -Type "SUCESSO"
    
    # Memória
    $totalMemory = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum
    $availableMemory = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory * 1KB
    $totalMemoryGB = [math]::Round($totalMemory / 1GB, 2)
    $availableMemoryGB = [math]::Round($availableMemory / 1GB, 2)
    $usedMemoryPercent = [math]::Round(($totalMemory - $availableMemory) / $totalMemory * 100, 2)
    
    Write-Log "`nMemória RAM:" -Type "SUCESSO"
    Write-Log "Total: $totalMemoryGB GB" -Type "INFO"
    Write-Log "Disponível: $availableMemoryGB GB" -Type "INFO"
    Write-Log "Em uso: $usedMemoryPercent%" -Type $(if ($usedMemoryPercent -gt 80) { "AVISO" } else { "INFO" })
}
catch {
    Write-Log "Erro ao verificar hardware: $_" -Type "ERRO"
}

# 3. Discos
Write-Log "`nVerificando Discos..." -Type "INFO"
try {
    Get-Volume | Where-Object { $_.DriveLetter } | ForEach-Object {
        $free = [math]::Round($_.SizeRemaining / 1GB, 2)
        $total = [math]::Round($_.Size / 1GB, 2)
        $used = [math]::Round(100 - ($_.SizeRemaining / $_.Size * 100), 2)
        
        Write-Log "Drive $($_.DriveLetter):" -Type "SUCESSO"
        Write-Log "  Total: $total GB" -Type "INFO"
        Write-Log "  Livre: $free GB" -Type "INFO"
        Write-Log "  Uso: $used%" -Type $(if ($used -gt 90) { "AVISO" } else { "INFO" })
    }
}
catch {
    Write-Log "Erro ao verificar discos: $_" -Type "ERRO"
}

# 4. Serviços Críticos
Write-Log "`nVerificando Serviços Críticos..." -Type "INFO"
$servicosCriticos = @(
    "wuauserv"     # Windows Update
    "WinDefend"    # Windows Defender
    "wscsvc"       # Security Center
    "RpcSs"        # Remote Procedure Call
    "EventLog"     # Event Log
)

foreach ($servico in $servicosCriticos) {
    try {
        $status = Get-Service -Name $servico -ErrorAction Stop
        Write-Log "$($status.DisplayName): $($status.Status)" -Type $(
            if ($status.Status -eq "Running") { "SUCESSO" }
            else { "AVISO" }
        )
    }
    catch {
        Write-Log "Erro ao verificar serviço $servico" -Type "ERRO"
    }
}

# 5. Finalização
Write-Log "`nDiagnóstico concluído" -Type "SUCESSO"

# Verificar se o relatório foi gerado
if (Test-Path $reportPath) {
    $fileInfo = Get-Item $reportPath
    Write-Log "`nRelatório gerado com sucesso:" -Type "SUCESSO"
    Write-Log "Caminho: $($fileInfo.FullName)" -Type "INFO"
    Write-Log "Tamanho: $([math]::Round($fileInfo.Length/1KB, 2)) KB" -Type "INFO"
    
    # Tentar abrir o relatório
    try {
        Invoke-Item $reportPath
    }
    catch {
        Write-Log "Não foi possível abrir o relatório automaticamente" -Type "AVISO"
    }
}

Write-Host "`nPressione qualquer tecla para sair..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


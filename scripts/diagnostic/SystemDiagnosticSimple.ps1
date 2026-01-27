#Requires -RunAsAdministrator

# Configuração de codificação para UTF-8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Definir caminho do relatório
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$reportPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "diagnostico_sistema_$timestamp.txt"

# Função para escrever no relatório
function Write-Report {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [string]$Type = "INFO"
    )

    $time = Get-Date -Format "HH:mm:ss"
    $line = "[$time] [$Type] $Message"
    
    try {
        # Escrever diretamente no arquivo usando .NET para garantir codificação
        [System.IO.File]::AppendAllText($reportPath, $line + "`r`n", [System.Text.Encoding]::UTF8)
        
        # Mostrar na tela com cores
        switch ($Type) {
            "ERRO"    { Write-Host $line -ForegroundColor Red }
            "AVISO"   { Write-Host $line -ForegroundColor Yellow }
            "SUCESSO" { Write-Host $line -ForegroundColor Green }
            default   { Write-Host $line }
        }
    }
    catch {
        Write-Host "ERRO ao escrever no arquivo: $_" -ForegroundColor Red
        exit 1
    }
}

# Início do diagnóstico
Write-Report "Iniciando diagnóstico do sistema"
Write-Report "Relatório será salvo em: $reportPath" -Type "SUCESSO"

# 1. Sistema Operacional
Write-Report "`r`n=== Sistema Operacional ===" -Type "INFO"
try {
    $os = Get-CimInstance Win32_OperatingSystem
    Write-Report "Nome: $($os.Caption)" -Type "SUCESSO"
    Write-Report "Versão: $($os.Version)" -Type "SUCESSO"
    Write-Report "Arquitetura: $($os.OSArchitecture)" -Type "SUCESSO"
    Write-Report "Último Boot: $($os.LastBootUpTime)" -Type "SUCESSO"
}
catch {
    Write-Report "Erro ao obter informações do sistema: $_" -Type "ERRO"
}

# 2. Hardware
Write-Report "`r`n=== Hardware ===" -Type "INFO"
try {
    # CPU
    $cpu = Get-CimInstance Win32_Processor
    Write-Report "Processador: $($cpu.Name)" -Type "SUCESSO"
    Write-Report "Núcleos: $($cpu.NumberOfCores)" -Type "SUCESSO"

    # Memória
    $memory = Get-CimInstance Win32_ComputerSystem
    $totalMemoryGB = [math]::Round($memory.TotalPhysicalMemory / 1GB, 2)
    Write-Report "Memória Total: $totalMemoryGB GB" -Type "SUCESSO"
}
catch {
    Write-Report "Erro ao obter informações de hardware: $_" -Type "ERRO"
}

# 3. Discos
Write-Report "`r`n=== Discos ===" -Type "INFO"
try {
    Get-Volume | Where-Object {$_.DriveLetter} | ForEach-Object {
        $free = [math]::Round($_.SizeRemaining / 1GB, 2)
        $total = [math]::Round($_.Size / 1GB, 2)
        $used = [math]::Round(100 - (($_.SizeRemaining / $_.Size) * 100), 2)
        
        if ($used -gt 90) {
            Write-Report "Drive $($_.DriveLetter): $free GB livres de $total GB ($used% usado)" -Type "AVISO"
        } else {
            Write-Report "Drive $($_.DriveLetter): $free GB livres de $total GB ($used% usado)" -Type "SUCESSO"
        }
    }
}
catch {
    Write-Report "Erro ao obter informações dos discos: $_" -Type "ERRO"
}

# 4. Serviços Críticos
Write-Report "`r`n=== Serviços Críticos ===" -Type "INFO"
$servicosImportantes = @(
    "wuauserv",      # Windows Update
    "WinDefend",     # Windows Defender
    "RpcSs",         # Remote Procedure Call
    "EventLog"       # Windows Event Log
)

foreach ($servico in $servicosImportantes) {
    try {
        $status = Get-Service -Name $servico -ErrorAction Stop
        if ($status.Status -eq "Running") {
            Write-Report "$($status.DisplayName): Em execução" -Type "SUCESSO"
        } else {
            Write-Report "$($status.DisplayName): Parado" -Type "AVISO"
        }
    }
    catch {
        Write-Report "Erro ao verificar serviço $servico" -Type "ERRO"
    }
}

# Verificar se o relatório foi criado com sucesso
if (Test-Path $reportPath) {
    $fileInfo = Get-Item $reportPath
    Write-Report "`r`n=== Relatório Gerado com Sucesso ===" -Type "SUCESSO"
    Write-Report "Caminho: $($fileInfo.FullName)" -Type "SUCESSO"
    Write-Report "Tamanho: $([math]::Round($fileInfo.Length/1KB, 2)) KB" -Type "SUCESSO"
    Write-Report "Hora: $($fileInfo.LastWriteTime)" -Type "SUCESSO"
    
    # Testar leitura do arquivo
    try {
        $null = Get-Content $reportPath -Encoding UTF8 -ErrorAction Stop
        Write-Report "Verificação de leitura: OK" -Type "SUCESSO"
    }
    catch {
        Write-Report "Erro ao ler o arquivo gerado: $_" -Type "ERRO"
    }
}
else {
    Write-Report "ERRO: Falha ao gerar relatório!" -Type "ERRO"
    exit 1
}

Write-Report "Diagnóstico concluído" -Type "SUCESSO"
exit 0


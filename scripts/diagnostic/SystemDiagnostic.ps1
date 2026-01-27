#Requires -RunAsAdministrator
# SystemDiagnostic.ps1
# Script de diagnóstico completo do sistema Windows
# Versão: 2.0

# Configuração inicial
$ErrorActionPreference = "Continue"
$ProgressPreference = "Continue"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# Configuração do diretório de relatórios
$userDesktop = [Environment]::GetFolderPath("Desktop")
$reportDir = Join-Path $userDesktop "SystemDiagnostics"
$reportPath = Join-Path $reportDir "SystemDiagnostic_Report_$timestamp.txt"

# Variáveis globais para tracking
$global:recommendations = @()
$global:errorCount = 0
$global:warningCount = 0
$global:totalSteps = 8  # Número total de etapas de diagnóstico
$global:currentStep = 0
$global:issuesSummary = @{}

# Criar diretório de relatórios se não existir
if (-not (Test-Path $reportDir)) {
    try {
        New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
        Write-Host "Diretório de relatórios criado em: $reportDir" -ForegroundColor Green
    }
    catch {
        Write-Error "Erro ao criar diretório de relatórios: $_"
        exit 1
    }
}

# Funções de Suporte
function Write-Report {
    param(
        [string]$Message,
        [string]$Type = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Type] $Message"
    
    switch ($Type) {
        "ERROR" {
            Write-Host $logMessage -ForegroundColor Red
            $global:errorCount++
        }
        "WARNING" {
            Write-Host $logMessage -ForegroundColor Yellow
            $global:warningCount++
        }
        "SUCCESS" {
            Write-Host $logMessage -ForegroundColor Green
        }
        default {
            Write-Host $logMessage
        }
    }
    
    Add-Content -Path $reportPath -Value $logMessage -Encoding UTF8
}

function Show-Progress {
    param(
        [string]$Activity,
        [string]$Status
    )
    $global:currentStep++
    $percentComplete = [math]::Round(($global:currentStep / $global:totalSteps) * 100)
    Write-Progress -Activity $Activity -Status $Status -PercentComplete $percentComplete
}

function Write-SectionHeader {
    param([string]$Title)
    $header = "`n=== $Title ==="
    Write-Report $header
    Write-Report ("=" * $header.Length)
}

function Add-Recommendation {
    param(
        [string]$Category,
        [string]$Issue,
        [string]$Recommendation,
        [string]$Severity = "Info"
    )
    if (-not $global:issuesSummary.ContainsKey($Category)) {
        $global:issuesSummary[$Category] = @()
    }
    $global:issuesSummary[$Category] += @{
        Issue = $Issue
        Recommendation = $Recommendation
        Severity = $Severity
        Timestamp = Get-Date
    }
    $global:recommendations += $Recommendation
}

# Início do diagnóstico
Write-Report "`nIniciando diagnóstico do sistema..." -Type "INFO"
Write-Report "Relatório será salvo em: $reportPath" -Type "INFO"
Write-Report "Data/Hora: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")`n" -Type "INFO"

# 1. Sistema Operacional e Hardware
Show-Progress -Activity "Sistema Operacional" -Status "Coletando informações básicas"
Write-SectionHeader "Sistema Operacional e Hardware"
try {
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    $ram = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
    
    Write-Report "Sistema: $($os.Caption) $($os.Version)"
    Write-Report "Arquitetura: $($os.OSArchitecture)"
    Write-Report "Último Boot: $($os.LastBootUpTime)"
    Write-Report "CPU: $($cpu.Name)"
    Write-Report "Memória Total: $([math]::Round($ram.Sum/1GB, 2)) GB"
    
    # Verificação de espaço em disco
    Get-Volume | Where-Object {$_.DriveLetter} | ForEach-Object {
        $free = [math]::Round($_.SizeRemaining/1GB, 2)
        $total = [math]::Round($_.Size/1GB, 2)
        $percentFree = [math]::Round(($_.SizeRemaining/$_.Size) * 100, 2)
        Write-Report "Drive $($_.DriveLetter): $free GB livre de $total GB ($percentFree% livre)"
        
        if ($percentFree -lt 10) {
            Add-Recommendation -Category "Storage" `
                             -Issue "Pouco espaço livre no drive $($_.DriveLetter)" `
                             -Recommendation "Libere espaço no drive $($_.DriveLetter) (apenas $percentFree% livre)" `
                             -Severity "Warning"
        }
    }
}
catch {
    Write-Report "Erro ao coletar informações do sistema: $_" -Type "ERROR"
}

# 2. Serviços Críticos
Show-Progress -Activity "Serviços" -Status "Verificando serviços críticos"
Write-SectionHeader "Serviços Críticos"
$criticalServices = @(
    @{Name="wuauserv"; Display="Windows Update"},
    @{Name="WinDefend"; Display="Windows Defender"},
    @{Name="wscsvc"; Display="Security Center"},
    @{Name="RpcSs"; Display="Remote Procedure Call"},
    @{Name="DcomLaunch"; Display="DCOM Server Process"},
    @{Name="EventLog"; Display="Windows Event Log"}
)

foreach ($service in $criticalServices) {
    try {
        $svc = Get-Service -Name $service.Name -ErrorAction Stop
        Write-Report "$($service.Display): $($svc.Status)"
        
        if ($svc.Status -ne "Running") {
            Add-Recommendation -Category "Services" `
                             -Issue "Serviço $($service.Display) não está em execução" `
                             -Recommendation "Verifique e inicie o serviço $($service.Display)" `
                             -Severity "Warning"
        }
    }
    catch {
        Write-Report "Erro ao verificar serviço $($service.Display): $_" -Type "ERROR"
    }
}

# 3. Performance e Recursos
Show-Progress -Activity "Performance" -Status "Analisando uso de recursos"
Write-SectionHeader "Performance e Recursos"
try {
    # CPU
    $cpuLoad = (Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction Stop).CounterSamples.CookedValue
    Write-Report "Uso de CPU: $([math]::Round($cpuLoad, 2))%"
    
    if ($cpuLoad -gt 80) {
        Add-Recommendation -Category "Performance" `
                         -Issue "Alto uso de CPU" `
                         -Recommendation "Investigue processos consumindo muito CPU" `
                         -Severity "Warning"
    }
    
    # Memória
    $memory = Get-Counter '\Memory\Available MBytes' -ErrorAction Stop
    $availableMemoryGB = [math]::Round($memory.CounterSamples.CookedValue/1024, 2)
    $totalMemoryGB = [math]::Round(((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory)/1GB, 2)
    $usedMemoryPercent = [math]::Round((($totalMemoryGB - $availableMemoryGB)/$totalMemoryGB) * 100, 2)
    
    Write-Report "Memória Disponível: $availableMemoryGB GB de $totalMemoryGB GB ($usedMemoryPercent% em uso)"
    
    if ($usedMemoryPercent -gt 80) {
        Add-Recommendation -Category "Performance" `
                         -Issue "Alto uso de memória" `
                         -Recommendation "Investigue processos consumindo muita memória" `
                         -Severity "Warning"
    }
    
    # Top 5 processos por CPU
    Write-Report "`nTop 5 Processos por CPU:"
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | ForEach-Object {
        Write-Report "  $($_.ProcessName): $([math]::Round($_.CPU, 2))% CPU, $([math]::Round($_.WorkingSet/1MB, 2)) MB RAM"
    }
}
catch {
    Write-Report "Erro ao coletar métricas de performance: $_" -Type "ERROR"
}

# 4. Rede
Show-Progress -Activity "Rede" -Status "Verificando conectividade"
Write-SectionHeader "Rede"
try {
    # Adaptadores de rede
    Get-NetAdapter | Where-Object Status -eq "Up" | ForEach-Object {
        Write-Report "Adaptador: $($_.Name)"
        Write-Report "  Status: $($_.Status)"
        Write-Report "  Velocidade: $($_.LinkSpeed)"
        
        $ipConfig = Get-NetIPConfiguration -InterfaceIndex $_.ifIndex -Detailed
        Write-Report "  IP: $($ipConfig.IPv4Address.IPAddress)"
        Write-Report "  Gateway: $($ipConfig.IPv4DefaultGateway.NextHop)"
        Write-Report "  DNS: $($ipConfig.DNSServer.ServerAddresses -join ', ')"
    }
    
    # Teste de conectividade
    $testSites = @("8.8.8.8", "google.com", "github.com")
    foreach ($site in $testSites) {
        $test = Test-Connection -TargetName $site -Count 1 -Quiet
        Write-Report "Conectividade com $site: $(if($test){'OK'}else{'Falha'})"
        
        if (-not $test) {
            Add-Recommendation -Category "Network" `
                             -Issue "Falha na conexão com $site" `
                             -Recommendation "Verifique sua conexão com a internet" `
                             -Severity "Warning"
        }
    }
}
catch {
    Write-Report "Erro ao verificar rede: $_" -Type "ERROR"
}

# 5. Drivers e Dispositivos
Show-Progress -Activity "Drivers" -Status "Verificando estado dos drivers"
Write-SectionHeader "Drivers e Dispositivos"
try {
    $problemDrivers = Get-WmiObject Win32_PnPEntity | Where-Object {$_.ConfigManagerErrorCode -ne 0}
    
    if ($problemDrivers) {
        foreach ($driver in $problemDrivers) {
            Write-Report "Problema encontrado: $($driver.Name)" -Type "WARNING"
            Write-Report "  ID: $($driver.DeviceID)"
            Write-Report "  Código de Erro: $($driver.ConfigManagerErrorCode)"
            
            Add-Recommendation -Category "Drivers" `
                             -Issue "Problema com driver: $($driver.Name)" `
                             -Recommendation "Atualize ou reinstale o driver: $($driver.Name)" `
                             -Severity "Warning"
        }
    }
    else {
        Write-Report "Nenhum problema com drivers encontrado" -Type "SUCCESS"
    }
}
catch {
    Write-Report "Erro ao verificar drivers: $_" -Type "ERROR"
}

# 6. Ambiente de Desenvolvimento
Show-Progress -Activity "Dev Environment" -Status "Verificando ferramentas de desenvolvimento"
Write-SectionHeader "Ambiente de Desenvolvimento"
try {
    # Verificar ferramentas comuns
    $devTools = @(
        @{Name="Git"; Command="git --version"},
        @{Name="Python"; Command="python --version"},
        @{Name="Node.js"; Command="node --version"},
        @{Name="Docker"; Command="docker --version"},
        @{Name="VSCode"; Command="code --version"},
        @{Name="Rust"; Command="rustc --version"}
    )
    
    foreach ($tool in $devTools) {
        try {
            $version = Invoke-Expression $tool.Command 2>&1
            Write-Report "$($tool.Name): $version" -Type "SUCCESS"
        }
        catch {
            Write-Report "$($tool.Name) não encontrado" -Type "WARNING"
            Add-Recommendation -Category "Development" `
                             -Issue "$($tool.Name) não instalado" `
                             -Recommendation "Instale $($tool.Name) para desenvolvimento" `
                             -Severity "Info"
        }
    }
    
    # Verificar WSL
    try {
        $wslStatus = wsl --status 2>&1
        Write-Report "`nStatus WSL:"
        Write-Report $wslStatus
    }
    catch {
        Write-Report "WSL não instalado ou não configurado" -Type "WARNING"
        Add-Recommendation -Category "Development" `
                         -Issue "WSL não configurado" `
                         -Recommendation "Configure WSL para desenvolvimento Linux" `
                         -Severity "Info"
    }
    
    # Verificar variáveis de ambiente importantes
    $envVars = @("JAVA_HOME", "PYTHON_HOME", "NODE_HOME", "RUST_HOME", "PATH")
    Write-Report "`nVariáveis de Ambiente:"
    foreach ($var in $envVars) {
        $value = [Environment]::GetEnvironmentVariable($var)
        if ($value) {
            Write-Report "$var está configurado"
        }
        else {
            Write-Report "$var não está configurado" -Type "WARNING"
            if ($var -ne "PATH") {
                Add-Recommendation -Category "Environment" `
                                 -Issue "$var não configurado" `
                                 -Recommendation "Configure a variável de ambiente $var" `
                                 -Severity "Info"
            }
        }
    }
}
catch {
    Write-Report "Erro ao verificar ambiente de desenvolvimento: $_" -Type "ERROR"
}

# 7. Resumo e Recomendações
Show-Progress -Activity "Resumo" -Status "Gerando resumo e recomendações"
Write-SectionHeader "Resumo do Diagnóstico"

# Contagem de problemas
Write-Report "Total de Erros: $global:errorCount" -Type $(if ($global:errorCount -gt 0) { "ERROR" } else { "SUCCESS" })
Write-Report "Total de Avisos: $global:warningCount" -Type $(if ($global:warningCount -gt 0) { "WARNING" } else { "SUCCESS" })

# Resumo por categoria
Write-SectionHeader "Problemas por Categoria"
foreach ($category in $global:issuesSummary.Keys) {
    Write-Report "`nCategoria: $category"
    foreach ($issue in $global:issuesSummary[$category]) {
        Write-Report "- [$($issue.Severity)] $($issue.Issue)"
        Write-Report "  Recomendação: $($issue.Recommendation)"
    }
}

# 8. Finalização
Show-Progress -Activity "Finalização" -Status "Concluindo diagnóstico"
Write-SectionHeader "Conclusão"
Write-Report "Diagnóstico concluído em: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")" -Type "SUCCESS"
Write-Report "Relatório salvo em: $reportPath" -Type "SUCCESS"

# Remove a barra de progresso
Write-Progress -Activity "Diagnóstico" -Completed

exit 0

#Requires -RunAsAdministrator
# SystemDiagnostic.ps1
# Script de diagnóstico completo do sistema Windows
# Versão: 1.1

# Configuração inicial
$ErrorActionPreference = "Continue"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$reportPath = Join-Path $scriptPath "SystemDiagnostic_Report_$timestamp.txt"
$global:recommendations = @()
$global:errorCount = 0
$global:warningCount = 0

# Verifica permissões de escrita
try {
    $testFile = Join-Path $scriptPath "test_write.tmp"
    [System.IO.File]::WriteAllText($testFile, "Test")
    Remove-Item $testFile -Force
    Write-Host "Verificação de permissões de escrita: OK" -ForegroundColor Green
}
catch {
    Write-Error "Erro: Sem permissão de escrita no diretório $scriptPath"
    exit 1
}

# Função para mostrar progresso
function Write-Progress {
    param([string]$Status, [int]$PercentComplete)
    Write-Host "`r$Status - $PercentComplete%" -NoNewline
}

# Função melhorada para relatório
function Write-Report {
    param(
        [string]$Message,
        [string]$Type = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Type] $Message"
    
    switch ($Type) {
        "ERROR" {
            Write-Host $logMessage -ForegroundColor Red
            $global:errorCount++
        }
        "WARNING" {
            Write-Host $logMessage -ForegroundColor Yellow
            $global:warningCount++
        }
        "SUCCESS" {
            Write-Host $logMessage -ForegroundColor Green
        }
        default {
            Write-Host $logMessage
        }
    }
    
    Add-Content -Path $reportPath -Value $logMessage -Encoding UTF8
}

function Write-Report {
    param([string]$Message)
    Write-Host $Message
    Add-Content -Path $reportPath -Value $Message
}

function Add-Recommendation {
    param([string]$Recommendation)
    $global:recommendations += $Recommendation
}

function Write-SectionHeader {
    param([string]$Title)
    $header = "`n=== $Title ==="
    Write-Report $header
    Write-Report ("=" * $header.Length)
}

# 1. Informações do Sistema
Write-SectionHeader "Informações do Sistema"
try {
    $sysInfo = Get-ComputerInfo
    Write-Report "Sistema Operacional: $($sysInfo.WindowsProductName)"
    Write-Report "Versão: $($sysInfo.WindowsVersion)"
    Write-Report "Última Inicialização: $($sysInfo.OsLastBootUpTime)"
    Write-Report "Memória Total (GB): $([math]::Round($sysInfo.OsTotalVisibleMemorySize/1MB, 2))"
    Write-Report "Memória Livre (GB): $([math]::Round($sysInfo.OsFreePhysicalMemory/1MB, 2))"
} catch {
    Write-Report "ERRO ao coletar informações do sistema: $_"
    Add-Recommendation "Verifique permissões de acesso às informações do sistema"
}

# 2. Verificação de Disco
Write-SectionHeader "Estado dos Discos"
try {
    $disks = Get-Volume | Where-Object {$_.DriveLetter}
    foreach ($disk in $disks) {
        $freeSpace = [math]::Round($disk.SizeRemaining/1GB, 2)
        $totalSpace = [math]::Round($disk.Size/1GB, 2)
        $usedPercent = [math]::Round(($disk.Size - $disk.SizeRemaining)/$disk.Size * 100, 2)
        Write-Report "Drive $($disk.DriveLetter):"
        Write-Report "  - Espaço Total: $totalSpace GB"
        Write-Report "  - Espaço Livre: $freeSpace GB"
        Write-Report "  - Uso: $usedPercent%"
        
        if ($usedPercent -gt 90) {
            Add-Recommendation "Drive $($disk.DriveLetter): Espaço crítico ($usedPercent% usado). Considere liberar espaço"
        }
    }
} catch {
    Write-Report "ERRO ao verificar discos: $_"
}

# 3. Verificação de Serviços Críticos
Write-SectionHeader "Serviços Críticos"
$criticalServices = @(
    "wuauserv",      # Windows Update
    "WinDefend",     # Windows Defender
    "wscsvc",        # Security Center
    "RpcSs",         # Remote Procedure Call
    "DcomLaunch",    # DCOM Server
    "EventLog",      # Windows Event Log
    "Dhcp",          # DHCP Client
    "Dnscache",      # DNS Client
    "LanmanServer",  # Server
    "LanmanWorkstation" # Workstation
)

foreach ($service in $criticalServices) {
    try {
        $svc = Get-Service -Name $service -ErrorAction Stop
        Write-Report "$($svc.DisplayName): $($svc.Status)"
        
        if ($svc.Status -ne "Running") {
            Add-Recommendation "Serviço $($svc.DisplayName) não está em execução. Verificar configuração"
        }
    } catch {
        Write-Report "ERRO ao verificar serviço $service: $_"
        Add-Recommendation "Serviço $service não encontrado ou inacessível"
    }
}

# 4. Análise de Logs do Sistema
Write-SectionHeader "Logs de Sistema Críticos (Últimas 24h)"
try {
    $yesterday = (Get-Date).AddDays(-1)
    $criticalEvents = Get-WinEvent -FilterHashtable @{
        LogName='System','Application'
        Level=1,2
        StartTime=$yesterday
    } -ErrorAction Stop | Select-Object -First 50
    
    Write-Report "Eventos Críticos/Erro encontrados: $($criticalEvents.Count)"
    foreach ($event in $criticalEvents) {
        Write-Report "[$($event.TimeCreated)] [$($event.LevelDisplayName)] $($event.Message.Split([Environment]::NewLine)[0])"
    }
    
    if ($criticalEvents.Count -gt 10) {
        Add-Recommendation "Alto número de eventos críticos/erro nas últimas 24h. Análise detalhada recomendada"
    }
} catch {
    Write-Report "ERRO ao coletar logs do sistema: $_"
}

# 5. Verificação de Drivers com Problemas
Write-SectionHeader "Drivers com Problemas"
try {
    $problemDrivers = Get-WmiObject Win32_PnPEntity | Where-Object {$_.ConfigManagerErrorCode -ne 0}
    
    if ($problemDrivers) {
        foreach ($driver in $problemDrivers) {
            Write-Report "Dispositivo: $($driver.Name)"
            Write-Report "  - ID: $($driver.DeviceID)"
            Write-Report "  - Código de Erro: $($driver.ConfigManagerErrorCode)"
        }
        Add-Recommendation "Encontrados drivers com problemas. Atualize ou reinstale os drivers afetados"
    } else {
        Write-Report "Nenhum driver com problemas encontrado"
    }
} catch {
    Write-Report "ERRO ao verificar drivers: $_"
}

# 6. Verificação de Atualizações do Windows
Write-SectionHeader "Status das Atualizações do Windows"
try {
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()
    $pendingUpdates = $updateSearcher.Search("IsInstalled=0")
    
    Write-Report "Atualizações pendentes: $($pendingUpdates.Updates.Count)"
    if ($pendingUpdates.Updates.Count -gt 0) {
        Add-Recommendation "Existem $($pendingUpdates.Updates.Count) atualizações pendentes. Recomenda-se instalar"
    }
} catch {
    Write-Report "ERRO ao verificar atualizações: $_"
}

# 7. Verificação de Antivírus
Write-SectionHeader "Status do Antivírus"
try {
    $antiVirusProducts = Get-WmiObject -Namespace "root\SecurityCenter2" -Class AntiVirusProduct
    foreach ($av in $antiVirusProducts) {
        Write-Report "Produto: $($av.displayName)"
        Write-Report "  - Estado: $($av.productState)"
    }
    
    if (-not $antiVirusProducts) {
        Add-Recommendation "Nenhum antivírus detectado. Recomenda-se instalar uma solução de proteção"
    }
} catch {
    Write-Report "ERRO ao verificar antivírus: $_"
}

# 8. Recomendações Finais
Write-SectionHeader "Recomendações"
if ($global:recommendations.Count -eq 0) {
    Write-Report "Nenhum problema crítico encontrado"
} else {
    foreach ($rec in $global:recommendations) {
        Write-Report "- $rec"
    }
}

Write-Report "`nDiagnóstico concluído. Relatório salvo em: $reportPath"


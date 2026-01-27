# Script wrapper para execução do diagnóstico com elevação automática
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Função para logging
function Write-Log {
    param(
        [string]$Message,
        [string]$Type = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Type] $Message"
    
    switch ($Type) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage }
    }
}

# Verifica privilégios atuais
Write-Log "Verificando privilégios de administrador..." -Type "INFO"
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Se não estiver rodando como administrador, reinicia o script com elevação
if (-not $isAdmin) {
    try {
        Write-Log "Solicitando privilégios de administrador..." -Type "INFO"
        $scriptPath = $MyInvocation.MyCommand.Path
        $diagPath = Join-Path $PSScriptRoot "SystemDiagnostic.ps1"
        
        # Verifica se o arquivo de diagnóstico existe
        if (-not (Test-Path $diagPath)) {
            Write-Log "Erro: Arquivo SystemDiagnostic.ps1 não encontrado em: $diagPath" -Type "ERROR"
            exit 1
        }
        
        Write-Log "Iniciando processo elevado..." -Type "INFO"
        
        # Configura argumentos para melhor visibilidade e codificação
        $arguments = "-NoProfile -ExecutionPolicy Bypass -Command `"& { `$OutputEncoding = [Console]::OutputEncoding = [Text.Encoding]::UTF8; `$VerbosePreference='Continue'; . '$diagPath' }`""
        
        # Inicia um novo processo do PowerShell como administrador
        $proc = Start-Process powershell.exe -ArgumentList $arguments -Verb RunAs -PassThru -Wait
        
        switch ($proc.ExitCode) {
            0 { 
                Write-Log "Diagnóstico concluído com sucesso." -Type "SUCCESS"
            }
            1 {
                Write-Log "O script de diagnóstico encontrou erros durante a execução." -Type "ERROR"
            }
            default {
                Write-Log "O script de diagnóstico terminou com código de saída: $($proc.ExitCode)" -Type "WARNING"
            }
        }
    }
    catch {
        Write-Log "Erro ao tentar elevar privilégios: $_" -Type "ERROR"
        Write-Log "Stack Trace: $($_.ScriptStackTrace)" -Type "ERROR"
    }
}
else {
    # Se já estiver rodando como administrador, executa o diagnóstico diretamente
    try {
        Write-Log "Executando diagnóstico com privilégios de administrador..." -Type "INFO"
        $diagPath = Join-Path $PSScriptRoot "SystemDiagnostic.ps1"
        
        if (Test-Path $diagPath) {
            $VerbosePreference = "Continue"
            & $diagPath
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Diagnóstico concluído com sucesso." -Type "SUCCESS"
            }
            else {
                Write-Log "O diagnóstico terminou com erros (Exit Code: $LASTEXITCODE)" -Type "WARNING"
            }
        }
        else {
            Write-Log "Arquivo SystemDiagnostic.ps1 não encontrado em: $diagPath" -Type "ERROR"
            exit 1
        }
    }
    catch {
        Write-Log "Erro ao executar o diagnóstico: $_" -Type "ERROR"
        Write-Log "Stack Trace: $($_.ScriptStackTrace)" -Type "ERROR"
        exit 1
    }
}

# Procura o relatório gerado
$reportPattern = "SystemDiagnostic_Report_*.txt"
$reportFile = Get-ChildItem -Path ([Environment]::GetFolderPath("Desktop")) -Recurse -Filter $reportPattern |
              Sort-Object LastWriteTime -Descending |
              Select-Object -First 1

if ($reportFile) {
    Write-Log "Relatório gerado em: $($reportFile.FullName)" -Type "SUCCESS"
    Write-Log "Abrindo relatório..." -Type "INFO"
    
    # Tenta abrir o relatório com o visualizador padrão
    try {
        Invoke-Item $reportFile.FullName
    }
    catch {
        Write-Log "Não foi possível abrir o relatório automaticamente. Por favor, abra manualmente em: $($reportFile.FullName)" -Type "WARNING"
    }
}
else {
    Write-Log "Não foi possível encontrar o relatório gerado." -Type "WARNING"
}

# Mantém a janela aberta para visualização
Write-Host "`n"
Write-Log "Diagnóstico finalizado. Pressione qualquer tecla para sair..." -Type "INFO"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


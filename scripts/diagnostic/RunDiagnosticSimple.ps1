# Script wrapper simplificado para execução do diagnóstico
$ErrorActionPreference = "Stop"

# Configuração de codificação
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Verifica privilégios de administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Solicitando privilégios de administrador..." -ForegroundColor Yellow
    try {
        $scriptPath = Join-Path $PSScriptRoot "SystemDiagnosticSimple.ps1"
        if (-not (Test-Path $scriptPath)) {
            Write-Host "ERRO: Script de diagnóstico não encontrado em: $scriptPath" -ForegroundColor Red
            exit 1
        }
        
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs -Wait
    }
    catch {
        Write-Host "ERRO ao elevar privilégios: $_" -ForegroundColor Red
        exit 1
    }
}
else {
    # Se já está executando como administrador
    $scriptPath = Join-Path $PSScriptRoot "SystemDiagnosticSimple.ps1"
    if (Test-Path $scriptPath) {
        Write-Host "Executando diagnóstico..." -ForegroundColor Yellow
        & $scriptPath
    }
    else {
        Write-Host "ERRO: Script de diagnóstico não encontrado em: $scriptPath" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`nPressione qualquer tecla para sair..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


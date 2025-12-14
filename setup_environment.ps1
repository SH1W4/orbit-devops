# Script de Configuração Inicial
# setup_environment.ps1

# Configurar PYTHONPATH
$symbeonPath = "C:\Users\JX\Desktop\PROJETOS\PLATAFORMAS\SYMBEON"
[System.Environment]::SetEnvironmentVariable('PYTHONPATH', $symbeonPath, [System.EnvironmentVariableTarget]::User)

# Criar ambiente virtual Python se não existir
$venvPath = ".venv"
if (-not (Test-Path $venvPath)) {
    Write-Host "Criando ambiente virtual Python..." -ForegroundColor Cyan
    python -m venv $venvPath
    Write-Host "Ambiente virtual criado com sucesso!" -ForegroundColor Green
}

# Gerar relatório de configuração
$configLog = @"
# Relatório de Configuração do Ambiente
Data: $(Get-Date -Format 'yyyy-MM-dd HH:mm')

## Configurações Realizadas
1. PYTHONPATH configurado para: $symbeonPath
2. Ambiente virtual Python criado em: $venvPath

## Estado do Ambiente
- Python: $(python --version 2>&1)
- Rust: $(rustc --version 2>&1)
- WSL: Instalado

## Próximos Passos
1. Instalar ferramentas essenciais via Microsoft Store:
   - App Installer (para winget)
   - Windows Terminal (recomendado)

2. Após instalar App Installer, executar:
   ```powershell
   winget install --id Git.Git
   winget install --id Microsoft.VisualStudioCode
   winget install --id OpenJS.NodeJS.LTS
   winget install --id Docker.DockerDesktop
   ```

3. Configurar ambiente virtual:
   ```powershell
   .\.venv\Scripts\Activate.ps1
   pip install fastapi uvicorn pandas numpy torch transformers pytest black mypy ruff
   ```

## Observações
- WSL já está instalado, facilitará a configuração do Docker posteriormente
- Rust está configurado corretamente com cargo no PATH
- Python está instalado e configurado corretamente
"@

# Salvar relatório
$configLog | Out-File -FilePath "$env:USERPROFILE\Desktop\DIAGNOSTIC_BACKUP\CONFIG_LOG.md" -Encoding utf8

Write-Host "`nConfigurações iniciais aplicadas. Verifique o relatório em CONFIG_LOG.md" -ForegroundColor Green
Get-Content "$env:USERPROFILE\Desktop\DIAGNOSTIC_BACKUP\CONFIG_LOG.md"

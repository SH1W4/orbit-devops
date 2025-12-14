# Script de Verificação do Ambiente de Desenvolvimento
# check_environment.ps1

function Write-StatusMessage {
    param(
        [string]$Tool,
        [string]$Status,
        [string]$Version = "",
        [string]$Color = "White"
    )
    $statusEmoji = switch ($Status) {
        "Instalado" { "✅" }
        "Não Encontrado" { "❌" }
        default { "⚠️" }
    }
    Write-Host "$statusEmoji $Tool" -NoNewline
    if ($Version) {
        Write-Host " ($Version)" -NoNewline
    }
    Write-Host " - $Status" -ForegroundColor $Color
}

function Test-Command {
    param([string]$Command)
    (Get-Command $Command -ErrorAction SilentlyContinue) -ne $null
}

Write-Host "`n=== Verificação do Ambiente de Desenvolvimento ===" -ForegroundColor Cyan
Write-Host "Data: $(Get-Date -Format 'yyyy-MM-dd HH:mm')`n"

# Verificar Python
try {
    $pythonVersion = (python --version 2>&1).ToString()
    Write-StatusMessage "Python" "Instalado" $pythonVersion "Green"
} catch {
    Write-StatusMessage "Python" "Não Encontrado" "" "Red"
}

# Verificar Rust
try {
    $rustVersion = (rustc --version 2>&1).ToString()
    Write-StatusMessage "Rust" "Instalado" $rustVersion "Green"
} catch {
    Write-StatusMessage "Rust" "Não Encontrado" "" "Red"
}

# Verificar Git
try {
    $gitVersion = (git --version 2>&1).ToString()
    Write-StatusMessage "Git" "Instalado" $gitVersion "Green"
} catch {
    Write-StatusMessage "Git" "Não Encontrado" "" "Red"
}

# Verificar VS Code
try {
    $codeVersion = (code --version 2>&1)[0].ToString()
    Write-StatusMessage "VS Code" "Instalado" $codeVersion "Green"
} catch {
    Write-StatusMessage "VS Code" "Não Encontrado" "" "Red"
}

# Verificar Node.js
try {
    $nodeVersion = (node --version 2>&1).ToString()
    Write-StatusMessage "Node.js" "Instalado" $nodeVersion "Green"
} catch {
    Write-StatusMessage "Node.js" "Não Encontrado" "" "Red"
}

# Verificar Docker
try {
    $dockerVersion = (docker --version 2>&1).ToString()
    Write-StatusMessage "Docker" "Instalado" $dockerVersion "Green"
} catch {
    Write-StatusMessage "Docker" "Não Encontrado" "" "Red"
}

# Verificar WSL
try {
    $wslVersion = (wsl --version 2>&1).ToString()
    Write-StatusMessage "WSL" "Instalado" $wslVersion "Green"
} catch {
    Write-StatusMessage "WSL" "Não Encontrado" "" "Red"
}

# Verificar Variáveis de Ambiente
Write-Host "`n=== Variáveis de Ambiente ===" -ForegroundColor Cyan
$pythonPath = [System.Environment]::GetEnvironmentVariable("PYTHONPATH", "User")
Write-Host "PYTHONPATH: " -NoNewline
if ($pythonPath) {
    Write-Host $pythonPath -ForegroundColor Green
} else {
    Write-Host "Não configurado" -ForegroundColor Yellow
}

Write-Host "`nPATH do Usuário:"
$userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
$userPath.Split(";") | ForEach-Object { Write-Host "  $_" }

Write-Host "`n=== Recomendações ===" -ForegroundColor Cyan
if (-not (Test-Command "winget")) {
    Write-Host "❗ Instale o App Installer da Microsoft Store para ter acesso ao winget" -ForegroundColor Yellow
}

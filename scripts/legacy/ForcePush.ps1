# ForcePush.ps1
# Script para fazer push ignorando configurações globais de credenciais

Write-Host "🔐 Obtendo token autenticado do GitHub CLI..." -ForegroundColor Cyan
try {
    $token = gh auth token
    if (-not $token) { throw "Não foi possível obter o token. Rode 'gh auth login' primeiro." }
} catch {
    Write-Error "Erro ao obter token: $_"
    exit 1
}

Write-Host "🚀 Iniciando Push Seguro (Bypassing Credential Manager)..." -ForegroundColor Yellow

# Monta a URL com o token autenticado
$repoUrl = "https://oauth2:$token@github.com/SH1W4/Orbit-DevOps.git"

# Executa o push desativando os helpers de credencial do sistema e global
# -c credential.helper= : Limpa qualquer helper configurado
try {
    git -c credential.helper= push $repoUrl main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ SUCESSO! Código enviado para o GitHub." -ForegroundColor Green
    } else {
        throw "Git push falhou com código de saída $LASTEXITCODE"
    }
} catch {
    Write-Host "`n❌ FALHA NO PUSH" -ForegroundColor Red
    Write-Host "Erro: $_"
}

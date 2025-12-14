# Script de Verificação do Ambiente
Write-Host "=== Verificação do Ambiente de Desenvolvimento ===" -ForegroundColor Cyan
Write-Host "Execute este script após reiniciar o terminal`n"

Write-Host "Verificando ferramentas instaladas:`n"

function Test-Tool {
    param(
        [string]$Name,
        [string]$Command,
        [string]$ExpectedOutput
    )
    Write-Host "$Name: " -NoNewline
    try {
        $result = Invoke-Expression $Command
        Write-Host "✅ Instalado" -ForegroundColor Green
        Write-Host "   Versão: $result"
    }
    catch {
        Write-Host "❌ Não encontrado ou não disponível" -ForegroundColor Red
    }
}

# Ativar ambiente virtual Python
try {
    .\.venv\Scripts\Activate.ps1
    Write-Host "Ambiente Virtual Python: ✅ Ativo" -ForegroundColor Green
}
catch {
    Write-Host "Ambiente Virtual Python: ❌ Erro ao ativar" -ForegroundColor Red
}

Write-Host "`nVerificando ferramentas principais:"
Test-Tool "Python" "python --version" "3.11.5"
Test-Tool "Git" "git --version" ""
Test-Tool "VS Code" "code --version" ""
Test-Tool "Node.js" "node --version" ""
Test-Tool "Docker" "docker --version" ""
Test-Tool "Rust" "rustc --version" ""

Write-Host "`nPróximos passos:"
Write-Host "1. Feche este terminal"
Write-Host "2. Abra um novo terminal"
Write-Host "3. Execute este script novamente para confirmar que todas as ferramentas estão disponíveis"
Write-Host "4. Se alguma ferramenta ainda não for encontrada, verifique se o computador precisa ser reiniciado"


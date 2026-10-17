# Configuração do Ambiente de Desenvolvimento

Este guia descreve uma configuração genérica. Não inclua saídas locais de diagnóstico, caminhos pessoais, variáveis de ambiente, listas de processos ou inventários de software neste arquivo.

## Requisitos

- Node.js 20 ou superior
- npm
- Git
- PowerShell 7 (Windows) para scripts PowerShell
- Python apenas para os componentes MCP

## Instalação

```powershell
npm ci
```

## Uso

```powershell
npm start -- doctor
npm start -- space
npm start -- clean
```

O comando `clean` deve operar em modo de simulação por padrão. Revise o plano antes de qualquer execução explícita. Nunca execute scripts de limpeza legados que estejam desabilitados.

## Privacidade e segurança

- Não versionar relatórios pessoais de diagnóstico, caminhos absolutos, logs de sessão ou inventários de software.
- Não publicar `dev-stack.json` sem revisar e redigir os dados que ele contém.
- Não armazenar credenciais, tokens, chaves privadas ou frases-semente no repositório.
- Revise as alterações antes de fazer commit ou push.

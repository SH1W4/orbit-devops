# Script de Limpeza Adicional
# Pode ser executado sem privilégios de admin

$logPath = "$env:USERPROFILE\Desktop\DIAGNOSTIC_BACKUP\ADDITIONAL_CLEANUP_LOG.txt"

function Write-Log {
    param($Message)
    $line = "[$(Get-Date -Format 'HH:mm:ss')] $Message"
    Write-Host $line -ForegroundColor Cyan
    $line | Out-File -FilePath $logPath -Append -Encoding utf8
}

Write-Log "=== LIMPEZA ADICIONAL ==="

# 1. Cache do Google Chrome
Write-Log "Limpando cache do Google Chrome..."
$chromePath = "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Cache"
if (Test-Path $chromePath) {
    $before = (Get-ChildItem $chromePath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1GB
    Remove-Item "$chromePath\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "Chrome cache: ~$([math]::Round($before, 2)) GB limpo"
}

# 2. Cache do Edge
Write-Log "Limpando cache do Edge..."
$edgePath = "$env:USERPROFILE\AppData\Local\Microsoft\Edge\User Data\Default\Cache"
if (Test-Path $edgePath) {
    $before = (Get-ChildItem $edgePath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1GB
    Remove-Item "$edgePath\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "Edge cache: ~$([math]::Round($before, 2)) GB limpo"
}

# 3. Cache geral do usuário
Write-Log "Limpando .cache do usuário..."
$cachePath = "$env:USERPROFILE\.cache"
if (Test-Path $cachePath) {
    $before = (Get-ChildItem $cachePath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1GB
    Remove-Item "$cachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log ".cache: ~$([math]::Round($before, 2)) GB limpo"
}

# 4. Downloads - Instaladores
Write-Log "Removendo instaladores antigos de Downloads..."
$downloads = "$env:USERPROFILE\Downloads"
$installers = @("*.exe", "*.msi")
foreach ($pattern in $installers) {
    Get-ChildItem $downloads -Filter $pattern -File | Where-Object {
        $_.Name -match "Setup|Installer|Install|Driver|NVIDIA|Google"
    } | ForEach-Object {
        $sizeMB = [math]::Round($_.Length / 1MB, 0)
        Write-Log "Removendo: $($_.Name) ($sizeMB MB)"
        Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
    }
}

# 5. Temp do usuário (arquivos antigos)
Write-Log "Limpando arquivos temporários antigos..."
$tempPath = "$env:USERPROFILE\AppData\Local\Temp"
$cutoffDate = (Get-Date).AddDays(-7)
Get-ChildItem $tempPath -Recurse -Force -ErrorAction SilentlyContinue | 
Where-Object { $_.LastWriteTime -lt $cutoffDate } |
Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

# 6. Status Final
Write-Log "=== RESULTADO ==="
$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
$freeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
Write-Log "Espaço livre agora: $freeGB GB"

Write-Log "Limpeza concluída!"

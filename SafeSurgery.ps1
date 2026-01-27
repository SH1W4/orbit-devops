$ErrorActionPreference = "SilentlyContinue"

Write-Host "=== STARTING SAFE SURGERY ===" -ForegroundColor Cyan

# 1. REMOVE BACKUPS
$targets = @(
    "$env:USERPROFILE\Desktop\PROJETOS\02_ORGANIZATIONS\MOBILIDADE\guardrive-core-backup",
    "$env:USERPROFILE\Desktop\PROJETOS\05_PLATFORMS\SYMBEON-AI\SYMBEON\backup"
)

foreach ($path in $targets) {
    if (Test-Path $path) {
        Write-Host "Removing $path ..." -ForegroundColor Yellow
        # Retry loop for stubborn files
        for ($i = 0; $i -lt 3; $i++) {
            Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            if (-not (Test-Path $path)) { break }
        }
        
        if (Test-Path $path) {
            Write-Host "FAILED to fully remove $path (Permission/Lock issue)" -ForegroundColor Red
        }
        else {
            Write-Host "REMOVED $path" -ForegroundColor Green
        }
    }
    else {
        Write-Host "Target not found (already gone?): $path"
    }
}

# 2. COMPACT DOCKER
Write-Host "`n=== COMPACTING DOCKER ===" -ForegroundColor Cyan
Write-Host "Stopping WSL..."
wsl --shutdown

$vhdx = "$env:USERPROFILE\AppData\Local\Docker\wsl\disk\docker_data.vhdx"
if (Test-Path $vhdx) {
    if (Get-Command Optimize-VHD -ErrorAction SilentlyContinue) {
        Write-Host "Using Optimize-VHD (Hyper-V)..." -ForegroundColor Yellow
        try {
            Optimize-VHD -Path $vhdx -Mode Full
            Write-Host "Compaction Complete." -ForegroundColor Green
        }
        catch {
            Write-Host "Optimize-VHD failed: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "'Optimize-VHD' not found. Trying Diskpart..." -ForegroundColor Yellow
        $script = "select vdisk file=`"$vhdx`"`ncompact vdisk`ndetach vdisk"
        $script | Out-File -FilePath "compact_script.txt" -Encoding ASCII
        
        try {
            diskpart /s "compact_script.txt" | Out-File "diskpart_log.txt"
            Write-Host "Diskpart execution attempted. Check diskpart_log.txt" -ForegroundColor Green
        }
        catch {
            Write-Host "Diskpart failed: $_" -ForegroundColor Red
        }
        Remove-Item "compact_script.txt" -ErrorAction SilentlyContinue
    }
}
else {
    Write-Host "Docker VHDX not found at expected path." -ForegroundColor Red
}

Write-Host "`n=== SURGERY COMPLETE ===" -ForegroundColor Cyan

$ErrorActionPreference = "SilentlyContinue"
$logPath = "$env:USERPROFILE\Desktop\DIAGNOSTIC_BACKUP\TOTAL_CLEANUP_LOG.txt"

function Write-Log {
    param($Message)
    $line = "[$(Get-Date -Format 'HH:mm:ss')] $Message"
    Write-Host $line -ForegroundColor Cyan
    $line | Out-File -FilePath $logPath -Append -Encoding utf8
}

Write-Log "=== STARTING TOTAL CLEANUP ==="

# 1. HIBERNATION
Write-Log "--- Disabling Hibernation ---"
try {
    powercfg -h off 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Log "SUCCESS: Hibernation disabled (Reclaimed ~3GB)"
    }
    else {
        Write-Log "WARNING: Could not disable hibernation (Requires Admin)"
    }
}
catch { Write-Log "Error disabling hibernation: $_" }

# 2. DOCKER
Write-Log "--- Docker Cleanup ---"
if (Get-Command docker -ErrorAction SilentlyContinue) {
    # Stop all containers
    $containers = docker ps -q
    if ($containers) {
        Write-Log "Stopping containers..."
        docker stop $containers | Out-Null
    }
    
    # Prune everything
    Write-Log "Pruning ALL images and volumes..."
    $output = docker system prune -a --volumes -f 2>&1
    Write-Log "Docker Output:"
    $output | ForEach-Object { Write-Log "  $_" }
}

# 3. ANACONDA
Write-Log "--- Removing Anaconda ---"
$anacondaPath = "$env:USERPROFILE\anaconda3"
if (Test-Path $anacondaPath) {
    Write-Log "Found Anaconda at $anacondaPath"
    
    # Try Uninstaller
    $uninstaller = "$anacondaPath\Uninstall-Anaconda3.exe"
    if (Test-Path $uninstaller) {
        Write-Log "Running Uninstaller..."
        try {
            # Run uninstaller silent mode if possible, or just start it
            Start-Process -FilePath $uninstaller -ArgumentList "/S", "/D=$anacondaPath" -Wait -NoNewWindow
            Write-Log "Uninstaller finished."
        }
        catch {
            Write-Log "Uninstaller failed, falling back to force delete."
        }
    }
    
    # Force Delete if still exists
    if (Test-Path $anacondaPath) {
        Write-Log "Force deleting remaining files..."
        Remove-Item $anacondaPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    if (-not (Test-Path $anacondaPath)) {
        Write-Log "SUCCESS: Anaconda removed."
    }
    else {
        Write-Log "PARTIAL: Some files might remain in $anacondaPath"
    }
}
else {
    Write-Log "Anaconda folder not found (maybe already removed)."
}

# 4. FINAL CHECK
Write-Log "=== FINAL STATUS ==="
Get-Volume -DriveLetter C | ForEach-Object {
    $free = [math]::Round($_.SizeRemaining / 1GB, 2)
    $total = [math]::Round($_.Size / 1GB, 2)
    Write-Log "Drive C: Free Space: $free GB (Total: $total GB)"
}

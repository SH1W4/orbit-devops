$ErrorActionPreference = "SilentlyContinue"
$logPath = "$env:USERPROFILE\Desktop\DIAGNOSTIC_BACKUP\CLEANUP_LOG.txt"

function Write-Log {
    param($Message)
    $line = "[$(Get-Date -Format 'HH:mm:ss')] $Message"
    Write-Host $line -ForegroundColor Cyan
    $line | Out-File -FilePath $logPath -Append -Encoding utf8
}

Write-Log "=== STARTING CLEANUP PROCESS ==="

# 1. Cursor Backup
$cursorBackup = "$env:USERPROFILE\AppData\Roaming\Cursor\User\globalStorage\state.vscdb.backup"
if (Test-Path $cursorBackup) {
    Write-Log "Removing Cursor Backup: $cursorBackup"
    try {
        $item = Get-Item $cursorBackup
        $sizeGB = [math]::Round($item.Length / 1GB, 2)
        Remove-Item $cursorBackup -Force -ErrorAction Stop
        Write-Log "SUCCESS: Removed $sizeGB GB from Cursor backup."
    }
    catch {
        Write-Log "ERROR: Could not remove Cursor backup: $_"
    }
}
else {
    Write-Log "INFO: Cursor backup file not found."
}

# 2. Docker Prune
Write-Log "Running Docker System Prune..."
if (Get-Command docker -ErrorAction SilentlyContinue) {
    try {
        # Prune stopped containers, networks, and dangling images
        # We capture the output to log it
        $output = docker system prune -f 2>&1
        Write-Log "Docker Prune Output:"
        $output | ForEach-Object { Write-Log "  $_" }
    }
    catch {
        Write-Log "ERROR running Docker prune: $_"
    }
}
else {
    Write-Log "WARNING: Docker command not found."
}

# 3. Temp Files
Write-Log "Cleaning User Temp Folder..."
$tempPath = "$env:USERPROFILE\AppData\Local\Temp"
if (Test-Path $tempPath) {
    $before = (Get-ChildItem $tempPath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    
    Get-ChildItem $tempPath -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { 
        # Only delete files older than 24 hours to be safe(r) for running apps
        $_.LastWriteTime -lt (Get-Date).AddDays(-1)
    } | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    
    $after = (Get-ChildItem $tempPath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    $clearedMB = [math]::Round(($before - $after) / 1MB, 2)
    Write-Log "SUCCESS: Cleared approx $clearedMB MB from Temp (older than 24h)."
}

# 4. Verify Result
Write-Log "=== FINAL STORAGE CHECK ==="
Get-Volume -DriveLetter C | ForEach-Object {
    $free = [math]::Round($_.SizeRemaining / 1GB, 2)
    $total = [math]::Round($_.Size / 1GB, 2)
    Write-Log "Drive C: Free Space: $free GB (Total: $total GB)"
}

Write-Log "Cleanup Completed."

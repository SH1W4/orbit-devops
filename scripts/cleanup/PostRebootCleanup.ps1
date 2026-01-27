# Post-Reboot Cleanup Script
# Run as Administrator

$logPath = "$env:USERPROFILE\Desktop\DIAGNOSTIC_BACKUP\POST_REBOOT_LOG.txt"

function Write-Log {
    param($Message)
    $line = "[$(Get-Date -Format 'HH:mm:ss')] $Message"
    Write-Host $line -ForegroundColor Green
    $line | Out-File -FilePath $logPath -Append -Encoding utf8
}

Write-Log "=== POST-REBOOT CLEANUP ==="

# 1. Disable Hibernation
Write-Log "Disabling Hibernation..."
try {
    powercfg -h off
    Write-Log "SUCCESS: Hibernation disabled (~3 GB freed)"
}
catch {
    Write-Log "ERROR: Could not disable hibernation: $_"
}

# 2. Remove Anaconda (if still exists)
$anacondaPath = "$env:USERPROFILE\anaconda3"
if (Test-Path $anacondaPath) {
    Write-Log "Removing remaining Anaconda files..."
    cmd /c rmdir /s /q "$anacondaPath"
    if (-not (Test-Path $anacondaPath)) {
        Write-Log "SUCCESS: Anaconda removed"
    }
    else {
        Write-Log "WARNING: Some Anaconda files remain"
    }
}
else {
    Write-Log "INFO: Anaconda already removed"
}

# 3. Clean Windows Temp
Write-Log "Cleaning Windows Temp..."
$winTemp = "C:\Windows\Temp"
Get-ChildItem $winTemp -Recurse -Force -ErrorAction SilentlyContinue | 
Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
Write-Log "Windows Temp cleaned"

# 4. Empty Recycle Bin
Write-Log "Emptying Recycle Bin..."
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
Write-Log "Recycle Bin emptied"

# 5. Final Status
Write-Log "=== FINAL STATUS ==="
$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
$freeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
$totalGB = [math]::Round($disk.Size / 1GB, 2)
Write-Log "Drive C: Free Space: $freeGB GB (Total: $totalGB GB)"

Write-Log "Cleanup Complete!"

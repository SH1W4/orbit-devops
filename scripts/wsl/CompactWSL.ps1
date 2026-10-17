# Orbit-DevOps: WSL Compact Tool
# Compacts WSL2 virtual disks (ext4.vhdx) to reclaim space
# REQUIRES: Administrator Privileges

param (
    [switch]$Execute
)

Write-Host "🪐 Orbit-DevOps: WSL Compact Tool" -ForegroundColor Cyan
Write-Host "Scanning for WSL distributions..." -ForegroundColor Gray

# Get all .vhdx files for WSL distros
# Typically in %LOCALAPPDATA%\Packages\...\LocalState\ext4.vhdx

$wslPath = "$env:LOCALAPPDATA\Packages"
$vhdxFiles = Get-ChildItem -Path $wslPath -Recurse -Filter "ext4.vhdx" -ErrorAction SilentlyContinue

if ($vhdxFiles.Count -eq 0) {
    Write-Host "No WSL2 distributions found in standard location." -ForegroundColor Yellow
    exit
}

foreach ($disk in $vhdxFiles) {
    $sizeGB = [math]::Round($disk.Length / 1GB, 2)
    Write-Host "`nFound Disk: $($disk.Name)" -ForegroundColor Green
    Write-Host "Location: $($disk.DirectoryName)" -ForegroundColor Gray
    Write-Host "Current Size: $sizeGB GB" -ForegroundColor Magenta

    if (-not $Execute) {
        Write-Host "[Preview] No disk changes made. Pass -Execute only after reviewing the disk path." -ForegroundColor Yellow
        continue
    }

    Write-Host "EXECUTION REQUESTED: WSL will be shut down and the selected virtual disk will be modified. Continue? [Y/N]" -ForegroundColor Yellow -NoNewline
    $confirm = Read-Host
    if ($confirm -ne "Y" -and $confirm -ne "y") { continue }

    Write-Host "Stopping WSL..." -ForegroundColor Cyan
    wsl --shutdown

    $diskPath = $disk.FullName
    $script = "select vdisk file=`"$diskPath`"`nattach vdisk readonly`ncompact vdisk`ndetach vdisk"
    $scriptPath = "$env:TEMP\wsl_compact.txt"
    $script | Out-File -FilePath $scriptPath -Encoding ASCII

    Write-Host "Compacting... (This may take a while)" -ForegroundColor Cyan
    try {
        diskpart /s $scriptPath
        
        $newSize = (Get-Item $diskPath).Length / 1GB
        $saved = $sizeGB - $newSize
        Write-Host "Compact Complete!" -ForegroundColor Green
        Write-Host "New Size: $([math]::Round($newSize, 2)) GB (Saved: $([math]::Round($saved, 2)) GB)" -ForegroundColor Green
    } catch {
        Write-Host "Error compacting disk: $_" -ForegroundColor Red
        Write-Host "Make sure you are running as Administrator." -ForegroundColor Red
    } finally {
        Remove-Item $scriptPath -ErrorAction SilentlyContinue
    }
}

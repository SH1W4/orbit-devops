$ErrorActionPreference = "SilentlyContinue"
Write-Host "--- TOP 10 RAM PROCESSES ---" -ForegroundColor Yellow
$p = Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10
foreach ($proc in $p) {
    $mb = [math]::Round($proc.WorkingSet / 1MB, 2)
    Write-Host "$($proc.Name) (ID: $($proc.Id)): $mb MB"
}

Write-Host "`n--- SYSTEM MEMORY STATE ---" -ForegroundColor Yellow
$os = Get-CimInstance Win32_OperatingSystem
$total = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$free = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
Write-Host "Total RAM: $total GB (Approx)"
Write-Host "Free RAM:  $([math]::Round($free / 1024, 2)) GB"

Write-Host "`n--- WSL/DOCKER CHECK ---" -ForegroundColor Yellow
$vmmem = Get-Process -Name vmmem*
if ($vmmem) {
    $vSize = [math]::Round(($vmmem | Measure-Object WorkingSet -Sum).Sum / 1MB, 2)
    Write-Host "VMMEM (WSL2/Docker): $vSize MB"
}
else {
    Write-Host "VMMEM process not found."
}

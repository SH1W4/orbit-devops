$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$reportFile = "diagnostico_v2_$timestamp.txt"

function Log {
    param($Msg)
    $out = "[$(Get-Date -Format 'HH:mm:ss')] $Msg"
    Write-Host $out
    $out | Out-File -FilePath $reportFile -Append -Encoding utf8
}

Log "=== DIAGNOSTICO DE SISTEMA (V2) ==="
Log "Data: $timestamp"

# 1. DISCO (CRITICO)
Log "`n--- DISCOS ---"
Get-Volume | Where-Object { $_.DriveLetter } | ForEach-Object {
    $free = [math]::Round($_.SizeRemaining / 1GB, 2)
    $total = [math]::Round($_.Size / 1GB, 2)
    $pct = [math]::Round(($free / $total) * 100, 1)
    Log "Drive $($_.DriveLetter): $free GB livres ($pct%)"
}

# 2. MEMORIA
Log "`n--- MEMORIA ---"
$mem = Get-CimInstance Win32_OperatingSystem
$freeMem = [math]::Round($mem.FreePhysicalMemory / 1024 / 1024, 2)
$totalMem = [math]::Round($mem.TotalVisibleMemorySize / 1024 / 1024, 2)
Log "RAM: $freeMem GB livres de $totalMem GB"

# 3. TOP CPU
Log "`n--- TOP CPU ---"
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | ForEach-Object {
    Log "$($_.ProcessName): $([math]::Round($_.CPU, 1))s"
}

Log "`n--- FIM ---"

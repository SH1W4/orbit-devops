$ErrorActionPreference = "SilentlyContinue"
$reportFile = "C:\Users\Public\FullRAMReport.txt"

Write-Output "=== AUDITORIA FORENSE DE RAM (100% DOS PROCESSOS) ===" > $reportFile
Write-Output "Data: $(Get-Date)" >> $reportFile
Write-Output "`n[1. RESUMO POR EMPRESA]" >> $reportFile
Get-Process | Group-Object Company | Sort-Object Count -Descending | ForEach-Object {
    $size = [math]::Round(($_.Group | Measure-Object WorkingSet -Sum).Sum / 1MB, 2)
    Write-Output "Empresa: $($_.Name) | Count: $($_.Count) | Total RAM: $size MB" >> $reportFile
}

Write-Output "`n[2. LISTA COMPLETA DE PROCESSOS (TOP 200)]" >> $reportFile
Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 200 Name, Id, @{Name = 'RAM_MB'; Expression = { [math]::Round($_.WorkingSet / 1MB, 2) } }, Company, Description | Format-Table -AutoSize >> $reportFile

Write-Output "`n[3. SERVICOS DO WINDOWS ATIVOS]" >> $reportFile
Get-Service | Where-Object { $_.Status -eq 'Running' } | Select-Object Name, DisplayName | Format-Table -AutoSize >> $reportFile

Write-Output "`n[4. ANALISE DO ACER CLUSTER]" >> $reportFile
Get-Process | Where-Object { $_.Name -match "Acer" -or $_.Company -match "Acer" } | ForEach-Object {
    $size = [math]::Round($_.WorkingSet / 1MB, 2)
    Write-Output "Acer Process: $($_.Name) | Size: $size MB | Desc: $($_.Description)" >> $reportFile
}

Write-Output "`n=== FIM DO RELATORIO ===" >> $reportFile
Write-Host "Relatorio gerado em: $reportFile"

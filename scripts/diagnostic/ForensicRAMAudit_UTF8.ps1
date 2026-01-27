$ErrorActionPreference = "SilentlyContinue"
$reportFile = "FullRAMReport_UTF8.txt"

# Usando UTF8 para compatibilidade de leitura
$report = New-Object System.Collections.Generic.List[string]

$report.Add("=== AUDITORIA FORENSE DE RAM (100% DOS PROCESSOS) ===")
$report.Add("Data: $(Get-Date)")
$report.Add("`n[1. RESUMO POR EMPRESA]")
Get-Process | Group-Object Company | Sort-Object Count -Descending | ForEach-Object {
    $size = [math]::Round(($_.Group | Measure-Object WorkingSet -Sum).Sum / 1MB, 2)
    $report.Add("Empresa: $($_.Name) | Count: $($_.Count) | Total RAM: $size MB")
}

$report.Add("`n[2. LISTA COMPLETA DE PROCESSOS (TOP 200)]")
$p200 = Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 200 Name, Id, @{Name = 'RAM_MB'; Expression = { [math]::Round($_.WorkingSet / 1MB, 2) } }, Company, Description | Out-String
$report.Add($p200)

$report.Add("`n[3. SERVICOS DO WINDOWS ATIVOS]")
$services = Get-Service | Where-Object { $_.Status -eq 'Running' } | Select-Object Name, DisplayName | Out-String
$report.Add($services)

$report.Add("`n[4. ANALISE DO ACER CLUSTER]")
Get-Process | Where-Object { $_.Name -match "Acer" -or $_.Company -match "Acer" } | ForEach-Object {
    $size = [math]::Round($_.WorkingSet / 1MB, 2)
    $report.Add("Acer Process: $($_.Name) | Size: $size MB | Desc: $($_.Description)")
}

$report.Add("`n=== FIM DO RELATORIO ===")

[System.IO.File]::WriteAllLines($reportFile, $report, [System.Text.Encoding]::UTF8)
Write-Host "Relatorio gerado em UTF8: $reportFile"

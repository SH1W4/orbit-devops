
$paths = @("C:\Program Files", "C:\Program Files (x86)", "C:\XboxGames", "C:\Games")
foreach ($p in $paths) {
    if (Test-Path $p) {
        Write-Host "Scanning $p..."
        Get-ChildItem $p -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $s = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1GB
            if ($s -gt 1) {
                Write-Host "$($_.FullName): $([math]::Round($s, 2)) GB"
            }
        }
    }
}

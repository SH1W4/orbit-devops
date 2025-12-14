
$path = "$env:USERPROFILE\AppData\Roaming"
Get-ChildItem $path -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1GB
    if ($size -gt 0.5) {
        Write-Host "$($_.Name): $([math]::Round($size, 2)) GB"
    }
}

$path = "$env:USERPROFILE\anaconda3"
if (Test-Path $path) {
    Write-Host "Checking Anaconda at $path ..."
    $size = Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
    Write-Host "SIZE: $([math]::Round($size.Sum / 1GB, 2)) GB"
}
else {
    Write-Host "Anaconda Gone"
}

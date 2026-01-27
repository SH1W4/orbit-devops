$ErrorActionPreference = "SilentlyContinue"
$user = $env:USERPROFILE
$folders = @("Desktop", "Documents", "Downloads", "Videos", "Pictures", "Music", "AppData", "PROJETOS")

Write-Host "=== USER PROFILE AUDIT ($user) ===" -ForegroundColor Cyan
foreach ($f in $folders) {
    $path = Join-Path $user $f
    if (Test-Path $path) {
        $size = Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
        Write-Host "$f : $([math]::Round($size.Sum / 1GB, 2)) GB"
    }
    else {
        Write-Host "$f : Not Found"
    }
}

# Check for other large hidden folders in user root
Get-ChildItem $user -Directory -Force | Where-Object { $folders -notcontains $_.Name } | ForEach-Object {
    $size = Get-ChildItem $_.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
    if ($size.Sum -gt 1GB) {
        Write-Host "$($_.Name) (Extra) : $([math]::Round($size.Sum / 1GB, 2)) GB"
    }
}

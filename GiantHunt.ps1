$ErrorActionPreference = "SilentlyContinue"
$root = "C:\"
$folders = Get-ChildItem -Path $root -Directory

Write-Host "=== C: DRIVE TOP-LEVEL AUDIT ===" -ForegroundColor Cyan
Write-Host "Analyzing root folders (this may take a minute)..."

$results = foreach ($f in $folders) {
    if ($f.Name -eq "Windows") { continue } # Skip Windows core
    
    $size = Get-ChildItem $f.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
    [PSCustomObject]@{
        Folder = $f.Name
        SizeGB = [math]::Round($size.Sum / 1GB, 2)
    }
}

# Special check for User Profile AppData (Common Bloat Area)
$userProfile = $env:USERPROFILE
$appDataSize = Get-ChildItem "$userProfile\AppData" -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
$results += [PSCustomObject]@{
    Folder = "USER_AppData"
    SizeGB = [math]::Round($appDataSize.Sum / 1GB, 2)
}

$results | Sort-Object SizeGB -Descending | Format-Table -AutoSize


$path = "$env:USERPROFILE"
Get-ChildItem $path -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    if ($_.Name -notin @("AppData", "Documents", "Downloads", "Desktop")) {
        $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1GB
        if ($size -gt 1) {
            Write-Host "$($_.Name): $([math]::Round($size, 2)) GB"
        }
    }
}

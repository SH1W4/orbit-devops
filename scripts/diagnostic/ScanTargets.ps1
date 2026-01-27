
$ErrorActionPreference = "SilentlyContinue"

Write-Host "=== TARGETED SCAN ==="

# 1. Check Docker/WSL
Write-Host "`n--- DOCKER / WSL ---"
if (Get-Command docker -ErrorAction SilentlyContinue) {
    docker system df
}
else {
    Write-Host "Docker not found/running."
}

# 2. Check Large AppData Folders
Write-Host "`n--- APPDATA (Top 10 Folders) ---"
$appDataLocal = "$env:USERPROFILE\AppData\Local"
if (Test-Path $appDataLocal) {
    Get-ChildItem $appDataLocal -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
        [PSCustomObject]@{ Name = $_.Name; SizeMB = [math]::Round($size, 0) }
    } | Sort-Object SizeMB -Descending | Select-Object -First 10 | Format-Table -AutoSize
}

# 3. Check Downloads for large files (>100MB)
Write-Host "`n--- LARGE DOWNLOADS (>100MB) ---"
Get-ChildItem "$env:USERPROFILE\Downloads" -File | Where-Object { $_.Length -gt 100MB } | 
Sort-Object Length -Descending | 
ForEach-Object {
    Write-Host "$($_.Name) - $([math]::Round($_.Length/1MB, 0)) MB"
}

# 4. Search for node_modules in Desktop (can be slow, limiting depth)
Write-Host "`n--- NODE_MODULES SEARCH (Desktop - Depth 3) ---"
Get-ChildItem "$env:USERPROFILE\Desktop" -Directory -Recurse -Depth 3 -Filter "node_modules" -ErrorAction SilentlyContinue | 
ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "Found: $($_.FullName) - $([math]::Round($size, 0)) MB"
}

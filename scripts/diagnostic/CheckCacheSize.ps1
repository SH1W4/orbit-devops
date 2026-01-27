$paths = @(
    "$env:USERPROFILE\AppData\Roaming\Code\User\workspaceStorage",
    "$env:USERPROFILE\AppData\Local\npm-cache",
    "$env:USERPROFILE\AppData\Local\pip\cache",
    "$env:USERPROFILE\.gradle\caches"
)

Write-Host "=== CACHE ANALYSIS ==="
foreach ($p in $paths) {
    if (Test-Path $p) {
        $size = Get-ChildItem $p -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
        Write-Host "$p : $([math]::Round($size.Sum / 1GB, 2)) GB"
    }
    else {
        Write-Host "Not found: $p"
    }
}

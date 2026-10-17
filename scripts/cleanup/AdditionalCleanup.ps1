[CmdletBinding()]
param(
    [switch]$Execute
)

$ErrorActionPreference = "Continue"
$cutoffDate = (Get-Date).AddDays(-7)
$targets = @(
    @{ Name = "Chrome cache"; Path = Join-Path $env:LOCALAPPDATA "Google\Chrome\User Data\Default\Cache"; Mode = "Contents" },
    @{ Name = "Edge cache"; Path = Join-Path $env:LOCALAPPDATA "Microsoft\Edge\User Data\Default\Cache"; Mode = "Contents" },
    @{ Name = "Temporary files older than 7 days"; Path = Join-Path $env:LOCALAPPDATA "Temp"; Mode = "OldFiles" }
)

Write-Host "Orbit-DevOps cleanup — $(if ($Execute) { 'EXECUTION REQUESTED' } else { 'DRY RUN (default)' })" -ForegroundColor Cyan
Write-Host "Downloads and the user's broad .cache directory are deliberately excluded." -ForegroundColor Yellow
$plan = @()

foreach ($target in $targets) {
    if (-not (Test-Path -LiteralPath $target.Path)) {
        Write-Host "[SKIP] $($target.Name): target not found."
        continue
    }

    if ($target.Mode -eq "OldFiles") {
        $items = @(Get-ChildItem -LiteralPath $target.Path -Recurse -Force -File -ErrorAction SilentlyContinue |
            Where-Object { $_.LastWriteTime -lt $cutoffDate })
    } else {
        $items = @(Get-ChildItem -LiteralPath $target.Path -Force -ErrorAction SilentlyContinue)
    }

    if ($target.Mode -eq "OldFiles") {
        $sizeItems = $items
    } else {
        $sizeItems = @(Get-ChildItem -LiteralPath $target.Path -Recurse -Force -File -ErrorAction SilentlyContinue)
    }
    $bytes = ($sizeItems | Measure-Object -Property Length -Sum).Sum
    if ($null -eq $bytes) { $bytes = 0 }
    $entry = [pscustomobject]@{
        Name = $target.Name
        Path = $target.Path
        Items = $items
        Count = $items.Count
        Bytes = [int64]$bytes
    }
    $plan += $entry
    Write-Host ("[PLAN] {0}: {1} item(s), {2:N2} MB" -f $target.Name, $entry.Count, ($entry.Bytes / 1MB))
    foreach ($item in $entry.Items) {
        Write-Host ("       - {0}" -f $item.FullName)
    }
}

if (-not $Execute) {
    Write-Host "No files were changed. Review this plan; rerun with -Execute only when you explicitly intend to delete the listed targets." -ForegroundColor Green
    return
}

$confirmation = Read-Host "Type DELETE to confirm removal of the exact listed paths (directories are removed recursively)"
if ($confirmation -cne "DELETE") {
    Write-Host "Cancelled. No files were changed." -ForegroundColor Yellow
    return
}

foreach ($entry in $plan) {
    foreach ($item in $entry.Items) {
        try {
            Remove-Item -LiteralPath $item.FullName -Recurse -Force -ErrorAction Stop
        } catch {
            Write-Warning ("Could not remove '{0}': {1}" -f $item.FullName, $_.Exception.Message)
        }
    }
}
Write-Host "Cleanup attempt completed. Review any warnings above; no claim is made that every item was removed." -ForegroundColor Green

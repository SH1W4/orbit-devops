[CmdletBinding()]
param(
    [string]$WorkspaceRoot = $env:ORBIT_WORKSPACE
)

if (-not $WorkspaceRoot) {
    $WorkspaceRoot = Join-Path $HOME "Projects"
}
if (-not (Test-Path -LiteralPath $WorkspaceRoot -PathType Container)) {
    Write-Error "Workspace root not found. Set ORBIT_WORKSPACE or pass -WorkspaceRoot."
    exit 1
}

Write-Host "=== BACKUP SIZE ANALYSIS ==="
Get-ChildItem -LiteralPath $WorkspaceRoot -Directory -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match '^(backup|backups|archive)$' } |
    ForEach-Object {
        $files = Get-ChildItem -LiteralPath $_.FullName -File -Recurse -Force -ErrorAction SilentlyContinue
        $bytes = ($files | Measure-Object -Property Length -Sum).Sum
        if ($null -eq $bytes) { $bytes = 0 }
        $relative = [System.IO.Path]::GetRelativePath($WorkspaceRoot, $_.FullName)
        [pscustomobject]@{
            Directory = $relative
            Files = $files.Count
            SizeGB = [math]::Round($bytes / 1GB, 2)
        }
    } | Sort-Object SizeGB -Descending | Format-Table -AutoSize

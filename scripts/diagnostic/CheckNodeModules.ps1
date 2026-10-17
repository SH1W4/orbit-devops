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

Write-Host "=== NODE_MODULES SIZE ANALYSIS ==="
Get-ChildItem -LiteralPath $WorkspaceRoot -Directory -Recurse -Force -Filter "node_modules" -ErrorAction SilentlyContinue |
    ForEach-Object {
        $files = Get-ChildItem -LiteralPath $_.FullName -File -Recurse -Force -ErrorAction SilentlyContinue
        $bytes = ($files | Measure-Object -Property Length -Sum).Sum
        if ($null -eq $bytes) { $bytes = 0 }
        $relative = [System.IO.Path]::GetRelativePath($WorkspaceRoot, $_.FullName)
        [pscustomobject]@{
            Path = $relative
            Files = $files.Count
            SizeMB = [math]::Round($bytes / 1MB, 2)
        }
    } | Sort-Object SizeMB -Descending | Format-Table -AutoSize

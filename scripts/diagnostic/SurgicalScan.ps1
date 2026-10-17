[CmdletBinding()]
param(
    [string]$WorkspaceRoot = $env:ORBIT_WORKSPACE
)

if (-not $WorkspaceRoot) { $WorkspaceRoot = Join-Path $HOME "Projects" }
if (-not (Test-Path -LiteralPath $WorkspaceRoot -PathType Container)) {
    Write-Error "Workspace root not found. Set ORBIT_WORKSPACE or pass -WorkspaceRoot."
    exit 1
}

$artifactNames = @("node_modules", "target", ".next", "dist", "build", ".venv", "venv")
Write-Host "=== WORKSPACE ARTIFACT SCAN ===" -ForegroundColor Cyan
$report = foreach ($name in $artifactNames) {
    Get-ChildItem -LiteralPath $WorkspaceRoot -Directory -Recurse -Force -Filter $name -ErrorAction SilentlyContinue |
        ForEach-Object {
            $bytes = (Get-ChildItem -LiteralPath $_.FullName -File -Recurse -Force -ErrorAction SilentlyContinue |
                Measure-Object -Property Length -Sum).Sum
            if ($null -eq $bytes) { $bytes = 0 }
            [pscustomobject]@{
                Path = [System.IO.Path]::GetRelativePath($WorkspaceRoot, $_.FullName)
                SizeGB = [math]::Round($bytes / 1GB, 2)
            }
        }
}
$report | Sort-Object SizeGB -Descending | Format-Table -AutoSize

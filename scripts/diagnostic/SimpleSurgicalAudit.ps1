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
Write-Host "=== BUILD ARTIFACT AUDIT ===" -ForegroundColor Cyan
$results = foreach ($name in $artifactNames) {
    Get-ChildItem -LiteralPath $WorkspaceRoot -Directory -Recurse -Force -Filter $name -ErrorAction SilentlyContinue |
        ForEach-Object {
            $files = Get-ChildItem -LiteralPath $_.FullName -File -Recurse -Force -ErrorAction SilentlyContinue
            $bytes = ($files | Measure-Object -Property Length -Sum).Sum
            if ($null -eq $bytes) { $bytes = 0 }
            [pscustomobject]@{
                Path = [System.IO.Path]::GetRelativePath($WorkspaceRoot, $_.FullName)
                Type = $name
                SizeGB = [math]::Round($bytes / 1GB, 2)
            }
        }
}
$results | Sort-Object SizeGB -Descending | Format-Table -AutoSize

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

function Get-WorkspaceRelativePath {
    param([string]$Root, [string]$FullPath)
    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd('\', '/')
    $full = [System.IO.Path]::GetFullPath($FullPath)
    if ($full.StartsWith($rootFull + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $full.Substring($rootFull.Length + 1)
    }
    if ($full.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $full.Substring($rootFull.Length).TrimStart('\', '/')
    }
    return $full
}

Write-Host "=== NODE_MODULES SIZE ANALYSIS ==="
Get-ChildItem -LiteralPath $WorkspaceRoot -Directory -Recurse -Force -Filter "node_modules" -ErrorAction SilentlyContinue |
    ForEach-Object {
        $files = Get-ChildItem -LiteralPath $_.FullName -File -Recurse -Force -ErrorAction SilentlyContinue
        $bytes = ($files | Measure-Object -Property Length -Sum).Sum
        if ($null -eq $bytes) { $bytes = 0 }
        $relative = (Get-WorkspaceRelativePath -Root $WorkspaceRoot -FullPath $_.FullName)
        [pscustomobject]@{
            Path = $relative
            Files = $files.Count
            SizeMB = [math]::Round($bytes / 1MB, 2)
        }
    } | Sort-Object SizeMB -Descending | Format-Table -AutoSize

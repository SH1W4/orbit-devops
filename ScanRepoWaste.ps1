$ErrorActionPreference = "SilentlyContinue"
$root = "$env:USERPROFILE\Desktop\PROJETOS"
$wastePatterns = @("node_modules", "venv", ".venv", "target", "dist", "build", ".git")
$results = @()

Write-Host "=== SCANNING REPOSITORIES FOR WASTE ===" -ForegroundColor Cyan
Write-Host "Scanning $root (This may take a moment)..."

# Get all subdirectories in PROJETOS (Depth 2: Category -> Repo)
$repos = Get-ChildItem -Path $root -Directory -Depth 2 -ErrorAction SilentlyContinue

foreach ($repo in $repos) {
    # Skip if it's not a repo level (heuristic)
    if ($repo.FullName.Split("\").Count -lt 6) { continue }

    $repoWaste = 0
    $details = @()

    foreach ($pattern in $wastePatterns) {
        $path = Join-Path $repo.FullName $pattern
        if (Test-Path $path) {
            $size = Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
            if ($size.Sum -gt 100MB) {
                $mb = [math]::Round($size.Sum / 1MB, 0)
                $repoWaste += $size.Sum
                $details += "$pattern ($mb MB)"
            }
        }
    }

    if ($repoWaste -gt 200MB) {
        $totalMB = [math]::Round($repoWaste / 1MB, 0)
        $results += [PSCustomObject]@{
            Repo    = $repo.Name
            Path    = $repo.FullName
            WasteMB = $totalMB
            Details = ($details -join ", ")
        }
        Write-Host "." -NoNewline -ForegroundColor Gray
    }
}

Write-Host "`n"

$results | Sort-Object WasteMB -Descending | Select-Object -First 20 | Format-Table -AutoSize

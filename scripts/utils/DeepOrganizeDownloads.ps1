# Orbit-DevOps: Deep Organize Downloads
# Reorganizes subdirectories in the Downloads folder into categorized subfolders

$downloadsPath = "$env:USERPROFILE\Downloads"
$logPath = ".\deep_downloads_org_log.txt"

function Write-Log {
    param($Message)
    $line = "[$(Get-Date -Format 'HH:mm:ss')] $Message"
    Write-Output $line
    $line | Out-File -FilePath $logPath -Append -Encoding utf8
}

function Ensure-Directory {
    param($Path)
    if (-not (Test-Path $Path)) {
        Write-Log "Creating directory: $Path"
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

Write-Log "=== STARTING DEEP DOWNLOADS ORGANIZATION ==="

# 1. Project Consolidation
$projectTarget = Join-Path $downloadsPath "Develop\Projects"
Ensure-Directory $projectTarget

$projects = @(
    @{ Name = "Missão com análise de arquivos enviados"; NewName = "DocSync-Legacy" },
    @{ Name = "th3m1s-core" },
    @{ Name = "AGILIZE-AI" },
    @{ Name = "GuardFlow_AgilizeAI" },
    @{ Name = "KRONOS" },
    @{ Name = "GuardDrive" },
    @{ Name = "SYMBEON DESIGN" }
)

foreach ($proj in $projects) {
    $src = Join-Path $downloadsPath $proj.Name
    if (Test-Path $src) {
        $newName = if ($proj.NewName) { $proj.NewName } else { $proj.Name }
        $dest = Join-Path $projectTarget $newName
        Write-Log "Moving Project: $($proj.Name) -> Develop\Projects\$newName"
        Move-Item -Path $src -Destination $dest -Force
    }
}

# 2. Installer Cleanup
$installerTarget = Join-Path $downloadsPath "Applications\Extracted"
Ensure-Directory $installerTarget

$installers = @(
    "Nitro Sense_Acer_5.0.1473_20241009_W11x64_A",
    "Reset_L3250",
    "temp_installers"
)

foreach ($inst in $installers) {
    $src = Join-Path $downloadsPath $inst
    if (Test-Path $src) {
        $dest = Join-Path $installerTarget $inst
        Write-Log "Moving Installer: $inst -> Applications\Extracted\$inst"
        Move-Item -Path $src -Destination $dest -Force
    }
}

# 3. Game Data
$gameTarget = Join-Path $downloadsPath "Archives\GameData"
Ensure-Directory $gameTarget

$games = @("The_matrix")

foreach ($game in $games) {
    $src = Join-Path $downloadsPath $game
    if (Test-Path $src) {
        $dest = Join-Path $gameTarget $game
        Write-Log "Moving Game Data: $game -> Archives\GameData\$game"
        Move-Item -Path $src -Destination $dest -Force
    }
}

Write-Log "=== DEEP ORGANIZATION COMPLETE ==="

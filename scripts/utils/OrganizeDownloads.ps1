# Orbit-DevOps: Organize Downloads
# Categorizes files in the Downloads folder into subfolders

$downloadsPath = "$env:USERPROFILE\Downloads"
$logPath = ".\downloads_org_log.txt"

$mapping = @{
    "Archives"     = @(".zip", ".rar", ".7z", ".tar", ".gz", ".iso")
    "Applications" = @(".exe", ".msi", ".bin", ".appinstaller")
    "Documents"    = @(".pdf", ".txt", ".csv", ".tex", ".md", ".html", ".docx", ".xlsx", ".pptx")
    "Images"       = @(".png", ".jpg", ".jpeg", ".svg", ".gif", ".webp")
    "Media"        = @(".mp4", ".mov", ".avi", ".mkv", ".mp3", ".wav")
    "Develop"      = @(".py", ".json", ".js", ".ts", ".go", ".c", ".cpp")
}

function Write-Log {
    param($Message)
    $line = "[$(Get-Date -Format 'HH:mm:ss')] $Message"
    Write-Output $line
    $line | Out-File -FilePath $logPath -Append -Encoding utf8
}

Write-Log "=== STARTING DOWNLOADS ORGANIZATION ==="

foreach ($folder in $mapping.Keys) {
    $targetDir = Join-Path $downloadsPath $folder
    if (-not (Test-Path $targetDir)) {
        Write-Log "Creating directory: $folder"
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    $extensions = $mapping[$folder]
    Get-ChildItem -Path $downloadsPath -File | Where-Object { $extensions -contains $_.Extension.ToLower() } | ForEach-Object {
        $dest = Join-Path $targetDir $_.Name
        Write-Log "Moving: $($_.Name) -> $folder"
        Move-Item -Path $_.FullName -Destination $dest -Force
    }
}

Write-Log "=== ORGANIZATION COMPLETE ==="

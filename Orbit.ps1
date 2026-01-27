# Orbit-DevOps: Main Menu
# The interactive command center

function Show-Menu {
    Clear-Host
    Write-Host "🪐 ORBIT-DEVOPS v1.1.0" -ForegroundColor Cyan
    Write-Host "=====================" -ForegroundColor Gray
    Write-Host "1. 🏥 Check System Health"
    Write-Host "2. 🕵️ Analyze Storage"
    Write-Host "3. 🐳 Scan Docker Usage"
    Write-Host "---------------------"
    Write-Host "4. 🧹 Safe Cleanup (Browsers, Temp)"
    Write-Host "5. 🐧 Compact WSL (Requires Admin)"
    Write-Host "6. 📦 Snapshot Environment (Local)"
    Write-Host "7. 🚀 Sync Stack to GitHub"
    Write-Host "---------------------"
    Write-Host "Q. Quit"
    Write-Host ""
}

do {
    Show-Menu
    $choice = Read-Host "Select an option"

    switch ($choice) {
        "1" { & ".\scripts\diagnostic\SystemDiagnosticUser.ps1"; Pause }
        "2" { & ".\scripts\analysis\ScanStorage.ps1"; Pause }
        "3" { & ".\scripts\analysis\ScanTargets.ps1"; Pause }
        "4" { & ".\scripts\cleanup\AdditionalCleanup.ps1"; Pause }
        "5" { 
            Write-Warning "This operation requires Administrator privileges."
            & ".\scripts\wsl\CompactWSL.ps1"; Pause 
        }
        "6" { & ".\scripts\stack\SnapshotEnv.ps1"; Pause }
        "7" { & ".\scripts\stack\Push-Stack.ps1"; Pause }
        "Q" { exit }
        "q" { exit }
        default { Write-Warning "Invalid option" }
    }
} until ($choice -eq "Q")

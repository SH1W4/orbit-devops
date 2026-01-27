$paths = @(
    "$env:USERPROFILE\AppData\Local\Docker\wsl\main\ext4.vhdx",
    "$env:USERPROFILE\AppData\Local\Docker\wsl\disk\docker_data.vhdx",
    "$env:USERPROFILE\Downloads\The_Matrix_Path_of_Neo_Win_ISO_EN.7z",
    "$env:USERPROFILE\Downloads\The_Matrix_Path_of_Neo_Win_Files_EN.7z",
    "$env:USERPROFILE\Downloads\560.81-notebook-win10-win11-64bit-international-dch-whql.exe"
)
Write-Host "=== TARGETED FILE SIZES ==="
foreach ($p in $paths) {
    if (Test-Path $p) {
        $f = Get-Item $p
        Write-Host "$($f.Name) : $([math]::Round($f.Length / 1GB, 2)) GB"
    }
    else {
        Write-Host "Not found: $p"
    }
}

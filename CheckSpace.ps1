$disk = Get-Volume -DriveLetter C
Write-Host "Free Space: $([math]::Round($disk.SizeRemaining / 1GB, 2)) GB"


$path = "$env:USERPROFILE\AppData\Roaming\Cursor"
if (Test-Path $path) {
    Write-Host "Analyzing Cursor Data at $path..."
    
    # Check top level folders
    Get-ChildItem $path -Directory | ForEach-Object {
        $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
        Write-Host "$($_.Name): $([math]::Round($size, 0)) MB"
        
        # If it's "User Data" or "Code", dive deeper
        if ($_.Name -match "User|Code|Storage") {
            Write-Host "  --- Deep dive into $($_.Name) ---"
            Get-ChildItem $_.FullName -Directory | ForEach-Object {
                $subSize = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
                if ($subSize -gt 100) {
                    Write-Host "  $($_.Name): $([math]::Round($subSize, 0)) MB"
                }
            }
        }
    }
}
else {
    Write-Host "Cursor path not found in Roaming."
}

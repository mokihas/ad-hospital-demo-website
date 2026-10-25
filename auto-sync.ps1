# AD Hospital Demo - Automatic Git Watcher & Sync Script
# Runs in the background and automatically commits & pushes changes to GitHub

$repoPath = $PSScriptRoot
Set-Location -Path $repoPath

Write-Host "Watching '$repoPath' for changes..." -ForegroundColor Cyan
Write-Host "Any saved edit will automatically be committed and pushed to GitHub." -ForegroundColor Green
Write-Host "Press Ctrl+C to stop.`n"

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $repoPath
$watcher.IncludeSubdirectories = $false
$watcher.EnableRaisingEvents = $true
$watcher.Filter = "*.*"

$lastChange = [DateTime]::MinValue
$debounceSeconds = 3

while ($true) {
    $result = $watcher.WaitForChanged([System.IO.WatcherChangeTypes]::All, 1000)
    if ($result.TimedOut -eq $false) {
        $fileName = $result.Name
        if ($fileName -notmatch "^\.git|sync\.bat|auto-sync\.ps1") {
            $now = Get-Date
            if (($now - $lastChange).TotalSeconds -gt $debounceSeconds) {
                $lastChange = $now
                Start-Sleep -Seconds 2
                
                $status = git status --porcelain
                if ($status) {
                    Write-Host "[$([DateTime]::Now.ToString('HH:mm:ss'))] Detected changes in $fileName. Syncing to GitHub..." -ForegroundColor Yellow
                    git add .
                    git commit -m "Auto-update: changes detected in $fileName"
                    git push origin main
                    Write-Host "[$([DateTime]::Now.ToString('HH:mm:ss'))] Pushed to GitHub! Vercel is deploying.`n" -ForegroundColor Green
                }
            }
        }
    }
}

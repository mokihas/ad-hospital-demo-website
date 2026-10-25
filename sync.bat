@echo off
cd /d "%~dp0"
echo Syncing updates to GitHub...
git add .
git commit -m "Update hospital demo website content"
git push origin main
echo.
echo Synced to GitHub! Vercel will auto-redeploy shortly.
pause

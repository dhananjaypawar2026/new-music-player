# PowerShell Script to push all remaining files in a single push
$ErrorActionPreference = "Stop"

Write-Host "Syncing index with GitHub..." -ForegroundColor Cyan
git fetch origin
git reset origin/main

Write-Host "Staging remaining files..." -ForegroundColor Cyan
git add .

# Check if there are changes to commit
$status = git status --porcelain
if ([string]::IsNullOrEmpty($status)) {
    Write-Host "SUCCESS: No files left to push! Your repository is fully up to date." -ForegroundColor Green
    Exit
}

Write-Host "Committing changes..." -ForegroundColor Cyan
git commit -m "push all remaining files"

Write-Host "Pushing to GitHub (you will only need to authenticate ONCE)..." -ForegroundColor Green
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "SUCCESS: Everything successfully pushed to GitHub!" -ForegroundColor Green
} else {
    Write-Host "ERROR: Git push failed." -ForegroundColor Red
}

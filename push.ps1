# PowerShell Script to automate batch pushing to prevent network drops
$ErrorActionPreference = "Stop"

# 1. Check if the remote repository is empty
Write-Host "Checking remote repository state..." -ForegroundColor Cyan
$remoteRefs = git ls-remote origin
$isRemoteEmpty = [string]::IsNullOrEmpty($remoteRefs)

if ($isRemoteEmpty) {
    Write-Host "Remote repository is empty. Batch pushing existing local commit history first..." -ForegroundColor Yellow
    
    # Get all commits on the current branch (oldest to newest)
    $commits = @()
    try {
        $commits = @(git log --reverse --format="%H")
    } catch {
        Write-Host "Warning: Could not retrieve local commits." -ForegroundColor Yellow
    }
    
    if ($commits.Count -gt 0) {
        Write-Host "Found $($commits.Count) local commits to push."
        
        $step = 15
        for ($i = $step - 1; $i -lt $commits.Count; $i += $step) {
            $commit = $commits[$i]
            Write-Host "Pushing intermediate commit $commit ($($i+1)/$($commits.Count))..." -ForegroundColor Cyan
            git push origin "${commit}:refs/heads/main"
            Start-Sleep -Seconds 1
        }
        
        Write-Host "Pushing HEAD commit..." -ForegroundColor Green
        git push origin main
        Start-Sleep -Seconds 1
    } else {
        Write-Host "No commits found to push." -ForegroundColor Yellow
    }
}

# 2. Sync local Git index with GitHub
Write-Host "Syncing local Git index with GitHub..." -ForegroundColor Cyan
git fetch origin
$hasRemoteMain = git branch -r | Select-String "origin/main"
if ($hasRemoteMain) {
    git reset origin/main
} else {
    Write-Host "Warning: origin/main not found. Proceeding with current index." -ForegroundColor Yellow
}

# 3. Get list of all modified and untracked files
Write-Host "Scanning for files to upload..." -ForegroundColor Cyan
$statusLines = git status --porcelain -u

$allFiles = @()
foreach ($line in $statusLines) {
    if ($line.Length -gt 3) {
        $filePath = $line.Substring(3).Trim()
        if ($filePath.StartsWith('"') -and $filePath.EndsWith('"')) {
            $filePath = $filePath.Substring(1, $filePath.Length - 2)
        }
        if ($filePath -ne "") {
            $allFiles += $filePath
        }
    }
}

if ($allFiles.Count -eq 0) {
    Write-Host "SUCCESS: No files left to push! Your repository is fully up to date." -ForegroundColor Green
    Exit
}

# Separate code and media files to handle them with different batch sizes
$codeFiles = @()
$mediaFiles = @()
foreach ($file in $allFiles) {
    if ($file -match '\.(png|jpg|jpeg|gif|ico|pdf|zip|tar|gz|exe|apk|appimage|deb|rpm)$') {
        $mediaFiles += $file
    } else {
        $codeFiles += $file
    }
}

Write-Host "Found $($codeFiles.Count) code files and $($mediaFiles.Count) media/binary files to push." -ForegroundColor Yellow

# --- Phase A: Push Code Files in Batches of 5 ---
if ($codeFiles.Count -gt 0) {
    $batchSize = 5
    $totalCodeBatches = [Math]::Ceiling($codeFiles.Count / $batchSize)
    Write-Host ""
    Write-Host "--- PUSHING CODE FILES (in $totalCodeBatches batches) ---" -ForegroundColor Yellow
    
    for ($i = 0; $i -lt $codeFiles.Count; $i += $batchSize) {
        $endIndex = $i + $batchSize - 1
        if ($endIndex -ge $codeFiles.Count) {
            $endIndex = $codeFiles.Count - 1
        }
        
        $batch = $codeFiles[$i..$endIndex]
        $batchNum = [int]($i / $batchSize) + 1
        
        Write-Host ""
        Write-Host "[Code Batch $batchNum of $totalCodeBatches] ($($batch.Count) files)" -ForegroundColor Cyan
        foreach ($file in $batch) {
            Write-Host "Staging: $file"
            git add "$file"
        }
        
        git commit -m "push code batch $batchNum of $totalCodeBatches"
        Write-Host "Pushing to GitHub..." -ForegroundColor Green
        git push origin main
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host ""
            Write-Host "ERROR: Git push failed on Code Batch $batchNum! Aborting script." -ForegroundColor Red
            Exit
        }
        Start-Sleep -Seconds 1
    }
}

# --- Phase B: Push Media/Binary Files One-by-One ---
if ($mediaFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "--- PUSHING MEDIA/BINARY FILES (individually) ---" -ForegroundColor Yellow
    
    $fileNum = 1
    foreach ($file in $mediaFiles) {
        Write-Host ""
        Write-Host "[Media File $fileNum of $($mediaFiles.Count)] Staging: $file" -ForegroundColor Cyan
        git add "$file"
        
        git commit -m "push media $fileNum of $($mediaFiles.Count): $file"
        Write-Host "Pushing to GitHub..." -ForegroundColor Green
        git push origin main
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host ""
            Write-Host "ERROR: Git push failed on media file: $file! Aborting script." -ForegroundColor Red
            Exit
        }
        $fileNum++
        Start-Sleep -Seconds 1
    }
}

Write-Host ""
Write-Host "SUCCESS: All files have been successfully pushed to GitHub!" -ForegroundColor Green

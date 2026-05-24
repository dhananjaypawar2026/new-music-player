Write-Host "Running flutter analyze..." -ForegroundColor Cyan
flutter analyze --suppress-analytics | Out-File -Encoding utf8 analyze_results.txt
Write-Host "Analysis completed! Results saved in UTF-8 to analyze_results.txt." -ForegroundColor Green

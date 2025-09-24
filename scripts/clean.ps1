# Flutter Project Clean Script
Write-Host "Cleaning Flutter project..." -ForegroundColor Cyan

# Flutter clean
Write-Host "Running flutter clean..." -ForegroundColor Yellow
flutter clean

# Clean additional files
Write-Host "Cleaning additional cache files..." -ForegroundColor Yellow
if (Test-Path "build") { 
    Write-Host "Removing build directory..." -ForegroundColor Gray
    Remove-Item "build" -Recurse -Force -ErrorAction SilentlyContinue 
}
if (Test-Path ".dart_tool") { 
    Write-Host "Removing .dart_tool directory..." -ForegroundColor Gray
    Remove-Item ".dart_tool" -Recurse -Force -ErrorAction SilentlyContinue 
}

# Get dependencies
Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "Clean completed successfully!" -ForegroundColor Green
Write-Host "You can now run: flutter run --dart-define=API_BASE_URL=http://192.168.0.184:8000" -ForegroundColor Cyan

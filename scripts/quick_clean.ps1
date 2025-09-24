# 快速清理脚本
Write-Host "🧹 快速清理Flutter项目..." -ForegroundColor Cyan

# 执行Flutter清理
Write-Host "清理Flutter缓存..." -ForegroundColor Yellow
flutter clean

# 清理额外文件
Write-Host "清理额外缓存文件..." -ForegroundColor Yellow
if (Test-Path "build") { Remove-Item "build" -Recurse -Force -ErrorAction SilentlyContinue }
if (Test-Path ".dart_tool") { Remove-Item ".dart_tool" -Recurse -Force -ErrorAction SilentlyContinue }

# 重新获取依赖
Write-Host "重新获取依赖..." -ForegroundColor Yellow
flutter pub get

Write-Host "✅ 清理完成！" -ForegroundColor Green

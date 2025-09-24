# Flutter项目清理脚本 (PowerShell版本)
# 用于清理构建文件和缓存

Write-Host "🧹 Flutter项目清理工具" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host ""

# 获取当前目录
$currentDir = Get-Location
Write-Host "📍 当前目录: $currentDir" -ForegroundColor Yellow
Write-Host ""

# 步骤1: Flutter清理
Write-Host "🗑️  步骤1: Flutter清理..." -ForegroundColor Green
try {
    flutter clean
    Write-Host "✅ Flutter清理完成" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter清理失败: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 步骤2: 清理额外的缓存文件
Write-Host "🗑️  步骤2: 清理额外的缓存文件..." -ForegroundColor Green

$pathsToClean = @(
    ".dart_tool",
    "build",
    "windows\flutter\ephemeral",
    "android\.gradle",
    "android\app\build",
    "ios\build",
    "ios\Pods",
    "ios\Podfile.lock",
    "web\build"
)

foreach ($path in $pathsToClean) {
    if (Test-Path $path) {
        Write-Host "   清理 $path ..." -ForegroundColor Yellow
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 清理临时文件
Get-ChildItem -Path . -Include "*.tmp", "*.log" -Recurse | Remove-Item -Force -ErrorAction SilentlyContinue

Write-Host "✅ 额外清理完成" -ForegroundColor Green
Write-Host ""

# 步骤3: 重新获取依赖
Write-Host "📦 步骤3: 重新获取依赖..." -ForegroundColor Green
try {
    flutter pub get
    Write-Host "✅ 依赖获取完成" -ForegroundColor Green
} catch {
    Write-Host "❌ 依赖获取失败: $_" -ForegroundColor Red
    Write-Host "💡 可能需要启用开发者模式或检查网络连接" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 清理完成！" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 建议:" -ForegroundColor Yellow
Write-Host "  1. 重启IDE（VS Code/Android Studio）" -ForegroundColor White
Write-Host "  2. 如果使用模拟器，重启模拟器" -ForegroundColor White
Write-Host "  3. 清理完成后第一次运行可能较慢" -ForegroundColor White
Write-Host ""

# 询问是否要立即运行应用
$runApp = Read-Host "是否要立即运行应用? (y/N)"
if ($runApp -eq "y" -or $runApp -eq "Y") {
    Write-Host "🚀 启动Flutter应用..." -ForegroundColor Green
    flutter run --dart-define=API_BASE_URL=http://192.168.0.184:8000
}

Write-Host "按任意键退出..." -ForegroundColor Gray
Read-Host

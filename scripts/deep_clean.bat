@echo off
chcp 65001 >nul
echo 🔥 Flutter深度清理工具
echo ====================

echo.
echo ⚠️  警告: 这将删除所有构建文件和缓存
echo    包括Gradle、Pod、Flutter缓存等
echo.
set /p confirm="确定要继续吗？(y/N): "
if /i not "%confirm%"=="y" (
    echo 已取消清理
    pause
    exit /b 0
)

echo.
echo 📍 当前目录: %cd%
echo.

echo 🗑️  步骤1: Flutter深度清理...
flutter clean
flutter pub cache repair
echo ✅ Flutter清理完成

echo.
echo 🗑️  步骤2: 清理所有构建和缓存文件...

REM Flutter相关
if exist ".dart_tool" rmdir /s /q ".dart_tool" 2>nul
if exist "build" rmdir /s /q "build" 2>nul
if exist ".flutter-plugins" del ".flutter-plugins" 2>nul
if exist ".flutter-plugins-dependencies" del ".flutter-plugins-dependencies" 2>nul
if exist ".packages" del ".packages" 2>nul
if exist "pubspec.lock" del "pubspec.lock" 2>nul

REM Android清理
if exist "android\.gradle" rmdir /s /q "android\.gradle" 2>nul
if exist "android\app\build" rmdir /s /q "android\app\build" 2>nul
if exist "android\build" rmdir /s /q "android\build" 2>nul
if exist "android\.idea" rmdir /s /q "android\.idea" 2>nul
if exist "android\local.properties" del "android\local.properties" 2>nul

REM iOS清理
if exist "ios\build" rmdir /s /q "ios\build" 2>nul
if exist "ios\Pods" rmdir /s /q "ios\Pods" 2>nul
if exist "ios\Podfile.lock" del "ios\Podfile.lock" 2>nul
if exist "ios\.symlinks" rmdir /s /q "ios\.symlinks" 2>nul
if exist "ios\Flutter\ephemeral" rmdir /s /q "ios\Flutter\ephemeral" 2>nul

REM Web清理
if exist "web\build" rmdir /s /q "web\build" 2>nul

REM Windows清理
if exist "windows\flutter\ephemeral" rmdir /s /q "windows\flutter\ephemeral" 2>nul
if exist "windows\build" rmdir /s /q "windows\build" 2>nul

REM Linux清理
if exist "linux\flutter\ephemeral" rmdir /s /q "linux\flutter\ephemeral" 2>nul
if exist "linux\build" rmdir /s /q "linux\build" 2>nul

REM macOS清理
if exist "macos\build" rmdir /s /q "macos\build" 2>nul
if exist "macos\Flutter\ephemeral" rmdir /s /q "macos\Flutter\ephemeral" 2>nul

REM 临时文件和日志
for /r %%i in (*.tmp, *.log, *.cache) do del "%%i" 2>nul

echo ✅ 深度清理完成

echo.
echo 📦 步骤3: 重新初始化项目...
flutter pub get
echo ✅ 依赖重新获取完成

echo.
echo 🔧 步骤4: 检查项目状态...
flutter doctor -v
echo.

echo 🎉 深度清理完成！
echo.
echo 💡 接下来的建议:
echo   1. 重启IDE和所有终端
echo   2. 重启模拟器/设备
echo   3. 如果使用Android Studio，同步项目
echo   4. 第一次运行会重新下载所有依赖
echo.

pause

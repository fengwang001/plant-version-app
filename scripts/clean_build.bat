@echo off
chcp 65001 >nul
echo 🧹 Flutter项目清理工具
echo =====================

echo.
echo 📍 当前目录: %cd%
echo.

echo 🗑️  步骤1: Flutter清理...
flutter clean
if errorlevel 1 (
    echo ❌ Flutter清理失败
    pause
    exit /b 1
)
echo ✅ Flutter清理完成

echo.
echo 🗑️  步骤2: 清理额外的缓存文件...

REM 清理Dart工具缓存
if exist ".dart_tool" (
    echo   清理 .dart_tool 目录...
    rmdir /s /q ".dart_tool" 2>nul
)

REM 清理构建目录
if exist "build" (
    echo   清理 build 目录...
    rmdir /s /q "build" 2>nul
)

REM 清理Windows特定文件
if exist "windows\flutter\ephemeral" (
    echo   清理 Windows ephemeral 文件...
    rmdir /s /q "windows\flutter\ephemeral" 2>nul
)

REM 清理Android构建文件
if exist "android\.gradle" (
    echo   清理 Android Gradle 缓存...
    rmdir /s /q "android\.gradle" 2>nul
)

if exist "android\app\build" (
    echo   清理 Android app build...
    rmdir /s /q "android\app\build" 2>nul
)

REM 清理iOS构建文件
if exist "ios\build" (
    echo   清理 iOS build...
    rmdir /s /q "ios\build" 2>nul
)

if exist "ios\Pods" (
    echo   清理 iOS Pods...
    rmdir /s /q "ios\Pods" 2>nul
)

if exist "ios\Podfile.lock" (
    echo   清理 Podfile.lock...
    del "ios\Podfile.lock" 2>nul
)

REM 清理Web构建文件
if exist "web\build" (
    echo   清理 Web build...
    rmdir /s /q "web\build" 2>nul
)

REM 清理临时文件
if exist "*.tmp" (
    echo   清理临时文件...
    del "*.tmp" 2>nul
)

if exist "*.log" (
    echo   清理日志文件...
    del "*.log" 2>nul
)

echo ✅ 额外清理完成

echo.
echo 📦 步骤3: 重新获取依赖...
flutter pub get
if errorlevel 1 (
    echo ❌ 依赖获取失败
    echo 💡 可能需要启用开发者模式或检查网络连接
    pause
    exit /b 1
)
echo ✅ 依赖获取完成

echo.
echo 🔧 步骤4: 生成必要的文件...
REM 如果有代码生成，可以在这里添加
REM flutter packages pub run build_runner build --delete-conflicting-outputs

echo.
echo 🎉 清理完成！
echo.
echo 💡 建议:
echo   1. 重启IDE（VS Code/Android Studio）
echo   2. 如果使用模拟器，重启模拟器
echo   3. 清理完成后第一次运行可能较慢
echo.

pause

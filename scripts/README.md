# 🧹 Flutter项目清理工具

本目录包含用于清理Flutter项目构建文件和缓存的各种脚本。

## 📁 文件说明

### 清理脚本

| 文件名 | 描述 | 推荐使用场景 |
|--------|------|------------|
| `clean_build.ps1` | PowerShell清理脚本 | **推荐** - Windows用户日常清理 |
| `clean_build.bat` | 批处理清理脚本 | Windows用户备选方案 |
| `deep_clean.bat` | 深度清理脚本 | 项目出现严重问题时使用 |


## 🚀 使用方法

### 方法1: PowerShell脚本 (推荐)

```powershell
# 在项目根目录执行
.\scripts\clean_build.ps1
```

**功能:**
- ✅ Flutter clean
- ✅ 清理额外缓存文件
- ✅ 重新获取依赖
- ✅ 可选择立即运行应用

### 方法2: VS Code任务

1. 按 `Ctrl+Shift+P` 打开命令面板
2. 输入 `Tasks: Run Task`
3. 选择以下任务之一:
   - `Flutter: 清理构建文件`
   - `Flutter: 深度清理`
   - `Flutter: 获取依赖`
   - `Flutter: 运行调试 (自定义API)`

### 方法3: 批处理脚本

```cmd
# 常规清理
scripts\clean_build.bat

# 深度清理 (谨慎使用)
scripts\deep_clean.bat
```

## 🔧 清理内容

### 常规清理包括:
- `build/` - 构建输出目录
- `.dart_tool/` - Dart工具缓存
- `windows/flutter/ephemeral/` - Windows平台临时文件
- `android/.gradle/` - Android Gradle缓存
- `android/app/build/` - Android应用构建文件
- `ios/build/` - iOS构建文件
- `ios/Pods/` - iOS依赖
- `web/build/` - Web构建文件
- `*.tmp`, `*.log` - 临时文件和日志

### 深度清理额外包括:
- `.flutter-plugins*` - Flutter插件配置
- `pubspec.lock` - 依赖锁定文件
- `android/local.properties` - Android本地配置
- IDE相关缓存文件

## ⚠️ 注意事项

### 开发者模式
Windows用户可能需要启用开发者模式来支持符号链接:
```cmd
start ms-settings:developers
```

### 网络问题
如果遇到网络连接问题:
1. 检查API服务是否正在运行
2. 确保防火墙允许8000端口
3. 验证API地址配置是否正确

## 🎯 最佳实践

### 何时清理?
- 🔄 切换分支后
- ❌ 遇到构建错误时
- 📦 更新依赖后
- 🐛 出现奇怪的缓存问题时
- 🚀 发布前

### 清理频率
- **日常开发**: 使用常规清理
- **问题排查**: 使用深度清理
- **CI/CD**: 每次构建前清理

### 性能提示
- 清理后第一次运行会较慢
- 建议在网络良好时进行清理
- 大型项目可能需要更长时间

## 🛠️ 自定义配置

### 修改API地址
编辑脚本中的API地址:
```powershell
flutter run --dart-define=API_BASE_URL=http://your-ip:8000
```

### 添加自定义清理路径
在脚本中的 `$pathsToClean` 数组中添加路径:
```powershell
$pathsToClean = @(
    ".dart_tool",
    "build",
    "your/custom/path"  # 添加自定义路径
)
```

## 📞 故障排除

### 常见问题

**Q: 权限不足错误**
A: 以管理员身份运行PowerShell或命令提示符

**Q: 脚本执行策略错误**
A: 运行 `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

**Q: 网络连接失败**
A: 检查网络连接，或使用离线模式

**Q: 依赖获取失败**
A: 确保Flutter和Dart环境正确安装

### 获取帮助
如果遇到问题，请检查:
1. Flutter版本: `flutter --version`
2. 环境诊断: `flutter doctor -v`
3. 网络连接: 使用网络调试工具

---

💡 **提示**: 建议将常用的清理脚本添加到IDE的快捷键或工具栏中，方便日常使用。

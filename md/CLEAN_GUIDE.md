# 🧹 Flutter项目清理指南

## 📋 清理完成清单

✅ **基础清理工具已创建**
- `scripts/clean.ps1` - PowerShell清理脚本 (推荐)
- `scripts/clean_build.bat` - Windows批处理清理脚本
- `scripts/deep_clean.bat` - 深度清理脚本

✅ **VS Code任务集成**
- Flutter: 清理构建文件
- Flutter: 深度清理
- Flutter: 获取依赖
- Flutter: 运行调试 (自定义API)

✅ **网络调试工具**
- 应用内网络调试页面
- IP地址自动检测
- 多地址连接测试

✅ **项目配置优化**
- `.gitignore` 更新，排除临时文件
- 环境变量配置简化
- API地址配置统一

## 🚀 快速使用

### 方法1: PowerShell脚本 (最推荐)
```powershell
# 在项目根目录执行
powershell -ExecutionPolicy Bypass -File scripts/clean.ps1
```

### 方法2: VS Code任务
1. 按 `Ctrl+Shift+P`
2. 输入 `Tasks: Run Task`
3. 选择 `Flutter: 深度清理`

### 方法3: 手动清理
```cmd
flutter clean
flutter pub get
```

## 🔧 解决的问题

### ✅ 构建缓存问题
- 清理 `build/` 目录
- 清理 `.dart_tool/` 缓存
- 清理平台特定的临时文件

### ✅ 依赖问题
- 重新获取所有依赖包
- 清理插件配置文件
- 修复符号链接问题

### ✅ 网络配置问题
- API地址统一管理
- 真机调试网络配置
- 自动IP检测和测试

### ✅ 开发环境问题
- VS Code任务集成
- 脚本自动化
- 错误代码清理

## 📱 真机调试配置

### 检测到的网络配置
- **WiFi网络**: `192.168.0.184:8000` (推荐)
- **WSL网络**: `172.29.160.1:8000` (备选)

### 启动命令
```bash
# 推荐使用WiFi网络IP
flutter run --dart-define=API_BASE_URL=http://192.168.0.184:8000

# 备选WSL网络IP
flutter run --dart-define=API_BASE_URL=http://172.29.160.1:8000
```

### 后端服务启动
```bash
cd python
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

## ⚠️ 重要提醒

### Windows开发者模式
如果遇到符号链接问题，需要启用开发者模式：
```cmd
start ms-settings:developers
```

### 防火墙设置
确保8000端口被允许：
```cmd
netsh advfirewall firewall add rule name="Flutter API" dir=in action=allow protocol=TCP localport=8000
```

### 清理频率建议
- 🔄 **每次切换分支后**
- ❌ **遇到构建错误时**
- 📦 **更新依赖后**
- 🐛 **出现缓存问题时**

## 🎯 最佳实践

1. **定期清理**: 建议每周至少清理一次
2. **问题排查**: 遇到奇怪问题时首先尝试清理
3. **发布前**: 正式发布前进行深度清理
4. **团队协作**: 确保所有团队成员使用相同的清理流程

## 📞 故障排除

### 常见问题及解决方案

**Q: PowerShell执行策略错误**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Q: 依赖获取失败**
- 检查网络连接
- 启用开发者模式
- 尝试使用VPN

**Q: 真机无法连接后端**
- 使用应用内网络调试工具
- 检查IP地址是否正确
- 确保手机和电脑在同一WiFi

**Q: VS Code任务无法执行**
- 检查PowerShell版本
- 确认脚本文件存在
- 尝试手动执行脚本

## 🎉 总结

项目清理系统已完全配置完成！现在您可以：

✅ **一键清理** - 使用PowerShell脚本快速清理  
✅ **IDE集成** - 在VS Code中直接运行清理任务  
✅ **网络调试** - 使用内置工具解决真机调试问题  
✅ **自动化** - 脚本化的清理和启动流程  

**推荐工作流程**：
1. 遇到问题 → 运行清理脚本
2. 真机调试 → 使用网络调试工具
3. 日常开发 → 定期使用VS Code任务清理
4. 团队协作 → 共享清理脚本和配置

---

💡 **提示**: 将 `scripts/clean.ps1` 添加到您的常用工具中，可以大大提高开发效率！

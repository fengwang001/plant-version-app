# 游客模式未调用后端接口 - 诊断与解决

## 🔍 问题分析

**症状**: 游客模式没有调用后端接口，直接进入离线模式

**根本原因**: API状态检查失败，导致 `isApiAvailable` 为 `false`

## 🚀 立即解决方案

### 方案1: 使用调试模式强制启用API

1. **启动Flutter应用**:
   ```bash
   flutter run
   ```

2. **在登录页面**:
   - 查看顶部状态指示器（可能显示橙色"离线"）
   - 点击**蓝色调试按钮**（虫子图标）强制启用API模式
   - 现在点击"先逛逛（游客模式）"应该会调用后端API

3. **查看调试日志**:
   ```
   🔍 开始检查API状态...
   📡 API状态检查结果: 可用/不可用
   👤 开始游客登录流程...
   🌐 使用API游客登录 (或 📱 使用离线模式)
   ```

### 方案2: 手动刷新API状态

1. **点击刷新按钮**（灰色刷新图标）
2. **查看状态指示器是否变为绿色"API"**
3. **重新尝试游客登录**

### 方案3: 检查后端服务

1. **确保后端服务运行**:
   ```bash
   cd python
   python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

2. **测试健康检查端点**:
   ```bash
   curl http://localhost:8000/api/v1/health
   # 应该返回: {"status":"healthy",...}
   ```

## 🔧 详细诊断步骤

### 步骤1: 检查调试日志

启动Flutter应用后，在Debug Console中查找以下日志：

```
🔍 开始检查API状态...
🔍 发送健康检查请求到: http://localhost:8000/api/v1/health
📡 健康检查响应: 200 - {status: healthy, app_name: PlantVision API, version: 1.0.0}
💚 健康检查结果: 健康
📡 API状态检查结果: 可用
```

**如果看到错误**:
```
❌ API连接检查失败: [具体错误信息]
🔧 请确保后端服务在 http://localhost:8000/api/v1 运行
📡 API状态检查结果: 不可用
```

### 步骤2: 测试游客登录流程

点击游客登录按钮后，应该看到：

**API可用时**:
```
👤 开始游客登录流程...
📡 当前API状态: 可用
🌐 使用API游客登录
✅ API游客登录成功: [用户名]
```

**API不可用时**:
```
👤 开始游客登录流程...
📡 当前API状态: 不可用
📱 使用离线模式
```

### 步骤3: 验证后端响应

使用curl或浏览器测试：

```bash
# 1. 健康检查
curl http://localhost:8000/api/v1/health

# 2. 游客登录
curl -X POST http://localhost:8000/api/v1/auth/login/guest \
  -H "Content-Type: application/json" \
  -d '{"device_id":"test_debug","device_type":"android"}'
```

## 🐛 常见问题与解决

### 问题1: 网络连接错误
```
错误: Connection refused / Network is unreachable
原因: 后端服务未启动或端口错误
解决: 启动后端服务，确认端口8000
```

### 问题2: 健康检查404错误
```
错误: 404 Not Found
原因: 健康检查端点路径错误
解决: 确认端点为 /api/v1/health
```

### 问题3: CORS错误
```
错误: CORS policy blocked
原因: 跨域请求被阻止
解决: 确认后端CORS配置允许localhost
```

### 问题4: 设备信息获取失败
```
错误: Failed to get device info
原因: device_info_plus插件问题
解决: flutter clean && flutter pub get
```

## 🎯 强制API模式使用指南

如果自动检测失败，可以使用强制API模式：

1. **点击调试按钮**（蓝色虫子图标）
2. **看到"已强制启用API模式"提示**
3. **状态指示器变为绿色"API"**
4. **点击游客登录**
5. **应该显示"正在创建游客账户..."**

## 📊 预期的完整流程

### 正常API模式流程：
```
应用启动 → 检查API状态 → 显示绿色"API" → 
点击游客登录 → "正在创建游客账户..." → 
调用后端API → 保存令牌 → 跳转主页
```

### 离线模式流程：
```
应用启动 → 检查API状态失败 → 显示橙色"离线" → 
点击游客登录 → "当前为离线模式" → 直接跳转主页
```

## 🔧 临时修复代码

如果需要临时强制启用API模式，可以在代码中修改：

```dart
// 在 lib/presentation/pages/login_page.dart 的 _checkApiStatus 方法中
Future<void> _checkApiStatus() async {
  // 临时强制启用API模式
  isApiAvailable.value = true;
  print('🚀 临时强制启用API模式');
  return;
  
  // ... 原有代码
}
```

## 📱 用户操作指南

1. **启动应用** → 进入登录页面
2. **查看状态** → 顶部状态指示器
   - 绿色"API" = 正常，会调用后端
   - 橙色"离线" = 有问题，会进入离线模式
3. **如果是离线状态**:
   - 点击刷新按钮尝试重新连接
   - 点击蓝色调试按钮强制启用API
4. **点击游客登录** → 查看提示信息
5. **查看控制台日志** → 了解详细执行过程

## 🎉 验证成功标志

游客登录成功调用后端API的标志：
- ✅ 状态指示器显示绿色"API"
- ✅ 显示"正在创建游客账户..."提示
- ✅ 控制台显示"🌐 使用API游客登录"
- ✅ 显示"登录成功，欢迎使用PlantVision"
- ✅ 成功跳转到主页

现在请按照这个指南进行测试，如果还有问题请提供具体的错误日志！

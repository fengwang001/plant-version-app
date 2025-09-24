# 令牌认证修复指南

## 🔍 问题诊断

**问题**: 游客登录成功，但调用植物识别API时返回403 Forbidden  
**原因**: `ApiService`和`AuthService`的令牌管理不同步

## ✅ 已完成的修复

### 1. 统一令牌管理

**修复前**:
- `ApiService`使用静态变量`_authToken`
- `AuthService`使用`TokenStorageService`
- 两者不同步，导致API调用时没有令牌

**修复后**:
- `ApiService`直接从`TokenStorageService`获取令牌
- 统一的令牌管理机制

### 2. 修复内容

#### **文件**: `lib/data/services/api_service.dart`

**变更**:
```dart
// 修复前：使用静态变量
static String? _authToken;
static void setAuthToken(String token) {
  _authToken = token;
}

// 修复后：从TokenStorageService获取
static Map<String, String> _getHeaders({bool includeAuth = true}) {
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
  
  if (includeAuth) {
    final String? token = TokenStorageService.getAccessToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      print('🔑 使用访问令牌: ${token.substring(0, 20)}...');
    } else {
      print('⚠️ 未找到访问令牌');
    }
  }
  
  return headers;
}
```

### 3. 增强调试功能

添加了详细的日志输出来跟踪问题：

#### **API服务调试日志**:
```dart
print('🌐 发送API请求: $url');
print('🔑 使用访问令牌: ${token.substring(0, 20)}...');
print('📡 API响应状态: ${response.statusCode}');
```

#### **识别服务调试日志**:
```dart
print('📡 尝试从API获取最近识别...');
print('✅ 从API获取到 ${apiResults.length} 条识别记录');
print('❌ 从API获取最近识别失败，回退到本地数据: $e');
```

## 🚀 测试步骤

### 1. 重新启动Flutter应用
```bash
flutter hot restart
```

### 2. 执行游客登录
1. 点击"先逛逛（游客模式）"
2. 查看控制台日志，应该看到：
   ```
   🌐 使用API游客登录
   ✅ API游客登录成功: [用户名]
   ```

### 3. 验证令牌保存
登录成功后，应用会自动调用最近识别API，查看日志：

**成功的日志序列**:
```
📡 尝试从API获取最近识别...
🌐 发送API请求: http://localhost:8000/api/v1/plants/identifications?skip=0&limit=5
🔑 使用访问令牌: eyJhbGciOiJIUzI1NiI...
📡 API响应状态: 200
✅ 解析到 X 条识别记录
✅ 从API获取到 X 条识别记录
```

**失败的日志序列**:
```
📡 尝试从API获取最近识别...
🌐 发送API请求: http://localhost:8000/api/v1/plants/identifications?skip=0&limit=5
⚠️ 未找到访问令牌  ← 问题所在
📡 API响应状态: 403
❌ API响应内容: {"detail":"Not authenticated"}
❌ 从API获取最近识别失败，回退到本地数据: Exception: 认证失败，请重新登录
```

## 🔧 故障排除

### 问题1: 仍然显示"⚠️ 未找到访问令牌"

**检查步骤**:
1. 确认游客登录是否成功
2. 检查`TokenStorageService.getAccessToken()`是否返回令牌

**调试代码**:
```dart
// 在home_page.dart的loadRecentHistory方法中添加
print('🔍 检查令牌状态: ${TokenStorageService.getAccessToken() != null}');
```

### 问题2: 令牌存在但仍然403

**可能原因**:
- 令牌格式错误
- 令牌已过期
- 后端认证逻辑问题

**检查方法**:
```bash
# 使用curl测试令牌有效性
curl -H "Authorization: Bearer [你的令牌]" \
     http://localhost:8000/api/v1/plants/identifications?skip=0&limit=5
```

### 问题3: 游客登录成功但令牌未保存

**检查**:
```dart
// 在AuthApiService的loginAsGuest方法中检查
print('💾 保存认证结果: ${authResult.token.accessToken.substring(0, 20)}...');
await TokenStorageService.saveAuthResult(authResult);
```

## 📊 预期结果

### 成功场景

1. **游客登录** ✅
   ```
   👤 开始游客登录流程...
   🌐 使用API游客登录
   ✅ API游客登录成功: 游客用户[ID]
   ```

2. **令牌保存** ✅
   ```
   令牌保存成功
   用户信息保存成功
   ```

3. **API调用** ✅
   ```
   📡 尝试从API获取最近识别...
   🔑 使用访问令牌: eyJhbGciOiJIUzI1NiI...
   📡 API响应状态: 200
   ✅ 从API获取到 X 条识别记录
   ```

4. **主页显示** ✅
   - 最近识别列表正常显示
   - 不再显示"暂无识别记录"

### 失败场景的解决

如果仍然出现403错误：

1. **检查后端日志**：确认令牌解析是否正确
2. **重新生成令牌**：删除应用数据重新登录
3. **检查令牌格式**：确认Bearer前缀正确添加

## 🎯 验证清单

- [ ] 游客登录成功
- [ ] 令牌正确保存到本地存储
- [ ] API请求包含正确的Authorization头
- [ ] 最近识别API返回200状态码
- [ ] 主页显示识别历史记录
- [ ] 控制台显示成功的调试日志

完成所有检查项后，403 Forbidden错误应该已经解决！🎉

# 🔧 应用配置使用指南

## 📋 配置方式

应用现在支持两种配置方式，按优先级排序：

### 1. **编译时环境变量** (最高优先级)
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.0.184:8000 --dart-define=API_TIMEOUT=30
```

### 2. **.env文件配置** (推荐日常使用)
编辑 `config/.env` 文件：
```env
# API配置
API_BASE_URL=http://192.168.0.184:8000
API_TIMEOUT=30

# 应用配置
DEBUG_MODE=true
LOG_LEVEL=debug
```

### 3. **默认配置** (最低优先级)
如果以上都没有配置，使用代码中的默认值。

## 🚀 使用方法

### **方法1: 使用.env文件 (推荐)**
1. 编辑 `config/.env` 文件
2. 设置所需的配置值
3. 直接运行应用：
   ```bash
   flutter run
   ```

### **方法2: 编译时覆盖**
```bash
# 覆盖.env文件中的配置
flutter run --dart-define=API_BASE_URL=http://另一个地址:8000
```

## 📱 **支持的配置项**

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `API_BASE_URL` | `http://172.29.160.1:8000` | 后端API基础地址 |
| `API_TIMEOUT` | `30` | API请求超时时间（秒） |
| `DEBUG_MODE` | 根据编译模式 | 是否启用调试模式 |
| `LOG_LEVEL` | `debug`/`error` | 日志级别 |

## 🔍 **配置验证**

应用启动时会在控制台输出当前配置：
```
✅ .env文件加载成功
🔧 应用配置初始化完成
🌐 API地址: http://192.168.0.184:8000
⏱️ 超时时间: 30秒
🐛 调试模式: true
📝 日志级别: debug
```

## ⚠️ **注意事项**

### **安全性**
- `config/.env` 文件已添加到 `.gitignore`
- 不会被提交到版本控制
- 可以包含敏感配置信息

### **优先级**
```
编译时环境变量 > .env文件 > 默认配置
```

### **真机调试**
- 确保 `.env` 文件中的 `API_BASE_URL` 是真机可访问的地址
- 推荐使用WiFi网络IP地址：`http://192.168.0.184:8000`

## 🎯 **最佳实践**

### **开发环境**
在 `config/.env` 中设置：
```env
API_BASE_URL=http://192.168.0.184:8000
DEBUG_MODE=true
LOG_LEVEL=debug
```

### **生产构建**
使用编译时参数：
```bash
flutter build apk --dart-define=API_BASE_URL=https://api.production.com --dart-define=DEBUG_MODE=false
```

### **团队协作**
1. 不提交 `config/.env` 文件
2. 维护 `config/env.example` 作为模板
3. 团队成员根据需要创建自己的 `.env` 文件

## 🛠️ **故障排除**

### **配置未生效**
1. 检查 `.env` 文件路径：`config/.env`
2. 确认文件格式正确（无BOM，UTF-8编码）
3. 查看控制台日志确认加载状态

### **真机无法连接**
1. 确认API地址在真机上可访问
2. 检查防火墙设置
3. 验证后端服务是否运行

---

💡 **提示**: 现在您可以直接编辑 `config/.env` 文件来修改API地址，无需每次都使用命令行参数！

# 第三方登录配置指南

## Google 登录配置

**注意：** 本项目使用 `google_sign_in` 6.2.1+ 版本，该版本使用 `GoogleSignIn.instance` 单例模式。

### Android 配置

1. **创建 Google Cloud 项目**
   - 访问 [Google Cloud Console](https://console.cloud.google.com/)
   - 创建新项目或选择现有项目

2. **启用 Google Sign-In API**
   - 在 API 库中启用 "Google Sign-In API"

3. **创建 OAuth 2.0 凭据**
   - 转到 "凭据" 页面
   - 创建 OAuth 2.0 客户端 ID
   - 选择 "Android" 应用类型
   - 包名称：`com.example.flutter_application_1`
   - SHA-1 证书指纹：运行 `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`

4. **下载配置文件**
   - 下载 `google-services.json` 文件
   - 将其放置在 `android/app/` 目录下

5. **应用插件**
   - 在 `android/app/build.gradle.kts` 末尾添加：
   ```kotlin
   apply(plugin = "com.google.gms.google-services")
   ```

### iOS 配置

1. **创建 iOS OAuth 客户端**
   - 在同一个 Google Cloud 项目中
   - 创建 iOS OAuth 2.0 客户端 ID
   - Bundle ID：`com.example.flutterApplication1`

2. **下载配置文件**
   - 下载 `GoogleService-Info.plist`
   - 将其添加到 iOS 项目的 Runner 目录

3. **配置 URL Scheme**
   - 在 `ios/Runner/Info.plist` 中添加：
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLName</key>
       <string>REVERSE_CLIENT_ID</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>YOUR_REVERSE_CLIENT_ID</string>
       </array>
     </dict>
   </array>
   ```

## Apple 登录配置

### iOS 配置

1. **启用 Sign in with Apple**
   - 在 Xcode 中打开 `ios/Runner.xcworkspace`
   - 选择 Runner 项目
   - 转到 "Signing & Capabilities"
   - 添加 "Sign In with Apple" capability

2. **Apple Developer 控制台配置**
   - 登录 [Apple Developer](https://developer.apple.com/)
   - 配置 App ID 启用 "Sign In with Apple"
   - 创建相应的 Provisioning Profile

### Android 配置（可选）

Apple 登录在 Android 上需要通过 Web 流程：

1. **配置 Service ID**
   - 在 Apple Developer 控制台创建 Service ID
   - 配置域名和回调 URL

2. **Web 认证流程**
   - 实现 Web 认证流程
   - 处理回调和令牌验证

## 注意事项

1. **调试证书**
   - 开发阶段使用调试证书的 SHA-1
   - 生产环境需要使用发布证书的 SHA-1

2. **包名和 Bundle ID**
   - 确保配置文件中的包名/Bundle ID 与应用一致
   - Android: `com.example.flutter_application_1`
   - iOS: `com.example.flutterApplication1`

3. **网络权限**
   - 确保应用有网络访问权限
   - Android 会自动添加，iOS 需要在 Info.plist 中配置

4. **测试**
   - 在真实设备上测试登录功能
   - 模拟器可能不支持某些登录功能

## 故障排除

1. **Google 登录失败**
   - 检查 SHA-1 证书指纹是否正确
   - 确认 `google-services.json` 文件位置正确
   - 检查包名是否匹配

2. **Apple 登录失败**
   - 确认设备支持 Apple 登录（iOS 13+）
   - 检查 Signing & Capabilities 配置
   - 验证 Apple ID 设置中启用了双重认证

3. **网络问题**
   - 检查网络连接
   - 确认防火墙设置
   - 验证 API 密钥和权限

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';
import '../../data/services/auth_service.dart';

class LoginController extends GetxController {
  final RxBool isBusy = false.obs;
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  late final AuthService _authService;
  VoidCallback? onLoginSuccess;

  @override
  void onInit() {
    super.onInit();
    _authService = AuthService.instance;

    print('🔐 LoginController-page 初始化完成');
  }
  
  /// 设置登录成功回调
  void setOnLoginSuccess(VoidCallback callback) {
    onLoginSuccess = callback;
  }

  /// 游客登录
  Future<void> executeGuestLogin() async {
    if (isBusy.value) return;
    
    try {
      isBusy.value = true;
      
      print('👤 开始游客登录流程...');
      
      // 使用API游客登录
      print('🌐 使用API游客登录');
      Get.snackbar('登录中', '正在创建游客账户...', duration: const Duration(seconds: 2));
      
      final authResult = await _authService.loginAsGuest();
      
      print('✅ API游客登录成功: ${authResult.user.displayName}');
      Get.snackbar(
        '登录成功', 
        '欢迎使用PlantVision，${authResult.user.displayName}！',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      print('👤 游客登录流程完成');
      // 调用登录成功回调，不使用路由跳转
      if (onLoginSuccess != null) {
        onLoginSuccess!();
      }
      
    } catch (e) {
      print('❌ 游客登录失败: $e');
      Get.snackbar(
        '登录失败', 
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isBusy.value = false;
    }
  }

  /// Google登录
  Future<void> executeGoogleLogin() async {
    if (isBusy.value) return;
    
    try {
      isBusy.value = true;
      
      // TODO: 集成Google Sign In SDK
      Get.snackbar('开发中', 'Google登录功能正在开发中，请使用其他方式登录');
      
      // 示例代码（需要实际集成Google Sign In）
      /*
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        
        final authResult = await _authService.loginWithGoogle(
          idToken: googleAuth.idToken!,
          accessToken: googleAuth.accessToken,
        );
        
        Get.snackbar(
          '登录成功', 
          '欢迎回来，${authResult.user.displayName}！',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        Future.microtask(() {
          if (Get.context != null) {
            Get.offAllNamed('/home');
          }
        });
      }
      */
      
    } catch (e) {
      print('Google登录失败: $e');
      Get.snackbar(
        '登录失败', 
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isBusy.value = false;
    }
  }

  /// Apple登录
  Future<void> executeAppleLogin() async {
    if (isBusy.value) return;
    
    try {
      isBusy.value = true;
      
      // 检查平台支持
      if (!Platform.isIOS && !Platform.isMacOS) {
        Get.snackbar('不支持', 'Apple登录仅在iOS和macOS上可用');
        return;
      }
      
      
      // TODO: 集成Apple Sign In SDK
      Get.snackbar('开发中', 'Apple登录功能正在开发中，请使用其他方式登录');
      
      // 示例代码（需要实际集成Apple Sign In）
      /*
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      final userInfo = AppleUserInfo(
        givenName: credential.givenName,
        familyName: credential.familyName,
        email: credential.email,
      );
      
      final authResult = await _authService.loginWithApple(
        identityToken: credential.identityToken!,
        authorizationCode: credential.authorizationCode,
        userInfo: userInfo,
      );
      
      Get.snackbar(
        '登录成功', 
        '欢迎回来，${authResult.user.displayName}！',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      Get.offAllNamed('/home');
      */
      
    } catch (e) {
      print('Apple登录失败: $e');
      Get.snackbar(
        '登录失败', 
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isBusy.value = false;
    }
  }

  /// 邮箱登录
  Future<void> executeEmailLogin() async {
    if (isBusy.value) return;
    if (!formKey.currentState!.validate()) return;
    
    try {
      isBusy.value = true;
      
      Get.snackbar('登录中', '正在验证账户信息...', duration: const Duration(seconds: 2));
      
      final authResult = await _authService.loginWithEmail(
        email: email.value.trim(),
        password: password.value,
      );
      
      Get.snackbar(
        '登录成功', 
        '欢迎回来，${authResult.user.displayName}！',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // 调用登录成功回调，不使用路由跳转
      if (onLoginSuccess != null) {
        onLoginSuccess!();
      }
      
    } catch (e) {
      print('邮箱登录失败: $e');
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      // 处理常见错误
      if (errorMessage.contains('邮箱或密码错误')) {
        errorMessage = '邮箱或密码错误，请检查后重试';
      } else if (errorMessage.contains('网络')) {
        errorMessage = '网络连接失败，请检查网络后重试';
      } else if (errorMessage.contains('服务器')) {
        errorMessage = '服务器暂时不可用，请稍后重试';
      }
      
      Get.snackbar(
        '登录失败', 
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isBusy.value = false;
    }
  }

}

class LoginPage extends StatelessWidget {
  final VoidCallback? onLoginSuccess;
  
  const LoginPage({super.key, this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());
    
    // 如果提供了回调函数，设置到控制器中
    if (onLoginSuccess != null) {
      controller.setOnLoginSuccess(onLoginSuccess!);
    }
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 60),
              
              // 品牌 Logo 区域
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.3),
                            offset: const Offset(0, 8),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_florist_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Plant',
                            style: TextStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: 'Vision',
                            style: TextStyle(
                              color: AppTheme.primaryPurple,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '探索植物世界的奥秘',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              
              // const SizedBox(height: 24),
              
              // Text(
              //   '欢迎回来',
              //   style: Theme.of(context).textTheme.headlineMedium,
              //   textAlign: TextAlign.center,
              // ),
              // const SizedBox(height: 8),
              // Text(
              //   '登录以继续识别植物并生成 AI 视频',
              //   style: Theme.of(context).textTheme.bodyMedium,
              //   textAlign: TextAlign.center,
              // ),
              // const SizedBox(height: 32),
              
              // 邮箱登录表单
              Form(
                key: controller.formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: '邮箱地址',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      onChanged: (String v) => controller.email.value = v,
                      validator: (String? v) {
                        if (v == null || v.trim().isEmpty) return '请输入邮箱';
                        final bool ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
                        return ok ? null : '邮箱格式不正确';
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: '密码',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      onChanged: (String v) => controller.password.value = v,
                      validator: (String? v) {
                        if (v == null || v.isEmpty) return '请输入密码';
                        if (v.length < 6) return '密码至少 6 位';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Obx(() => Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryGreen, Color(0xFF66BB6A)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: controller.isBusy.value ? null : [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: controller.isBusy.value ? null : controller.executeEmailLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: controller.isBusy.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                '登录',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // 分隔线
              Row(
                children: <Widget>[
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '或使用以下方式登录',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              
              // 第三方登录按钮
              OutlinedButton.icon(
                onPressed: controller.executeGoogleLogin,
                icon: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.g_mobiledata,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                label: const Text('使用 Google 登录'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: controller.executeAppleLogin,
                icon: const Icon(Icons.apple, size: 20),
                label: const Text('使用 Apple 登录'),
              ),
              const SizedBox(height: 24),
              
              // 游客登录
              TextButton(
                onPressed: controller.executeGuestLogin,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  '先逛逛（游客模式）',
                  style: TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}



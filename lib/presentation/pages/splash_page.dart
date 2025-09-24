import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../data/services/auth_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  /// 检查用户认证状态并跳转到相应页面
  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 800)); // 显示启动画面
    
    try {
      final authService = AuthService.instance;
      
      // 检查用户是否已登录
      if (authService.isLoggedIn) {
        print('✅ 用户已登录，跳转到首页');
        Future.microtask(() {
          if (Get.context != null) {
            Get.offAllNamed(AppRoutes.home);
          }
        });
      } else {
        print('❌ 用户未登录，跳转到登录页');
        Future.microtask(() {
          if (Get.context != null) {
            Get.offAllNamed(AppRoutes.login);
          }
        });
      }
    } catch (e) {
      print('⚠️ 检查认证状态失败: $e，跳转到登录页');
      Future.microtask(() {
        if (Get.context != null) {
          Get.offAllNamed(AppRoutes.login);
        }
      });
    }
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.eco,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            // App Name
            Text(
              'PlantVision AI',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '植物识别与AI视频生成',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            // Loading Indicator
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




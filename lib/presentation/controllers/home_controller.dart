import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../data/models/plant_identification.dart';
import '../../data/models/plant.dart';
import '../../data/services/recent_identification_service.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/image_service.dart';
import '../pages/identification_result_page.dart';
import '../../fitness_app/fitness_app_home_screen.dart';
import '../../core/routes/app_routes.dart';

class HomeController extends GetxController {
  // 响应式变量
  final RxBool isLoadingHistory = false.obs;
  final RxBool isLoadingFeatured = false.obs;
  final RxBool isIdentifying = false.obs;
  final RxList<PlantIdentification> recentHistory = <PlantIdentification>[].obs;
  final RxList<Plant> featuredPlants = <Plant>[].obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuthentication();
    print('🏠 HomeController 初始化完成');
    _loadDataSequentially();
  }

  /// 按顺序加载数据，带重试机制
  Future<void> _loadDataSequentially() async {
    try {
      print('🔄 开始按顺序加载数据...');
      
      // 先加载识别历史（带重试）
      print('📡 从API获取最近识别...');
      await _loadRecentHistoryWithRetry(maxRetries: 3);
      
      // 再加载推荐植物（带重试）
      print('🌐 从API获取推荐植物...');
      await _loadFeaturedPlantsWithRetry(maxRetries: 3);
      
      print('✅ 所有数据加载完成');
    } catch (e) {
      print('❌ 数据加载过程中出现错误: $e');
    }
  }
  /// 带重试的加载最近识别历史
  Future<void> _loadRecentHistoryWithRetry({int maxRetries = 3}) async {
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        await loadRecentHistory(limit: 5);
        return; // 成功则返回
      } catch (e) {
        retryCount++;
        print('⚠️ 加载失败，尝试重试 ($retryCount/$maxRetries): $e');
        
        if (retryCount < maxRetries) {
          // 等待一段时间后重试（指数退避）
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
        } else {
          // 最后一次重试仍失败
          print('❌ 识别历史加载失败，已重试 $maxRetries 次');
          rethrow;
        }
      }
    }
  }

  /// 带重试的加载推荐植物
  Future<void> _loadFeaturedPlantsWithRetry({int maxRetries = 3}) async {
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        await loadFeaturedPlants();
        return; // 成功则返回
      } catch (e) {
        retryCount++;
        print('⚠️ 加载失败，尝试重试 ($retryCount/$maxRetries): $e');
        
        if (retryCount < maxRetries) {
          // 等待一段时间后重试（指数退避）
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
        } else {
          // 最后一次重试仍失败
          print('❌ 推荐植物加载失败，已重试 $maxRetries 次');
          rethrow;
        }
      }
    }
  }

  /// 检查用户认证状态
  void _checkAuthentication() {
    final authService = AuthService.instance;
    
    if (!authService.isLoggedIn) {
      print('❌ 用户未认证，但不执行路由跳转（由 FitnessAppHomeScreen 处理）');
      return;
    }
    
    print('✅ 用户已认证: ${authService.currentUser?.displayName}');
  }

  /// 【核心功能】开始植物识别流程 - 增强版
  Future<void> startPlantIdentification() async {
    print('🎬 ===== 开始植物识别流程 =====');
    print('📍 触发时间: ${DateTime.now()}');
    
    // 1️⃣ 防止重复点击
    if (isIdentifying.value) {
      print('⚠️ 识别正在进行中，忽略重复请求');
      Get.snackbar(
        '请稍候',
        '识别正在进行中，请勿重复操作',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // 2️⃣ 检查用户认证状态
    final authService = AuthService.instance;
    if (!authService.isLoggedIn) {
      print('❌ 用户未登录，终止识别流程');
      Get.snackbar(
        '需要登录',
        '请先登录后再使用识别功能',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    print('✅ 认证检查通过，当前用户: ${authService.currentUser?.displayName}');

    File? imageFile;
    
    try {
      print('📸 Step 1: 调用相机/相册选择图片');
      print('🔍 调用 ImageService.showHalfScreenCameraScanDialog()');
      
      // 3️⃣ 调用相机/相册选择图片
      if (Get.context == null) {
        throw Exception('Get.context 为空，无法打开相机');
      }
      
      imageFile = await ImageService.showHalfScreenCameraScanDialog(Get.context!);
      
      if (imageFile == null) {
        print('🚫 用户取消了图片选择或未选择图片');
        return;
      }

      print('✅ 图片选择成功');
      print('📁 图片路径: ${imageFile.path}');
      
      // 4️⃣ 验证图片文件
      final fileExists = await imageFile.exists();
      if (!fileExists) {
        throw Exception('所选图片文件不存在: ${imageFile.path}');
      }
      
      final fileSize = await imageFile.length();
      print('📏 图片大小: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      
      if (fileSize == 0) {
        throw Exception('图片文件为空');
      }
      
      if (fileSize > 10 * 1024 * 1024) { // 10MB
        throw Exception('图片文件过大（超过10MB），请选择较小的图片');
      }

      // 5️⃣ 设置识别状态
      isIdentifying.value = true;
      print('🔄 识别状态设置为: true');
      
      print('🔄 Step 2: 显示识别加载对话框');
      
      // 显示加载提示对话框
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false, // 防止返回键关闭
          child: Center(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '正在识别中...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI正在分析植物特征',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '这可能需要几秒钟',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      print('🌐 Step 3: 调用识别API服务');
      print('📤 发送识别请求到服务器...');
      
      // 6️⃣ 调用识别服务（添加超时控制）
      final PlantIdentification result = await RecentIdentificationService
          .identifyPlant(imageFile: imageFile)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('识别超时（30秒），服务器响应时间过长，请稍后重试');
            },
          );

      // 关闭加载对话框
      if (Get.isDialogOpen ?? false) {
        Get.back();
        print('✅ 关闭加载对话框');
      }
      
      print('✅ 识别成功！');
      print('🌿 植物名称: ${result.commonName}');
      print('🎯 置信度: ${result.confidence}%');
      print('🔬 学名: ${result.scientificName}');

      // 7️⃣ 跳转到结果页面
      print('🚀 Step 4: 跳转到识别结果页面');
      final dynamic pageResult = await Get.to(
        () => IdentificationResultPage(
          imageFile: imageFile!,
          result: IdentificationResult(
            requestId: result.id,
            suggestions: [result],
            isSuccess: true,
            errorMessage: null,
          ),
        ),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
      );
      
      print('↩️ 从结果页面返回，返回值: $pageResult');
      
      // 8️⃣ 如果从结果页面返回且需要刷新，刷新历史记录
      if (pageResult == true) {
        print('🔄 Step 5: 刷新识别历史记录');
        await loadRecentHistory();
      }

      print('🎉 ===== 识别流程完成 =====');

    } catch (e, stackTrace) {
      print('');
      print('❌ ===== 识别流程失败 =====');
      print('❌ 错误类型: ${e.runtimeType}');
      print('❌ 错误信息: $e');
      print('📚 堆栈跟踪:');
      print(stackTrace);
      print('');
      
      // 关闭可能存在的加载对话框
      if (Get.isDialogOpen ?? false) {
        Get.back();
        print('🔙 关闭加载对话框');
      }

      String errorTitle = '识别失败';
      String errorMessage = '发生未知错误';
      Color backgroundColor = Colors.red;

      // 9️⃣ 错误分类处理
      if (e.toString().contains('认证失败') || 
          e.toString().contains('401') || 
          e.toString().contains('403') ||
          e.toString().contains('Unauthorized')) {
        errorTitle = '认证失败';
        errorMessage = '登录已过期，请重新登录';
        backgroundColor = Colors.orange;
        print('🔒 检测到认证失败错误');
        
      } else if (e.toString().contains('网络') || 
                 e.toString().contains('SocketException') ||
                 e.toString().contains('Network') ||
                 e.toString().contains('Failed host lookup')) {
        errorTitle = '网络错误';
        errorMessage = '无法连接到服务器，请检查网络连接';
        backgroundColor = Colors.orange;
        print('📡 检测到网络连接错误');
        
      } else if (e.toString().contains('超时') || 
                 e.toString().contains('timeout') ||
                 e.toString().contains('TimeoutException')) {
        errorTitle = '请求超时';
        errorMessage = '服务器响应超时，请稍后重试';
        backgroundColor = Colors.orange;
        print('⏱️ 检测到超时错误');
        
      } else if (e.toString().contains('图片') ||
                 e.toString().contains('文件') ||
                 e.toString().contains('file')) {
        errorTitle = '图片错误';
        errorMessage = e.toString().replaceAll('Exception: ', '');
        backgroundColor = Colors.orange;
        print('🖼️ 检测到图片文件错误');
        
      } else if (e.toString().contains('context')) {
        errorTitle = '系统错误';
        errorMessage = '应用上下文错误，请重启应用';
        print('⚙️ 检测到上下文错误');
        
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        if (errorMessage.length > 100) {
          errorMessage = errorMessage.substring(0, 100) + '...';
        }
        print('❓ 未分类的错误类型');
      }
      
      // 显示错误提示
      Get.snackbar(
        errorTitle,
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: backgroundColor.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: Icon(
          Icons.error_outline,
          color: Colors.white,
        ),
      );
      
    } finally {
      isIdentifying.value = false;
      print('🏁 识别状态重置为: false');
      print('');
    }
  }

 /// 改进的加载最近识别历史
  Future<void> loadRecentHistory({int limit = 5}) async {
    // 防止并发：如果已在加载中则直接返回
    if (isLoadingHistory.value) {
      print('⚠️ 识别历史正在加载中，跳过本次请求');
      return;
    }
    
    try {
      isLoadingHistory.value = true;
      print('📡 开始获取最近识别历史（limit=$limit）...');
      
      // 添加超时控制
      final List<PlantIdentification> history = await RecentIdentificationService
          .getRecentIdentifications(limit: limit)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('识别历史请求超时（15秒）');
            },
          );
      
      // 验证返回数据
      if (history == null) {
        throw Exception('从服务返回空数据');
      }
      
      recentHistory.value = history;
      print('✅ 从API获取到 ${history.length} 条识别记录');
      
      if (history.isNotEmpty) {
        print('📋 最新记录: ${history.first.commonName}');
      }
      
    } on TimeoutException catch (e) {
      print('⏱️ 超时错误: $e');
      _handleLoadError(e, '加载识别历史超时');
      rethrow;
      
    } on SocketException catch (e) {
      print('📡 网络错误: $e');
      _handleLoadError(e, '网络连接失败');
      rethrow;
      
    } catch (e) {
      print('❌ 加载识别历史失败: $e');
      _handleLoadError(e, '加载识别历史失败');
      rethrow;
      
    } finally {
      isLoadingHistory.value = false;
    }
  }
  
  /// 改进的加载推荐植物
  Future<void> loadFeaturedPlants() async {
    // 防止并发：如果已在加载中则直接返回
    if (isLoadingFeatured.value) {
      print('⚠️ 推荐植物正在加载中，跳过本次请求');
      return;
    }
    
    try {
      isLoadingFeatured.value = true;
      print('🌐 开始获取推荐植物...');
      
      // 添加超时控制
      final List<Plant> plants = await ApiService.getFeaturedPlants(limit: 3)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('推荐植物请求超时（15秒）');
            },
          );
      
      // 验证返回数据
      if (plants == null) {
        throw Exception('从服务返回空数据');
      }
      
      featuredPlants.value = plants;
      print('✅ 获取到 ${plants.length} 个推荐植物');
      
      if (plants.isNotEmpty) {
        print('🌟 推荐植物列表: ${plants.map((p) => p.commonName).join(', ')}');
      }
      
    } on TimeoutException catch (e) {
      print('⏱️ 超时错误: $e');
      _handleLoadError(e, '加载推荐植物超时');
      rethrow;
      
    } on SocketException catch (e) {
      print('📡 网络错误: $e');
      _handleLoadError(e, '网络连接失败');
      rethrow;
      
    } catch (e) {
      print('❌ 加载推荐植物失败: $e');
      _handleLoadError(e, '加载推荐植物失败');
      rethrow;
      
    } finally {
      isLoadingFeatured.value = false;
    }
  }
 
  /// 改进的统一错误处理
  void _handleLoadError(dynamic error, String context) {
    print('⚠️ 处理加载错误: $context');
    print('⚠️ 错误详情: $error');
    
    String errorMessage = '加载失败，请重试';
    
    if (error.toString().contains('认证失败') || 
        error.toString().contains('401') || 
        error.toString().contains('403')) {
      errorMessage = '认证已过期，请重新登录';
      
    } else if (error.toString().contains('超时') || 
              error.toString().contains('SocketException') ||
              error.toString().contains('Network')) {
      errorMessage = '网络连接失败，请检查网络';
      
    } else if (error.toString().contains('NoSuchMethodError')) {
      errorMessage = '数据格式错误，请稍后重试';
    }
    
    // 只在用户界面可见时显示错误
    if (Get.context != null) {
      Get.snackbar(
        '提示',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// 手动刷新数据方法（可用于 UI 的下拉刷新）
  Future<void> refreshData() async {
    print('🔄 手动刷新所有数据');
    try {
      await _loadRecentHistoryWithRetry(maxRetries: 2);
      await _loadFeaturedPlantsWithRetry(maxRetries: 2);
      print('✅ 刷新完成');
    } catch (e) {
      print('❌ 刷新数据失败: $e');
    }
  }

  /// 查看识别详情
  void viewIdentificationDetail(PlantIdentification identification) {
    print('👁️ 查看识别详情: ${identification.commonName}');
    try {
      if (Get.isRegistered<AppNavigationController>()) {
        // TODO: 实现识别详情页面导航
        Get.snackbar(
          '功能开发中',
          '识别详情页面正在开发中',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ 导航到识别详情页面失败: $e');
    }
  }

  /// 查看更多识别历史
  void viewMoreHistory() {
    print('📚 查看更多识别历史');
    try {
      if (Get.isRegistered<AppNavigationController>()) {
        AppNavigationController.instance.navigateToLibrary();
      }
    } catch (e) {
      print('❌ 导航到历史页面失败: $e');
    }
  }

  /// 查看植物详情
  void viewPlantDetail(Plant plant) {
    print('🌿 查看植物详情: ${plant.commonName}');
    try {
      if (Get.isRegistered<AppNavigationController>()) {
        // TODO: 实现植物详情页面导航
        Get.snackbar(
          '功能开发中',
          '植物详情页面正在开发中',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ 导航到植物详情页面失败: $e');
    }
  }
}
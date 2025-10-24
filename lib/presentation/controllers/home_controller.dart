import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/plant_identification.dart';
import '../../data/models/plant.dart';
import '../../data/services/recent_identification_service.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/image_service.dart';
import '../pages/identification_result_page.dart';

class HomeController extends GetxController {
  // 响应式变量
  final RxBool isLoadingHistory = false.obs;
  final RxBool isLoadingFeatured = false.obs;
  final RxBool isIdentifying = false.obs;
  final RxList<PlantIdentification> recentHistory = <PlantIdentification>[].obs;
  final RxList<Plant> featuredPlants = <Plant>[].obs;

  // 防止重复加载标记
  bool _isInitialLoadComplete = false;

  @override
  void onInit() {
    super.onInit();
    print('🏠 HomeController.onInit() 被调用');
    _checkAuthentication();
    // ✅ 注意：数据加载由 FitnessAppHomeScreen 直接调用，这里不重复加载
  }

  @override
  void onClose() {
    super.onClose();
    print('🏠 HomeController 被关闭');
  }

  /// 按顺序加载数据 (已弃用，由 FitnessAppHomeScreen 直接调用各个加载方法)
  @Deprecated('Use loadRecentHistory() and loadFeaturedPlants() directly')
  Future<void> _loadDataSequentially() async {
    if (_isInitialLoadComplete) {
      print('⚠️ 初始加载已完成，跳过重复加载');
      return;
    }

    try {
      print('🔄 ===== 开始按顺序加载首屏数据 =====');
      
      final results = await Future.wait([
        loadRecentHistory(),
        loadFeaturedPlants(),
      ], eagerError: false);
      
      _isInitialLoadComplete = true;
      print('✅ ===== 首屏数据加载完成 =====');
      print('📊 加载结果 - 识别历史: ${recentHistory.length}, 推荐植物: ${featuredPlants.length}');
      
    } catch (e) {
      print('❌ 首屏数据加载失败: $e');
      _isInitialLoadComplete = true;
    }
  }

  /// 检查用户认证状态
  void _checkAuthentication() {
    final authService = AuthService.instance;
    if (!authService.isLoggedIn) {
      print('❌ 用户未认证');
      return;
    }
    print('✅ 用户已认证: ${authService.currentUser?.displayName}');
  }

  /// 加载最近识别历史（改进版）
  Future<void> loadRecentHistory({int limit = 5}) async {
    // 防止并发请求
    if (isLoadingHistory.value) {
      print('⚠️ 识别历史正在加载中，跳过本次请求');
      return;
    }

    try {
      print('📡 [开始] 获取最近识别历史 (limit=$limit)...');
      isLoadingHistory.value = true;

      // 调用 API 获取数据
      final List<PlantIdentification> history = await RecentIdentificationService
          .getRecentIdentifications(limit: limit)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('识别历史请求超时（15秒）');
            },
          );

      // 验证数据
      if (history == null || history.isEmpty) {
        print('⚠️ 获取到空的识别历史');
        recentHistory.value = [];
      } else {
        recentHistory.value = history;
        print('✅ [成功] 获取到 ${history.length} 条识别记录');
        print('📋 最新记录: ${history.first.commonName}');
        // ✅ 关键：手动触发 Obx 的重建
        recentHistory.refresh();
      }

    } on TimeoutException catch (e) {
      print('⏱️ [超时] 识别历史加载超时: $e');
      _handleLoadError(e, '识别历史加载超时');
      recentHistory.value = [];
      
    } on SocketException catch (e) {
      print('📡 [网络错误] 识别历史加载失败: $e');
      _handleLoadError(e, '网络连接失败');
      recentHistory.value = [];
      
    } catch (e) {
      print('❌ [异常] 识别历史加载异常: $e');
      _handleLoadError(e, '加载识别历史失败');
      recentHistory.value = [];
    } 
    finally {
      isLoadingHistory.value = false;
      print('📡 [完成] 识别历史加载状态: ${isLoadingHistory.value}');
    }
  }

  /// 加载推荐植物（改进版）
  Future<void> loadFeaturedPlants({int limit = 3}) async {
    // 防止并发请求
    if (isLoadingFeatured.value) {
      print('⚠️ 推荐植物正在加载中，跳过本次请求');
      return;
    }

    try {
      print('🌐 [开始] 获取推荐植物 (limit=$limit)...');
      isLoadingFeatured.value = true;

      // 调用 API 获取数据
      final List<Plant> plants = await ApiService.getFeaturedPlants(limit: limit)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('推荐植物请求超时（15秒）');
            },
          );

      // 验证数据
      if (plants == null || plants.isEmpty) {
        print('⚠️ 获取到空的推荐植物列表');
        featuredPlants.value = [];
      } else {
        featuredPlants.value = plants;
        print('✅ [成功] 获取到 ${plants.length} 个推荐植物');
        print('🌟 推荐植物: ${plants.map((p) => p.commonName).join(', ')}');
        // ✅ 关键：手动触发 Obx 的重建
        featuredPlants.refresh();
      }

    } on TimeoutException catch (e) {
      print('⏱️ [超时] 推荐植物加载超时: $e');
      _handleLoadError(e, '推荐植物加载超时');
      featuredPlants.value = [];
      
    } on SocketException catch (e) {
      print('📡 [网络错误] 推荐植物加载失败: $e');
      _handleLoadError(e, '网络连接失败');
      featuredPlants.value = [];
      
    } catch (e) {
      print('❌ [异常] 推荐植物加载异常: $e');
      _handleLoadError(e, '加载推荐植物失败');
      featuredPlants.value = [];
    } 
    finally {
      isLoadingFeatured.value = false;
      print('🌐 [完成] 推荐植物加载状态: ${isLoadingFeatured.value}');
    }
  }

  /// 统一错误处理
  void _handleLoadError(dynamic error, String context) {
    String errorMessage = '加载失败，请检查网络后重试';

    if (error.toString().contains('认证失败') ||
        error.toString().contains('401') ||
        error.toString().contains('403')) {
      errorMessage = '认证已过期，请重新登录';
    } else if (error.toString().contains('超时') ||
        error.toString().contains('timeout')) {
      errorMessage = '请求超时，请检查网络连接';
    } else if (error.toString().contains('网络') ||
        error.toString().contains('SocketException')) {
      errorMessage = '网络连接失败，请检查网络';
    }

    print('⚠️ 错误处理 - 上下文: $context，消息: $errorMessage');

    // 只在有 context 时显示 snackbar
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

  /// 手动刷新数据（下拉刷新时调用）
  Future<void> refreshData() async {
    print('🔄 ===== 手动刷新所有数据 =====');
    try {
      await Future.wait([
        loadRecentHistory(),
        loadFeaturedPlants(),
      ]);
      print('✅ 刷新完成');
      
      if (Get.context != null) {
        Get.snackbar(
          '成功',
          '数据刷新完成',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('❌ 刷新数据失败: $e');
    }
  }

  /// 开始植物识别流程
  Future<void> startPlantIdentification() async {
    print('🎬 ===== 开始植物识别流程 =====');

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

    // 2️⃣ 检查认证状态
    final authService = AuthService.instance;
    if (!authService.isLoggedIn) {
      print('❌ 用户未登录，终止识别流程');
      Get.snackbar(
        '需要登录',
        '请先登录后再使用识别功能',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    File? imageFile;

    try {
      print('📸 调用相机/相册选择图片...');
      
      if (Get.context == null) {
        throw Exception('应用上下文为空，无法打开相机');
      }

      // 3️⃣ 打开相机/相册
      imageFile = await ImageService.showHalfScreenCameraScanDialog(Get.context!);

      if (imageFile == null) {
        print('🚫 用户取消了图片选择');
        return;
      }

      // 4️⃣ 验证图片文件
      final fileExists = await imageFile.exists();
      if (!fileExists) {
        throw Exception('所选图片文件不存在: ${imageFile.path}');
      }

      final fileSize = await imageFile.length();
      if (fileSize == 0) {
        throw Exception('图片文件为空');
      }

      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('图片文件过大（超过10MB），请选择较小的图片');
      }

      print('✅ 图片验证成功，大小: ${(fileSize / 1024).toStringAsFixed(2)} KB');

      // 5️⃣ 设置识别状态
      isIdentifying.value = true;

      // 6️⃣ 显示加载对话框
      _showIdentifyingDialog();

      print('🌐 调用识别API...');
      
      // 7️⃣ 调用识别服务
      final PlantIdentification result = await RecentIdentificationService
          .identifyPlant(imageFile: imageFile)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('识别超时（30秒），服务器响应时间过长');
            },
          );

      // 关闭加载对话框
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      print('✅ 识别成功！植物: ${result.commonName}，置信度: ${result.confidence}%');

      // 8️⃣ 跳转到结果页面
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

      // 9️⃣ 如果返回 true，刷新历史
      if (pageResult == true) {
        print('🔄 刷新识别历史...');
        await loadRecentHistory();
      }

      print('🎉 ===== 识别流程完成 =====');

    } catch (e) {
      print('❌ ===== 识别流程失败 =====');
      print('错误: $e');

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      String errorTitle = '识别失败';
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      if (errorMessage.length > 100) {
        errorMessage = errorMessage.substring(0, 100) + '...';
      }

      Get.snackbar(
        errorTitle,
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } 
    finally {
      isIdentifying.value = false;
      print('🏁 识别状态已重置');
    }
  }

  /// 显示识别中对话框
  void _showIdentifyingDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI正在分析植物特征',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '这可能需要几秒钟',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// 查看识别详情
  void viewIdentificationDetail(PlantIdentification identification) {
    print('👁️ 查看识别详情: ${identification.commonName}');
    Get.snackbar(
      '功能开发中',
      '识别详情页面正在开发中',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  /// 查看更多历史
  void viewMoreHistory() {
    print('📚 查看更多识别历史');
    Get.snackbar(
      '功能开发中',
      '历史记录详情页面正在开发中',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  /// 查看植物详情
  void viewPlantDetail(Plant plant) {
    print('🌿 查看植物详情: ${plant.commonName}');
    Get.snackbar(
      '功能开发中',
      '植物详情页面正在开发中',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
}
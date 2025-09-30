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
    // _delayedLoad();
     _loadDataSequentially();

  }

  Future<void> _delayedLoad() async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('⏳ 延迟500毫秒后开始加载数据');
    await _loadDataSequentially();
  }
  
  /// 按顺序加载数据，避免并发请求问题
  Future<void> _loadDataSequentially() async {
    try {
      print('🔄 开始按顺序加载数据...');
      
      // 先加载识别历史
      print('📡 从API获取最近识别...');
      await loadRecentHistory();
      
      // 再加载推荐植物
      print('🌐 从API获取推荐植物...');
      await loadFeaturedPlants();
      
      print('✅ 所有数据加载完成');
    } catch (e) {
      print('❌ 数据加载过程中出现错误: $e');
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


  /// 加载最近的识别历史
  Future<void> loadRecentHistory() async {
    if (isLoadingHistory.value) {
      print('⚠️ 识别历史正在加载中，跳过重复请求');
      return;
    }
    
    try {
      isLoadingHistory.value = true;
      print('📡 开始获取最近识别历史...');
      
      // 添加超时控制
      final List<PlantIdentification> history = await RecentIdentificationService
          .getRecentIdentifications(limit: 5)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('请求超时，请检查网络连接');
            },
          );
      
      recentHistory.value = history;
      print('✅ 从API获取到 ${history.length} 条识别记录');
      print('📋 加载识别历史成功，共 ${history.length} 条记录');
      
    } catch (e) {
      print('❌ 加载识别历史失败: $e');
      
      // 处理认证失败的情况
      if (e.toString().contains('认证失败') || 
          e.toString().contains('401') || 
          e.toString().contains('403')) {
        print('🔒 认证失败，跳转到登录页');
        Get.snackbar(
          '认证失败', 
          '请重新登录',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
        print('🔒 认证失败，但不执行路由跳转（由 FitnessAppHomeScreen 处理）');
        throw Exception('111122222222111112244444444');

      }
      
      // 处理超时错误
      if (e.toString().contains('超时') || e.toString().contains('timeout')) {
        Get.snackbar(
          '网络超时', 
          '请检查网络连接后重试',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }
      
      // 显示错误消息
      Get.snackbar(
        '加载失败', 
        '无法加载识别历史',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoadingHistory.value = false;
    }
  }

  /// 开始植物识别
  Future<void> startPlantIdentification() async {
    if (isIdentifying.value) return;

    try {
      print('🌱 开始植物识别流程...');
      
      // 选择图片
  
      final File? imageFile = await ImageService.showHalfScreenCameraScanDialog(Get.context!);
      if (imageFile == null) return;

      isIdentifying.value = true;
      
      // 显示识别提示
      Get.snackbar('识别中', '正在调用AI识别服务，请稍候...');

      // 使用API识别服务
      final PlantIdentification result = await RecentIdentificationService.identifyPlant(
        imageFile: imageFile,
      );

      // 跳转到结果页面
      final dynamic pageResult = await Get.to(() => IdentificationResultPage(
        imageFile: imageFile,
        result: IdentificationResult(
          requestId: result.id,
          suggestions: [result],
          isSuccess: true,
          errorMessage: null,
        ),
      ));
      
      // 如果从结果页面返回，刷新历史记录
      if (pageResult == true) {
        await loadRecentHistory();
      }

    } catch (e) {
      String errorMessage = '识别失败：${e.toString()}';
      if (e.toString().contains('认证失败') || 
          e.toString().contains('401') || 
          e.toString().contains('403')) {
        print('🔒 认证失败');
        Get.snackbar(
          '认证失败', 
          '请重新登录',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
        print('🔒 认证失败，但不执行路由跳转（由 FitnessAppHomeScreen 处理）');
        return;
      } else if (e.toString().contains('网络')) {
        errorMessage = '网络连接失败，请检查网络设置';
      }
      
      print('❌ 植物识别失败: $e');
      Get.snackbar(
        '识别失败', 
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isIdentifying.value = false;
    }
  }

  

  /// 加载推荐植物
  Future<void> loadFeaturedPlants() async {
    if (isLoadingFeatured.value) {
      print('⚠️ 推荐植物正在加载中，跳过重复请求');
      return;
    }
    
    try {
      isLoadingFeatured.value = true;
      print('🌐 开始获取推荐植物...');
      
      // 添加超时控制
      final List<Plant> plants = await ApiService.getFeaturedPlants(limit: 3).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('请求超时，请检查网络连接');
        },
      );
      
      featuredPlants.value = plants;
      print('✅ 获取到 ${plants.length} 个推荐植物');
      print('🌟 加载推荐植物成功，共 ${plants.length} 个');
      print('🌟 推荐植物列表: ${featuredPlants.length}');
      
    } catch (e) {
      print('❌ 加载推荐植物失败: $e');
      
      // 处理认证失败的情况
      if (e.toString().contains('认证失败') || 
          e.toString().contains('401') || 
          e.toString().contains('403')) {
        print('🔒 认证失败，跳转到登录页');
        Get.snackbar(
          '认证失败', 
          '请重新登录',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
        print('🔒 认证失败，但不执行路由跳转（由 FitnessAppHomeScreen 处理）');
        return;
      }
      
      // 处理超时错误
      if (e.toString().contains('超时') || e.toString().contains('timeout')) {
        Get.snackbar(
          '网络超时', 
          '请检查网络连接后重试',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }
      
      // 显示错误消息
      Get.snackbar(
        '加载失败', 
        '无法加载推荐植物',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoadingFeatured.value = false;
    }
  }

  /// 刷新数据
  Future<void> refreshData() async {
    await loadRecentHistory();
    await loadFeaturedPlants();
  }

  /// 查看识别详情
  void viewIdentificationDetail(PlantIdentification identification) {
    // 使用新的导航方式，不使用路由跳转
    try {
      if (Get.isRegistered<AppNavigationController>()) {
        // 可以在这里添加识别详情页面的导航逻辑
        print('查看识别详情: ${identification.commonName}');
        Get.snackbar('功能开发中', '识别详情页面正在开发中', backgroundColor: Colors.blue);
      }
    } catch (e) {
      print('导航到识别详情页面失败: $e');
    }
  }

  /// 查看更多识别历史
  void viewMoreHistory() {
    // 使用新的导航方式，不使用路由跳转
    try {
      if (Get.isRegistered<AppNavigationController>()) {
        AppNavigationController.instance.navigateToLibrary();
      }
    } catch (e) {
      print('导航到历史页面失败: $e');
    }
  }

  /// 查看植物详情
  void viewPlantDetail(Plant plant) {
    // 使用新的导航方式，不使用路由跳转
    try {
      if (Get.isRegistered<AppNavigationController>()) {
        // 可以在这里添加植物详情页面的导航逻辑
        print('查看植物详情: ${plant.commonName}');
        Get.snackbar('功能开发中', '植物详情页面正在开发中', backgroundColor: Colors.blue);
      }
    } catch (e) {
      print('导航到植物详情页面失败: $e');
    }
  }
}


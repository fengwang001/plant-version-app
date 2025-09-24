import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/custom_bottom_nav.dart';
import '../../data/services/image_service.dart';
import '../../data/services/recent_identification_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/plant_identification.dart';
import 'identification_result_page.dart';

class HomeController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxBool isIdentifying = false.obs;
  final RxBool isLoadingHistory = false.obs;
  final RxList<PlantIdentification> recentHistory = <PlantIdentification>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    // 延迟认证检查，确保导航器已准备就绪
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthentication();
    });
    loadRecentHistory();
  }

  /// 检查用户认证状态
  void _checkAuthentication() {
    final authService = AuthService.instance;
    
    // 确保认证服务已初始化
    if (!authService.isInitialized) {
      // 等待认证服务初始化完成
      Future.delayed(const Duration(milliseconds: 100), () {
        if (Get.isRegistered<HomeController>()) {
          _checkAuthentication();
        }
      });
      return;
    }
    
    if (!authService.isLoggedIn) {
      print('❌ 用户未认证，跳转到登录页');
      // 使用 Future.microtask 确保在下一个事件循环中执行导航
      Future.microtask(() {
        if (Get.context != null) {
          Get.offAllNamed(AppRoutes.login);
        }
      });
      return;
    }
    
    print('✅ 用户已认证: ${authService.currentUser?.displayName}');
  }
  
  void onBottomNavTap(int index) {
    selectedIndex.value = index;
  }

  /// 加载最近的识别历史
  Future<void> loadRecentHistory() async {
    if (isLoadingHistory.value) return;
    
    try {
      isLoadingHistory.value = true;
      
      // 使用新的服务获取最近识别列表
      final List<PlantIdentification> history = 
          await RecentIdentificationService.getRecentIdentifications(limit: 5);
      
      recentHistory.value = history;
      // print('加载识别历史成功，共 ${history.length} 条记录');
      
    } catch (e) {
      print('加载识别历史失败: $e');
      
      if (e.toString().contains('认证失败') || e.toString().contains('401') || e.toString().contains('403')) {
        // 认证失败时跳转到登录页
        Get.offAllNamed(AppRoutes.login);
        Get.snackbar('认证失败', '登录状态已过期，请重新登录', backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }
      
      Get.snackbar('提示', '加载识别历史失败，请检查网络连接');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  /// 开始植物识别
  Future<void> startPlantIdentification() async {
    if (isIdentifying.value) return;

    try {
      // 选择图片
      final File? imageFile = await ImageService.showImageSourceDialog();
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
      if (e.toString().contains('认证失败') || e.toString().contains('401') || e.toString().contains('403')) {
        errorMessage = '认证失败，请重新登录';
        // 认证失败时跳转到登录页
        Future.microtask(() {
          if (Get.context != null) {
            Get.offAllNamed(AppRoutes.login);
          }
        });
        Get.snackbar('认证失败', '登录状态已过期，请重新登录', backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      } else if (e.toString().contains('网络')) {
        errorMessage = '网络连接失败，请检查网络设置';
      }
      
      Get.snackbar('识别失败', errorMessage);
    } finally {
      isIdentifying.value = false;
    }
  }

  /// 刷新数据
  Future<void> refreshData() async {
    await loadRecentHistory();
  }

}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    
    return Scaffold(
      body: SafeArea(
        child: Obx(() => IndexedStack(
          index: controller.selectedIndex.value,
          children: [
            _HomeTab(controller: controller),
            const _LibraryTab(),
            const _DiscoverTab(),
            const _ProfileTab(),
          ],
        )),
      ),
      bottomNavigationBar: Obx(() => CustomBottomNavBar(
        currentIndex: controller.selectedIndex.value,
        onTap: controller.onBottomNavTap,
      )),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final HomeController controller;
  
  const _HomeTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部品牌区域
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Plant',
                          style: TextStyle(
                            color: AppTheme.primaryGreen,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'Vision',
                          style: TextStyle(
                            color: AppTheme.primaryPurple,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '探索植物世界的奥秘',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              Row(
                children: [
                  // 刷新按钮
                  GestureDetector(
                    onTap: controller.refreshData,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // 拍照识别按钮
          Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryGreen, Color(0xFF66BB6A)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                  offset: const Offset(0, 8),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Obx(() => ElevatedButton(
              onPressed: controller.isIdentifying.value 
                  ? null 
                  : controller.startPlantIdentification,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: controller.isIdentifying.value
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '识别中...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_rounded, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text(
                          '拍摄识别植物',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            )),
          ),
          const SizedBox(height: 32),
          
          // 植物图片展示
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F8F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(
                Icons.local_florist_rounded,
                size: 80,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // AI四季变化生成器卡片
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'AI四季变化生成器',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '将植物照片变为动态生长视频',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '上传植物照片，AI将生成从春季到冬季的变化过程',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.navGradientStart, AppTheme.navGradientEnd],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPurple.withOpacity(0.3),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: 实现AI视频生成功能
                        Get.snackbar('提示', 'AI视频生成功能开发中');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '立即体验',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // 最近识别区域
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_florist_rounded,
                  color: AppTheme.primaryPurple,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '最近识别',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 识别历史列表
          Obx(() {
            if (controller.isLoadingHistory.value) {
              return _buildLoadingHistoryItem(context);
            } else if (controller.recentHistory.isEmpty) {
              return _buildEmptyHistoryItem(context);
            } else {
              return Column(
                children: controller.recentHistory.map((history) => GestureDetector(
                  onTap: () => _showIdentificationDetail(context, history),
                  child: _buildHistoryItem(
                    context,
                    history.commonName,
                    _formatTime(history.identifiedAt),
                    history.imageUrl,
                    confidence: history.confidence,
                    source: history.identificationSource,
                  ),
                )).toList(),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    String plantName,
    String time,
    String? imageUrl, {
    double? confidence,
    String? source,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: AppTheme.primaryGreen.withOpacity(0.1),
            ),
            clipBehavior: Clip.hardEdge,
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: 48,
                    height: 48,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.local_florist_rounded,
                          color: AppTheme.primaryGreen,
                          size: 24,
                        ),
                      );
                    },
                  )
                : const Icon(
                    Icons.local_florist_rounded,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plantName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (confidence != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getConfidenceColor(confidence).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(confidence * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 10,
                            color: _getConfidenceColor(confidence),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      time,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    if (source != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        _getSourceIcon(source),
                        size: 12,
                        color: AppTheme.textTertiary,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppTheme.textTertiary,
            size: 14,
          ),
        ],
      ),
    );
  }
}

class _LibraryTab extends StatelessWidget {
  const _LibraryTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('图鉴页面开发中'),
    );
  }
}

class _DiscoverTab extends StatelessWidget {
  const _DiscoverTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('发现页面开发中'),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final authService = AuthService.instance;
    final user = authService.currentUser;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 用户头像和信息
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // 头像
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).primaryColor,
                  backgroundImage: user?.avatarUrl != null 
                      ? NetworkImage(user!.avatarUrl!) 
                      : null,
                  child: user?.avatarUrl == null 
                      ? Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 16),
                // 用户名
                Text(
                  user?.displayName ?? '未知用户',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // 用户类型
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: user?.userType == 'guest' ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user?.userType == 'guest' ? '游客用户' : '注册用户',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // 统计信息
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '使用统计',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        '识别次数',
                        '${user?.identificationCount ?? 0}',
                        Icons.eco,
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        '视频生成',
                        '${user?.videoGenerationCount ?? 0}',
                        Icons.video_library,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // 操作按钮
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildActionButton(
                  context,
                  '设置',
                  Icons.settings,
                  () {
                    Get.snackbar('提示', '设置功能开发中');
                  },
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  context,
                  '帮助与反馈',
                  Icons.help,
                  () {
                    Get.snackbar('提示', '帮助功能开发中');
                  },
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  context,
                  '退出登录',
                  Icons.logout,
                  () async {
                    await _showLogoutDialog(context);
                  },
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.grey[700], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: color ?? Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出当前账户吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('退出'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    try {
      final authService = AuthService.instance;
      await authService.logout();
      
      Get.offAllNamed(AppRoutes.login);
      Get.snackbar(
        '退出成功', 
        '您已成功退出登录',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        '退出失败', 
        '退出登录时发生错误：${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

/// 格式化时间显示
String _formatTime(DateTime dateTime) {
  final DateTime now = DateTime.now();
  final Duration difference = now.difference(dateTime);

  if (difference.inDays == 0) {
    if (difference.inHours == 0) {
      if (difference.inMinutes < 5) {
        return '刚刚';
      } else {
        return '${difference.inMinutes} 分钟前';
      }
    } else {
      return '${difference.inHours} 小时前';
    }
  } else if (difference.inDays == 1) {
    return '昨天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} 天前';
  } else {
    return '${dateTime.month}/${dateTime.day}';
  }
}

/// 构建空历史记录提示
Widget _buildEmptyHistoryItem(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        Icon(
          Icons.history_rounded,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 12),
        Text(
          '暂无识别记录',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '拍摄植物照片开始你的第一次识别',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

/// 构建加载历史记录提示
Widget _buildLoadingHistoryItem(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '加载识别记录中...',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}

/// 获取置信度对应的颜色
Color _getConfidenceColor(double confidence) {
  if (confidence >= 0.8) {
    return Colors.green;
  } else if (confidence >= 0.6) {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}

/// 获取数据源对应的图标
IconData _getSourceIcon(String source) {
  switch (source) {
    case 'plant.id':
      return Icons.cloud_done_rounded;
    case 'local_mock':
      return Icons.offline_bolt_rounded;
    default:
      return Icons.help_outline_rounded;
  }
}

/// 显示识别详情
void _showIdentificationDetail(BuildContext context, PlantIdentification identification) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部指示器
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          identification.commonName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getConfidenceColor(identification.confidence).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '置信度: ${(identification.confidence * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getConfidenceColor(identification.confidence),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  Text(
                    identification.scientificName,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 识别信息
                  _buildDetailItem('识别时间', _formatTime(identification.identifiedAt)),
                  if (identification.locationName != null)
                    _buildDetailItem('识别地点', identification.locationName!),
                  _buildDetailItem('数据来源', _getSourceName(identification.identificationSource)),
                  
                  if (identification.description != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      '植物描述',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      identification.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                  
                  if (identification.characteristics.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      '植物特征',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: identification.characteristics.map((characteristic) => 
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            characteristic,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// 构建详情项
Widget _buildDetailItem(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

/// 获取数据源名称
String _getSourceName(String source) {
  switch (source) {
    case 'plant.id':
      return 'Plant.id API';
    case 'local_mock':
      return '本地模拟';
    default:
      return '未知来源';
  }
}




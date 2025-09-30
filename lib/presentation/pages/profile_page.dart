import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/profile_controller.dart';
import '../../l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'subscription_page.dart';
import 'edit_profile_page.dart';
import '../../data/services/auth_service.dart';
import '../../fitness_app/fitness_app_home_screen.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback? onLogout;
  final AnimationController? animationController;
  
  const ProfilePage({
    super.key, 
    this.onLogout, 
    this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final t = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 自定义AppBar
            _buildSliverAppBar(context),
            
            // 内容区域
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildProfileHeader(context, controller),
                  const SizedBox(height: 24),
                  _buildStatsGrid(context, controller),
                  const SizedBox(height: 24),
                  _buildPremiumBadge(context, controller),
                  const SizedBox(height: 24),
                  _buildWorksSection(context, controller),
                  const SizedBox(height: 24),
                  _buildAIVideosSection(context, controller),
                  const SizedBox(height: 24),
                  _buildSettingsSection(context, controller, t),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      pinned: false,
      floating: true,
      centerTitle: true,
      leading: const SizedBox(),
      title: const Text(
        'Profile',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // 设置按钮功能
          },
          icon: const Icon(
            Icons.tune_rounded,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileController controller) {
    return Obx(() => Column(
      children: [
        // 用户头像
        Stack(
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: controller.currentUser.value?.avatarUrl != null
                    ? CachedNetworkImage(
                        imageUrl: controller.currentUser.value!.avatarUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => _buildAvatarPlaceholder(controller),
                      )
                    : _buildAvatarPlaceholder(controller),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () async {
                  // 跳转到编辑个人资料页面
                  final result = await Get.to(() => const EditProfilePage());
                  if (result == true) {
                    // 刷新用户数据
                    controller.refreshUserData();
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 20,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 用户名
        Text(
          controller.displayName.value.isNotEmpty 
              ? controller.displayName.value 
              : 'Sophia Green',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        
        const SizedBox(height: 4),
        
        // 用户名handle
        Text(
          '@${controller.currentUser.value?.username ?? 'sophia_green'}',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    ));
  }

  Widget _buildAvatarPlaceholder(ProfileController controller) {
    return Container(
      color: AppTheme.primaryGreen.withOpacity(0.1),
      child: Center(
        child: Text(
          controller.avatarText.value,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, ProfileController controller) {
    return Obx(() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            '120',
            'Works',
            controller.creationsCount.value.toString(),
          ),
          _buildStatItem(
            '500',
            'Views',
            _formatNumber(controller.viewsCount.value),
          ),
          _buildStatItem(
            '85',
            'Identified',
            controller.currentUser.value?.identificationCount.toString() ?? '0',
          ),
        ],
      ),
    ));
  }

  Widget _buildStatItem(String defaultValue, String label, String value) {
    return Column(
      children: [
        Text(
          value.isNotEmpty ? value : defaultValue,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumBadge(BuildContext context, ProfileController controller) {
    return Obx(() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // 跳转到订阅管理页面
              Get.to(() => const SubscriptionPage());
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.isPremium.value ? 'Premium Member' : 'Free Member',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF22C55E),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Color(0xFF22C55E),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildWorksSection(BuildContext context, ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Works',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: Obx(() {
            if (controller.creations.isEmpty) {
              return _buildEmptyWorks();
            }
            
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.creations.length.clamp(0, 3),
              itemBuilder: (context, index) {
                final creation = controller.creations[index];
                return _buildWorkCard(creation);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildWorkCard(UserCreation creation) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            clipBehavior: Clip.hardEdge,
            child: creation.imagePath != null
                ? CachedNetworkImage(
                    imageUrl: creation.imagePath!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.eco, size: 48),
                    ),
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.eco, size: 48),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            creation.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWorks() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'No works yet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIVideosSection(BuildContext context, ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'AI Videos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: Obx(() {
            final aiVideos = controller.creations
                .where((c) => c.hasVideo || c.videoUrl != null)
                .take(3)
                .toList();
            
            if (aiVideos.isEmpty) {
              return _buildEmptyVideos();
            }
            
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: aiVideos.length,
              itemBuilder: (context, index) {
                return _buildVideoCard(aiVideos[index]);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildVideoCard(UserCreation creation) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                creation.imagePath != null
                    ? CachedNetworkImage(
                        imageUrl: creation.imagePath!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : Container(color: Colors.grey[200]),
                Center(
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF0F172A),
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            creation.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyVideos() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'No AI videos yet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, 
    ProfileController controller,
    AppLocalizations t,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSettingsItem(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              _showLanguageModal(context);
            },
          ),
          const SizedBox(height: 8),
          _buildSettingsItem(
            icon: Icons.support_agent_rounded,
            title: 'Customer Support',
            onTap: () {
              // 客服支持
            },
          ),
          const SizedBox(height: 8),
          _buildSettingsItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              // 隐私政策
            },
          ),
          const SizedBox(height: 8),
          _buildSettingsItem(
            icon: Icons.logout_rounded,
            title: 'Log Out',
            titleColor: Colors.red,
            onTap: () async {
              await _showLogoutDialog(context, controller, t);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: titleColor ?? const Color(0xFF64748B),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          color: titleColor ?? const Color(0xFF0F172A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF64748B),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              _buildLanguageOption(
                context,
                'English',
                isSelected: true,
              ),
              _buildLanguageOption(
                context,
                '简体中文',
                isSelected: false,
              ),
              _buildLanguageOption(
                context,
                'Español',
                isSelected: false,
              ),
              _buildLanguageOption(
                context,
                'Français',
                isSelected: false,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String language, {
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Get.snackbar(
            'Language Updated',
            'Language changed to $language',
            backgroundColor: const Color(0xFF22C55E),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            duration: const Duration(seconds: 2),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  language,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected 
                        ? const Color(0xFF22C55E) 
                        : const Color(0xFF0F172A),
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(
    BuildContext context,
    ProfileController controller,
    AppLocalizations t,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(t.logoutConfirmTitle),
        content: Text(t.logoutConfirmDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              t.cancel,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              t.logout,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _handleLogout(controller);
    }
  }

  Future<void> _handleLogout(ProfileController controller) async {
    try {
      // 显示加载提示
      Get.dialog(
        const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Logging out...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // 调用 ProfileController 的退出登录方法
      await controller.executeLogout();

      // 关闭加载对话框
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // 显示成功提示
      Get.snackbar(
        'Success',
        'You have been logged out successfully',
        backgroundColor: const Color(0xFF22C55E),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );

      // 等待一小段时间让用户看到提示
      await Future.delayed(const Duration(milliseconds: 500));

      // 优先使用回调，如果没有回调则使用 Get.find 方式
      if (onLogout != null) {
        print('✅ 调用 onLogout 回调');
        onLogout!();
      } else {
        print('⚠️ 没有 onLogout 回调，尝试直接导航');
        // 尝试使用 FitnessAppHomeScreen 的导航方法
        try {
          if (Get.isRegistered<AppNavigationController>()) {
            AppNavigationController.instance.navigateToLogin();
          } else {
            print('❌ AppNavigationController 未注册');
          }
        } catch (e) {
          print('❌ 导航失败: $e');
        }
      }
    } catch (e) {
      // 关闭加载对话框
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // 显示错误提示
      Get.snackbar(
        'Error',
        'Logout completed but navigation failed',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );

      // 即使出错也尝试调用回调
      try {
        if (onLogout != null) {
          onLogout!();
        } else if (Get.isRegistered<AppNavigationController>()) {
          AppNavigationController.instance.navigateToLogin();
        }
      } catch (navError) {
        print('❌ 导航到登录页失败: $navError');
      }
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
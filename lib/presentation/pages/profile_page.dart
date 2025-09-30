import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/profile_controller.dart';
import '../../l10n/app_localizations.dart';
// import '../widgets/bottom_navigation_widget.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback? onLogout;
  
  const ProfilePage({super.key, this.onLogout, this.animationController});

  final AnimationController? animationController;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, controller),
                const SizedBox(height: 16),
                _buildPremiumCard(context, t),
                const SizedBox(height: 16),
                _buildStatsCard(context, controller, t),
                const SizedBox(height: 16),
                _buildCreationsTitle(t),
                const SizedBox(height: 12),
                _buildCreationsGrid(controller),
                const SizedBox(height: 24),
                _buildLogoutButton(controller, t, context),
                const SizedBox(height: 100), // 为底部导航栏留出空间
              ],
            ),
          ),
        ),
      ),
      // bottomNavigationBar: const BottomNavigationWidget(currentIndex: 3),
    );
  }

  Widget _buildHeader(BuildContext context, ProfileController controller) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: const Color(0xFF16A34A),
                    fontWeight: FontWeight.w800,
                    fontSize: 32,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              controller.displayName.value.isNotEmpty 
                  ? 'Hello, ${controller.displayName.value}' 
                  : 'My Plants & Creations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF9333EA),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        _buildUserAvatar(controller),
      ],
    ));
  }

  Widget _buildUserAvatar(ProfileController controller) {
    return Obx(() {
      // 如果用户有头像URL，显示网络图片
      if (controller.currentUser.value?.avatarUrl?.isNotEmpty == true) {
        return CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(controller.currentUser.value!.avatarUrl!),
          onBackgroundImageError: (exception, stackTrace) {
            // 加载失败时显示文字头像
          },
          child: controller.currentUser.value!.avatarUrl!.isEmpty 
              ? Text(
                  controller.avatarText.value,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                )
              : null,
        );
      } else {
        // 显示文字头像
        return CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF6366F1),
          child: Text(
            controller.avatarText.value,
            style: const TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );
      }
    });
  }

  Widget _buildPremiumCard(BuildContext context, AppLocalizations t) {
    final controller = Get.find<ProfileController>();
    
    return Obx(() {
      // 如果已经是付费用户，显示不同的卡片
      if (controller.isPremium.value) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.workspace_premium, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Premium Creator',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Unlimited AI video generation',
                          style: TextStyle(color: Colors.white.withOpacity(0.9)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '✓ Premium Active',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        // 免费用户显示升级卡片
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE0EC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.workspace_premium, color: Color(0xFFE11D48)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.premiumCreator,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFBE185D),
                          ),
                        ),
                        Text(
                          '${controller.remainingVideoQuota} free videos remaining',
                          style: const TextStyle(color: Color(0xFF9D174D)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF472B6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    // TODO: 导航到订阅页面
                  },
                  child: Text(t.goPremium),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget _buildStatsCard(BuildContext context, ProfileController c, AppLocalizations t) {
    Widget stat(String label, String value, {Color? valueColor}) => Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value, 
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.w800, 
                  color: valueColor ?? AppTheme.primaryPurple,
                ),
              ),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 6, height: 24, decoration: BoxDecoration(color: const Color(0xFF16A34A), borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 8),
              Text(t.myStats, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Row(
                children: [
                  stat(
                    'Plant IDs', 
                    c.currentUser.value?.identificationCount.toString() ?? '0',
                    valueColor: const Color(0xFF16A34A),
                  ),
                  stat(
                    'AI Videos', 
                    c.currentUser.value?.videoGenerationCount.toString() ?? '0',
                    valueColor: const Color(0xFF8B5CF6),
                  ),
                  stat(
                    'Total Views', 
                    _formatViewsCount(c.viewsCount.value),
                    valueColor: const Color(0xFFEF4444),
                  ),
                ],
              )),
          // 添加用户类型和注册时间信息
          const SizedBox(height: 16),
          Obx(() {
            final user = c.currentUser.value;
            if (user != null) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Member since ${_formatMemberSince(user.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: c.isPremium.value ? const Color(0xFF16A34A) : Colors.grey[400],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        c.isPremium.value ? 'Premium' : 'Free',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  String _formatMemberSince(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }

  Widget _buildCreationsTitle(AppLocalizations t) {
    return Row(
      children: [
        Container(width: 6, height: 24, decoration: BoxDecoration(color: const Color(0xFF16A34A), borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Text(t.myCreations, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildCreationsGrid(ProfileController c) {
    return Obx(() {
      if (c.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (c.creations.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.eco,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No creations yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start identifying plants to see them here',
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

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: c.creations.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final creation = c.creations[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 图片部分
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: _buildCreationImage(creation),
                    ),
                  ),
                ),
                // 标题和统计信息部分
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        creation.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              _formatViews(creation.viewCount),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _formatDate(creation.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildCreationImage(UserCreation creation) {
    // 优先使用用户上传的图片
    if (creation.imagePath != null && creation.imagePath!.isNotEmpty) {
      // 如果是网络图片
      if (creation.imagePath!.startsWith('http')) {
        return Image.network(
          creation.imagePath!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultPlantImage();
          },
        );
      }
      // 如果是本地文件
      else {
        return Image.asset(
          creation.imagePath!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultPlantImage();
          },
        );
      }
    }
    // 使用默认植物图片
    return _buildDefaultPlantImage();
  }

  Widget _buildDefaultPlantImage() {
    return Container(
      color: Colors.grey[300],
      child: Icon(
        Icons.eco,
        color: Colors.grey[600],
        size: 32,
      ),
    );
  }

  String _formatViewsCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    } else {
      return views.toString();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildLogoutButton(ProfileController c, AppLocalizations t, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout, color: Colors.redAccent),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          foregroundColor: Colors.redAccent,
        ),
        onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(t.logoutConfirmTitle),
              content: Text(t.logoutConfirmDesc),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), 
                  child: Text(t.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), 
                  child: Text(t.logout),
                ),
              ],
            ),
          );
          if (ok == true) {
            print('🔄 ProfilePage: 开始执行退出登录');
            await c.executeLogout();
            print('✅ ProfilePage: 退出登录完成，调用回调');
            // 调用退出登录回调
            if (onLogout != null) {
              onLogout!();
              print('✅ ProfilePage: 退出登录回调已调用');
            } else {
              print('⚠️ ProfilePage: 退出登录回调为空');
            }
          }
        },
        label: Text(t.logout),
      ),
    );
  }
}
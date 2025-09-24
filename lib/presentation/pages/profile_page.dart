import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/profile_controller.dart';
import '../../l10n/app_localizations.dart';
// import '../widgets/bottom_navigation_widget.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback? onLogout;
  
  const ProfilePage({super.key, this.onLogout,this.animationController });

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
    return Row(
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
              'My Plants & Creations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF9333EA),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF6366F1),
          child: const Text(
            'JS',
            style: TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumCard(BuildContext context, AppLocalizations t) {
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
                      t.premiumDesc,
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
              onPressed: () {},
              child: Text(t.goPremium),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, ProfileController c, AppLocalizations t) {
    Widget stat(String label, String value) => Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.primaryPurple)),
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
                  stat(t.creations, c.creationsCount.value.toString()),
                  stat(t.aiVideos, c.aiVideosCount.value.toString()),
                  stat(t.views, '${c.viewsCount.value}K'),
                ],
              )),
        ],
      ),
    );
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
    // 模拟设计图中的作品数据
    final mockCreations = [
      {
        'image': 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?ixlib=rb-4.0.3&auto=format&fit=crop&w=800',
        'title': 'MacBook Pro'
      },
      {
        'image': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?ixlib=rb-4.0.3&auto=format&fit=crop&w=800', 
        'title': 'Office Setup'
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mockCreations.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final item = mockCreations[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                item['image']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
              // 如果需要显示标题，可以取消注释下面的代码
              // Positioned(
              //   left: 8,
              //   bottom: 8,
              //   right: 8,
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              //     decoration: BoxDecoration(
              //       color: Colors.black45,
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     child: Text(
              //       item['title']!,
              //       maxLines: 1,
              //       overflow: TextOverflow.ellipsis,
              //       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              //     ),
              //   ),
              // )
            ],
          ),
        );
      },
    );
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
              print('❌ ProfilePage: 退出登录回调为空');
            }
          }
        },
        label: Text(t.logout),
      ),
    );
  }

}




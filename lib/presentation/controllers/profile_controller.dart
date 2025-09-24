import 'package:get/get.dart';
import '../../data/models/plant_identification.dart';
import '../../data/services/recent_identification_service.dart';
import '../../data/services/auth_service.dart';
import '../../core/routes/app_routes.dart';

class ProfileController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<PlantIdentification> creations = <PlantIdentification>[].obs;
  final RxString displayName = ''.obs;
  final RxString avatarText = ''.obs;
  final RxInt creationsCount = 0.obs;
  final RxInt aiVideosCount = 0.obs;
  final RxInt viewsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
    loadCreations();
  }

  void _loadUser() {
    final AuthService auth = Get.find<AuthService>();
    final user = auth.currentUser;
    if (user != null) {
      displayName.value = user.fullName?.isNotEmpty == true
          ? user.fullName!
          : (user.username?.isNotEmpty == true ? user.username! : 'Guest');
      avatarText.value = 'JS'; // 固定显示 JS
      // 设计图中的固定数值
      creationsCount.value = 18;
      aiVideosCount.value = 12;
      viewsCount.value = 52; // 显示时会加上 K
    }
  }

  Future<void> loadCreations() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      final List<PlantIdentification> list =
          await RecentIdentificationService.getRecentIdentifications(limit: 24);
      creations.assignAll(list);
    } catch (e) {
      Get.log('加载作品失败: $e');
      if (e.toString().contains('401') || e.toString().contains('403')) {
        print('认证失败，需要重新登录');
        // 不再使用路由跳转，认证失败应该由全局处理
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> executeLogout() async {
    final AuthService auth = Get.find<AuthService>();
    await auth.logout();
    print('✅ 用户已退出登录');
    // 不再使用路由跳转，由 ProfilePage 的回调来处理导航
  }
}



import 'package:get/get.dart';
import '../../data/services/auth_service.dart';

// 简化的用户模型
class SimpleUser {
  final String id;
  final String? email;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final int identificationCount;
  final int videoGenerationCount;
  final DateTime createdAt;
  final String userType;

  SimpleUser({
    required this.id,
    this.email,
    this.username,
    this.fullName,
    this.avatarUrl,
    required this.identificationCount,
    required this.videoGenerationCount,
    required this.createdAt,
    required this.userType,
  });
}

// 简化的订阅模型
class SimpleSubscription {
  final String id;
  final String subscriptionType;
  final String status;
  final bool isPremium;
  final int monthlyVideoQuota;
  final int usedVideoQuota;

  SimpleSubscription({
    required this.id,
    required this.subscriptionType,
    required this.status,
    required this.isPremium,
    required this.monthlyVideoQuota,
    required this.usedVideoQuota,
  });

  int get remainingVideoQuota => (monthlyVideoQuota - usedVideoQuota).clamp(0, monthlyVideoQuota);
}

// 作品数据模型
class UserCreation {
  final String id;
  final String title;
  final String? imagePath;
  final String? description;
  final int viewCount;
  final int likeCount;
  final DateTime createdAt;
  final bool hasVideo;
  final String? videoUrl;

  UserCreation({
    required this.id,
    required this.title,
    this.imagePath,
    this.description,
    this.viewCount = 0,
    this.likeCount = 0,
    required this.createdAt,
    this.hasVideo = false,
    this.videoUrl,
  });
}

class ProfileController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<UserCreation> creations = <UserCreation>[].obs;
  final Rx<SimpleUser?> currentUser = Rx<SimpleUser?>(null);
  final Rx<SimpleSubscription?> currentSubscription = Rx<SimpleSubscription?>(null);
  final RxString displayName = ''.obs;
  final RxString avatarText = ''.obs;
  final RxInt creationsCount = 0.obs;
  final RxInt aiVideosCount = 0.obs;
  final RxInt viewsCount = 0.obs;
  final RxBool isPremium = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
    loadCreations();
    _loadSubscription();
  }

  void _loadUser() {
    // 临时使用模拟用户数据
    final user = _getMockUser();
    if (user != null) {
      currentUser.value = user;
      
      // 设置显示名称
      displayName.value = _getDisplayName(user);
      
      // 生成头像文字
      avatarText.value = _generateAvatarText(user);
      
      // 设置基础统计数据（从用户表获取）
      creationsCount.value = user.identificationCount;
      aiVideosCount.value = user.videoGenerationCount;
    }
  }

  // 模拟用户数据
  SimpleUser? _getMockUser() {
    return SimpleUser(
      id: 'user_123',
      email: 'john.doe@example.com',
      username: 'johndoe',
      fullName: 'John Doe',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      identificationCount: 42,
      videoGenerationCount: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      userType: 'free',
    );
  }

  String _getDisplayName(SimpleUser user) {
    if (user.fullName?.isNotEmpty == true) {
      return user.fullName!;
    } else if (user.username?.isNotEmpty == true) {
      return user.username!;
    } else if (user.email?.isNotEmpty == true) {
      return user.email!.split('@')[0];
    } else {
      return 'Guest';
    }
  }

  String _generateAvatarText(SimpleUser user) {
    if (user.fullName?.isNotEmpty == true) {
      final names = user.fullName!.trim().split(RegExp(r'\s+'));
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else {
        return user.fullName![0].toUpperCase();
      }
    } else if (user.username?.isNotEmpty == true) {
      return user.username![0].toUpperCase();
    } else if (user.email?.isNotEmpty == true) {
      return user.email![0].toUpperCase();
    }
    return 'U';
  }

  Future<void> _loadSubscription() async {
    try {
      // 临时模拟数据
      final mockSubscription = SimpleSubscription(
        id: 'sub_123',
        subscriptionType: 'free',
        status: 'active',
        isPremium: false,
        monthlyVideoQuota: 5,
        usedVideoQuota: 3,
      );
      
      currentSubscription.value = mockSubscription;
      isPremium.value = mockSubscription.isPremium;
    } catch (e) {
      print('加载订阅信息失败: $e');
    }
  }

  void _loadStats() {
    // 基于作品数据计算统计
    int totalViews = creations.fold(0, (sum, creation) => sum + creation.viewCount);
    viewsCount.value = totalViews;
    
    // 重新计算作品相关统计
    creationsCount.value = creations.length;
    aiVideosCount.value = creations.where((creation) => 
      creation.hasVideo == true || creation.videoUrl?.isNotEmpty == true
    ).length;
  }

  Future<void> loadCreations() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      
      // 临时使用模拟数据
      await _loadMockCreations();
      
      // 加载完成后更新统计数据
      _loadStats();
    } catch (e) {
      print('加载作品失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 模拟数据加载
  Future<void> _loadMockCreations() async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final mockData = [
      UserCreation(
        id: '1',
        title: '樱花四季变化',
        imagePath: 'https://images.unsplash.com/photo-1522383225653-ed111181a951?w=400',
        description: '记录樱花从春天盛开到秋天落叶的完整过程',
        viewCount: 24600,
        likeCount: 342,
        createdAt: DateTime.now().subtract(const Duration(days: 23)),
        hasVideo: true,
      ),
      UserCreation(
        id: '2',
        title: '室内绿植指南',
        imagePath: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400',
        description: '适合新手的室内植物养护技巧分享',
        viewCount: 18200,
        likeCount: 289,
        createdAt: DateTime.now().subtract(const Duration(days: 37)),
        hasVideo: false,
      ),
      UserCreation(
        id: '3',
        title: '多肉植物组合',
        imagePath: 'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=400',
        description: '创意多肉植物搭配方案',
        viewCount: 12800,
        likeCount: 156,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        hasVideo: true,
      ),
    ];
    
    creations.assignAll(mockData);
  }

  // 刷新用户数据
  Future<void> refreshUserData() async {
    _loadUser();
    await Future.wait([
      loadCreations(),
      _loadSubscription(),
    ]);
  }

  // 检查用户是否有剩余的免费视频配额
  bool get hasVideoQuota {
    if (isPremium.value) return true;
    final subscription = currentSubscription.value;
    if (subscription != null) {
      return subscription.remainingVideoQuota > 0;
    }
    return false;
  }

  // 获取剩余视频配额
  int get remainingVideoQuota {
    if (isPremium.value) return -1;
    final subscription = currentSubscription.value;
    if (subscription != null) {
      return subscription.remainingVideoQuota;
    }
    return 0;
  }

  /// 执行退出登录（调用 AuthService API）
  Future<void> executeLogout() async {
    try {
      print('🔄 ProfileController: 开始执行退出登录');
      
      // 获取 AuthService 实例
      final authService = AuthService.instance;
      
      // 调用 AuthService 的 logout 方法
      // 这会调用后端 API 并清除本地认证数据
      await authService.logout();
      
      print('✅ ProfileController: AuthService.logout() 调用成功');
      
      // 清空本地用户数据
      currentUser.value = null;
      currentSubscription.value = null;
      creations.clear();
      displayName.value = '';
      avatarText.value = '';
      creationsCount.value = 0;
      aiVideosCount.value = 0;
      viewsCount.value = 0;
      isPremium.value = false;
      
      print('✅ ProfileController: 本地数据清除完成');
      
    } catch (e) {
      print('❌ ProfileController: 退出登录失败: $e');
      
      // 即使 API 调用失败，也要清除本地数据
      try {
        currentUser.value = null;
        currentSubscription.value = null;
        creations.clear();
        displayName.value = '';
        avatarText.value = '';
        creationsCount.value = 0;
        aiVideosCount.value = 0;
        viewsCount.value = 0;
        isPremium.value = false;
        
        print('⚠️ ProfileController: API失败但本地数据已清除');
      } catch (clearError) {
        print('❌ ProfileController: 清除本地数据失败: $clearError');
      }
      
      // 重新抛出异常，让 UI 层处理
      rethrow;
    }
  }
}
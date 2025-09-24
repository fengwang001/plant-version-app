/// 认证服务 - 统一管理用户认证状态和业务逻辑
import 'package:get/get.dart';
import 'package:flutter_application_1/data/models/auth_models.dart';
import 'package:flutter_application_1/data/services/auth_api_service.dart';
import 'package:flutter_application_1/data/services/token_storage_service.dart';

class AuthService extends GetxService {
  static AuthService get instance => Get.find<AuthService>();
  
  final AuthApiService _apiService = AuthApiService();
  
  // 响应式状态
  final Rx<AuthStatus> _authStatus = AuthStatus.unauthenticated.obs;
  final Rx<UserResponse?> _currentUser = Rx<UserResponse?>(null);
  final RxBool _isInitialized = false.obs;

  // Getters
  AuthStatus get authStatus => _authStatus.value;
  UserResponse? get currentUser => _currentUser.value;
  bool get isInitialized => _isInitialized.value;
  bool get isLoggedIn => authStatus == AuthStatus.authenticated || authStatus == AuthStatus.guest;
  bool get isGuest => currentUser?.isGuest ?? false;
  bool get isPremium => currentUser?.isPremium ?? false;
  String get userDisplayName => currentUser?.displayName ?? '未知用户';

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeAuth();
  }

  /// 初始化认证状态
  Future<void> _initializeAuth() async {
    try {
      // 初始化令牌存储
      await TokenStorageService.init();
      
      // 检查本地存储的认证信息
      final authResult = TokenStorageService.getAuthResult();
      
      if (authResult != null) {
        // 检查令牌是否有效
        if (TokenStorageService.isLoggedIn()) {
          _currentUser.value = authResult.user;
          _authStatus.value = authResult.user.isGuest 
              ? AuthStatus.guest 
              : AuthStatus.authenticated;
          
          // 检查是否需要刷新令牌
          if (TokenStorageService.shouldRefreshToken()) {
            await _refreshTokenSilently();
          }
        } else {
          // 令牌过期，清除认证数据
          await TokenStorageService.clearAuth();
          _authStatus.value = AuthStatus.unauthenticated;
        }
      } else {
        _authStatus.value = AuthStatus.unauthenticated;
      }
      
      _isInitialized.value = true;
      print('认证服务初始化完成: ${authStatus.name}');
    } catch (e) {
      print('认证服务初始化失败: $e');
      _authStatus.value = AuthStatus.unauthenticated;
      _isInitialized.value = true;
    }
  }

  /// 邮箱注册
  Future<AuthResult> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      _authStatus.value = AuthStatus.authenticating;
      
      // 调用注册API
      await _apiService.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      
      // 注册成功后自动登录
      final authResult = await loginWithEmail(
        email: email,
        password: password,
      );
      
      return authResult;
    } catch (e) {
      _authStatus.value = AuthStatus.failed;
      print('注册失败: $e');
      rethrow;
    }
  }

  /// 邮箱登录
  Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _authStatus.value = AuthStatus.authenticating;
      
      final authResult = await _apiService.loginWithEmail(
        email: email,
        password: password,
      );
      
      _currentUser.value = authResult.user;
      _authStatus.value = AuthStatus.authenticated;
      
      print('邮箱登录成功: ${authResult.user.displayName}');
      return authResult;
    } catch (e) {
      _authStatus.value = AuthStatus.failed;
      print('邮箱登录失败: $e');
      rethrow;
    }
  }

  /// 游客登录
  Future<AuthResult> loginAsGuest() async {
    try {
      _authStatus.value = AuthStatus.authenticating;
      
      final authResult = await _apiService.loginAsGuest();
      
      _currentUser.value = authResult.user;
      _authStatus.value = AuthStatus.guest;
      
      print('游客登录成功: ${authResult.user.displayName}');
      return authResult;
    } catch (e) {
      _authStatus.value = AuthStatus.failed;
      print('游客登录失败: $e');
      rethrow;
    }
  }

  /// Apple登录
  Future<AuthResult> loginWithApple({
    required String identityToken,
    String? authorizationCode,
    AppleUserInfo? userInfo,
  }) async {
    try {
      _authStatus.value = AuthStatus.authenticating;
      
      final authResult = await _apiService.loginWithApple(
        identityToken: identityToken,
        authorizationCode: authorizationCode,
        userInfo: userInfo,
      );
      
      _currentUser.value = authResult.user;
      _authStatus.value = AuthStatus.authenticated;
      
      print('Apple登录成功: ${authResult.user.displayName}');
      return authResult;
    } catch (e) {
      _authStatus.value = AuthStatus.failed;
      print('Apple登录失败: $e');
      rethrow;
    }
  }

  /// Google登录
  Future<AuthResult> loginWithGoogle({
    required String idToken,
    String? accessToken,
  }) async {
    try {
      _authStatus.value = AuthStatus.authenticating;
      
      final authResult = await _apiService.loginWithGoogle(
        idToken: idToken,
        accessToken: accessToken,
      );
      
      _currentUser.value = authResult.user;
      _authStatus.value = AuthStatus.authenticated;
      
      print('Google登录成功: ${authResult.user.displayName}');
      return authResult;
    } catch (e) {
      _authStatus.value = AuthStatus.failed;
      print('Google登录失败: $e');
      rethrow;
    }
  }

  /// 退出登录
  Future<void> logout() async {
    // 先更新状态，防止重复调用
    if (_authStatus.value == AuthStatus.unauthenticated) {
      print('用户已经退出登录');
      return;
    }
    
    _authStatus.value = AuthStatus.unauthenticated;
    _currentUser.value = null;
    
    try {
      // 发送退出登录请求到服务器
      await _apiService.logout();
      print('✅ 服务器退出登录成功');
    } catch (e) {
      print('⚠️ 服务器退出登录请求失败: $e');
      // 即使服务器请求失败，本地状态已经清理，不影响用户体验
    }
    
    print('✅ 用户已退出登录');
  }

  /// 刷新用户信息
  Future<void> refreshUserInfo() async {
    try {
      if (!isLoggedIn) return;
      
      final user = await _apiService.getCurrentUser();
      _currentUser.value = user;
      await TokenStorageService.updateUser(user);
      
      print('用户信息刷新成功');
    } catch (e) {
      print('刷新用户信息失败: $e');
      // 如果刷新失败，可能是令牌过期，尝试刷新令牌
      final refreshed = await _refreshTokenSilently();
      if (!refreshed) {
        // 刷新令牌也失败，退出登录
        await logout();
      }
    }
  }

  /// 静默刷新令牌
  Future<bool> _refreshTokenSilently() async {
    try {
      final newToken = await _apiService.refreshToken();
      if (newToken != null) {
        print('令牌刷新成功');
        return true;
      } else {
        print('令牌刷新失败');
        return false;
      }
    } catch (e) {
      print('静默刷新令牌失败: $e');
      return false;
    }
  }

  /// 检查API连接状态
  Future<bool> checkApiConnection() async {
    return await _apiService.checkConnection();
  }

  /// 获取访问令牌（用于其他API调用）
  String? getAccessToken() {
    return TokenStorageService.getAccessToken();
  }

  /// 检查是否需要登录
  bool requiresLogin() {
    return !isLoggedIn || authStatus == AuthStatus.unauthenticated;
  }

  /// 检查权限
  bool hasPermission(String permission) {
    if (!isLoggedIn) return false;
    
    switch (permission) {
      case 'premium_features':
        return isPremium;
      case 'plant_identification':
        return true; // 所有登录用户都可以使用
      case 'unlimited_identifications':
        return isPremium;
      default:
        return false;
    }
  }

  /// 获取认证头（用于API调用）
  Map<String, String>? getAuthHeaders() {
    final token = getAccessToken();
    if (token == null) return null;
    
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// 处理认证错误
  void handleAuthError(dynamic error) {
    if (error.toString().contains('401') || error.toString().contains('未授权')) {
      // 令牌可能过期，尝试刷新
      _refreshTokenSilently().then((success) {
        if (!success) {
          // 刷新失败，退出登录
          logout();
          Get.snackbar('登录过期', '请重新登录');
        }
      });
    }
  }

  /// 获取存储统计信息（调试用）
  Map<String, dynamic> getStorageStats() {
    return TokenStorageService.getStorageStats();
  }

  @override
  void onClose() {
    TokenStorageService.dispose();
    super.onClose();
  }
}

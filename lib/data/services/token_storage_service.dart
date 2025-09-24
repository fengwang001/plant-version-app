/// 令牌存储服务 - 安全存储认证令牌
import 'package:hive/hive.dart';
import 'package:flutter_application_1/data/models/auth_models.dart';

class TokenStorageService {
  static const String _boxName = 'auth_tokens';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_info';
  
  static Box? _box;

  /// 初始化存储服务
  static Future<void> init() async {
    try {
      _box = await Hive.openBox(_boxName);
    } catch (e) {
      print('TokenStorageService初始化失败: $e');
      // 如果打开失败，尝试删除并重新创建
      await Hive.deleteBoxFromDisk(_boxName);
      _box = await Hive.openBox(_boxName);
    }
  }

  /// 获取Box实例
  static Box get _storage {
    if (_box == null) {
      throw Exception('TokenStorageService未初始化，请先调用init()');
    }
    return _box!;
  }

  /// 保存认证令牌
  static Future<void> saveToken(AuthToken token) async {
    try {
      await _storage.put(_tokenKey, token.toJson());
      print('令牌保存成功');
    } catch (e) {
      print('保存令牌失败: $e');
      throw Exception('保存令牌失败');
    }
  }

  /// 获取认证令牌
  static AuthToken? getToken() {
    try {
      final tokenData = _storage.get(_tokenKey);
      if (tokenData == null) return null;
      
      final Map<String, dynamic> tokenMap = Map<String, dynamic>.from(tokenData);
      return AuthToken.fromJson(tokenMap);
    } catch (e) {
      print('获取令牌失败: $e');
      return null;
    }
  }

  /// 保存用户信息
  static Future<void> saveUser(UserResponse user) async {
    try {
      await _storage.put(_userKey, user.toJson());
      print('用户信息保存成功');
    } catch (e) {
      print('保存用户信息失败: $e');
      throw Exception('保存用户信息失败');
    }
  }

  /// 获取用户信息
  static UserResponse? getUser() {
    try {
      final userData = _storage.get(_userKey);
      if (userData == null) return null;
      
      final Map<String, dynamic> userMap = Map<String, dynamic>.from(userData);
      return UserResponse.fromJson(userMap);
    } catch (e) {
      print('获取用户信息失败: $e');
      return null;
    }
  }

  /// 保存完整认证结果
  static Future<void> saveAuthResult(AuthResult authResult) async {
    await Future.wait([
      saveToken(authResult.token),
      saveUser(authResult.user),
    ]);
  }

  /// 获取完整认证结果
  static AuthResult? getAuthResult() {
    final token = getToken();
    final user = getUser();
    
    if (token == null || user == null) return null;
    
    return AuthResult(token: token, user: user);
  }

  /// 检查是否已登录
  static bool isLoggedIn() {
    final token = getToken();
    if (token == null) return false;
    
    // 检查令牌是否过期
    final now = DateTime.now();
    final expiryTime = token.expiryTime;
    
    return now.isBefore(expiryTime);
  }

  /// 检查令牌是否需要刷新
  static bool shouldRefreshToken() {
    final token = getToken();
    if (token == null) return false;
    
    return token.shouldRefresh;
  }

  /// 获取访问令牌
  static String? getAccessToken() {
    final token = getToken();
    return token?.accessToken;
  }

  /// 获取刷新令牌
  static String? getRefreshToken() {
    final token = getToken();
    return token?.refreshToken;
  }

  /// 清除所有认证数据
  static Future<void> clearAuth() async {
    try {
      await _storage.delete(_tokenKey);
      await _storage.delete(_userKey);
      print('认证数据清除成功');
    } catch (e) {
      print('清除认证数据失败: $e');
      throw Exception('清除认证数据失败');
    }
  }

  /// 更新用户信息（保持令牌不变）
  static Future<void> updateUser(UserResponse user) async {
    await saveUser(user);
  }

  /// 获取用户ID
  static String? getUserId() {
    final user = getUser();
    return user?.id;
  }

  /// 获取用户邮箱
  static String? getUserEmail() {
    final user = getUser();
    return user?.email;
  }

  /// 检查是否为游客用户
  static bool isGuest() {
    final user = getUser();
    return user?.isGuest ?? true;
  }

  /// 检查是否为付费用户
  static bool isPremium() {
    final user = getUser();
    return user?.isPremium ?? false;
  }

  /// 获取用户显示名称
  static String getUserDisplayName() {
    final user = getUser();
    return user?.displayName ?? '未知用户';
  }

  /// 关闭存储服务
  static Future<void> dispose() async {
    await _box?.close();
    _box = null;
  }

  /// 获取存储统计信息
  static Map<String, dynamic> getStorageStats() {
    if (_box == null) return {'error': 'Storage not initialized'};
    
    return {
      'isOpen': _box!.isOpen,
      'length': _box!.length,
      'keys': _box!.keys.toList(),
      'hasToken': _storage.containsKey(_tokenKey),
      'hasUser': _storage.containsKey(_userKey),
      'isLoggedIn': isLoggedIn(),
      'shouldRefresh': shouldRefreshToken(),
    };
  }

  // 设备ID存储键
  static const String _webDeviceIdKey = 'web_device_id';
  static const String _desktopDeviceIdKey = 'desktop_device_id';
  static const String _fallbackDeviceIdKey = 'fallback_device_id';

  /// 获取Web设备ID
  static Future<String?> getWebDeviceId() async {
    if (_box == null) await init();
    return _storage.get(_webDeviceIdKey);
  }

  /// 保存Web设备ID
  static Future<void> saveWebDeviceId(String deviceId) async {
    if (_box == null) await init();
    await _storage.put(_webDeviceIdKey, deviceId);
  }

  /// 获取Desktop设备ID
  static Future<String?> getDesktopDeviceId() async {
    if (_box == null) await init();
    return _storage.get(_desktopDeviceIdKey);
  }

  /// 保存Desktop设备ID
  static Future<void> saveDesktopDeviceId(String deviceId) async {
    if (_box == null) await init();
    await _storage.put(_desktopDeviceIdKey, deviceId);
  }

  /// 获取Fallback设备ID
  static Future<String?> getFallbackDeviceId() async {
    if (_box == null) await init();
    return _storage.get(_fallbackDeviceIdKey);
  }

  /// 保存Fallback设备ID
  static Future<void> saveFallbackDeviceId(String deviceId) async {
    if (_box == null) await init();
    await _storage.put(_fallbackDeviceIdKey, deviceId);
  }

  /// 清除所有设备ID（用于调试）
  static Future<void> clearAllDeviceIds() async {
    if (_box == null) await init();
    await _storage.delete(_webDeviceIdKey);
    await _storage.delete(_desktopDeviceIdKey);
    await _storage.delete(_fallbackDeviceIdKey);
  }
}

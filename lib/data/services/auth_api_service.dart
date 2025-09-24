/// 认证API服务 - 处理用户认证相关的API调用
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data/models/auth_models.dart';
import 'package:flutter_application_1/data/services/token_storage_service.dart';
import 'package:flutter_application_1/core/config/app_config.dart';

class AuthApiService {
  final Dio _dio = Dio();
  
  AuthApiService() {
    final config = AppConfig.instance;
    
    _dio.options.baseUrl = config.apiFullUrl;
    _dio.options.connectTimeout = Duration(seconds: config.apiTimeout);
    _dio.options.receiveTimeout = Duration(seconds: config.apiTimeout);
    
    if (config.isDebugMode) {
      print('🔧 AuthApiService 初始化');
      print('   API地址: ${config.apiFullUrl}');
      print('   超时时间: ${config.apiTimeout}秒');
    }
    print('  AuthApiService API地址: ${config.apiFullUrl}');
    
    // 添加请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 自动添加认证头
        final token = TokenStorageService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // 添加Content-Type
        if (options.method == 'POST' || options.method == 'PUT') {
          options.headers['Content-Type'] = 'application/json';
        }
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('API响应: ${response.statusCode} - ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        print('API错误: ${e.response?.statusCode} - ${e.message}');
        
        // 处理401未授权错误
        if (e.response?.statusCode == 401) {
          // 尝试刷新令牌
          final refreshed = await _tryRefreshToken();
          if (refreshed) {
            // 重试原请求
            final token = TokenStorageService.getAccessToken();
            e.requestOptions.headers['Authorization'] = 'Bearer $token';
            
            try {
              final retryResponse = await _dio.request(
                e.requestOptions.path,
                data: e.requestOptions.data,
                queryParameters: e.requestOptions.queryParameters,
                options: Options(
                  method: e.requestOptions.method,
                  headers: e.requestOptions.headers,
                ),
              );
              return handler.resolve(retryResponse);
            } catch (retryError) {
              // 重试失败，清除认证数据并返回错误
              await TokenStorageService.clearAuth();
              return handler.next(e);
            }
          } else {
            // 刷新失败，清除认证数据
            await TokenStorageService.clearAuth();
          }
        }
        
        return handler.next(e);
      },
    ));
  }

  /// 邮箱注册
  Future<UserResponse> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        fullName: fullName,
      );
      
      final response = await _dio.post(
        '/auth/register',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200) {
        return UserResponse.fromJson(response.data);
      }
      throw Exception('注册失败: ${response.statusMessage}');
    } catch (e) {
      print('注册错误: $e');
      if (e is DioException && e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? '注册失败';
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }

  /// 邮箱登录
  Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest(email: email, password: password);
      
      final response = await _dio.post(
        '/auth/login',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200) {
        final token = AuthToken.fromJson(response.data);
        
        // 获取用户信息
        final userResponse = await _getCurrentUser(token.accessToken);
        
        final authResult = AuthResult(token: token, user: userResponse);
        
        // 保存认证结果
        await TokenStorageService.saveAuthResult(authResult);
        
        return authResult;
      }
      throw Exception('登录失败: ${response.statusMessage}');
    } catch (e) {
      print('登录错误: $e');
      if (e is DioException && e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? '登录失败';
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }

  /// 游客登录
  Future<AuthResult> loginAsGuest() async {
    try {
      final deviceInfo = await _getDeviceInfo();
      final request = GuestLoginRequest(
        deviceId: deviceInfo['deviceId']!,
        deviceType: deviceInfo['deviceType']!,
      );
      
      final response = await _dio.post(
        '/auth/login/guest',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final token = AuthToken.fromJson(response.data);
        
        // 获取用户信息
        final userResponse = await _getCurrentUser(token.accessToken);
        
        final authResult = AuthResult(token: token, user: userResponse);
        
        // 保存认证结果
        await TokenStorageService.saveAuthResult(authResult);
        
        return authResult;
      }
      throw Exception('游客登录失败: ${response.statusMessage}');
    } catch (e) {
      print('游客登录错误: $e');
      if (e is DioException && e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? '游客登录失败';
        throw Exception(errorMessage);
      }
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
      final request = AppleLoginRequest(
        identityToken: identityToken,
        authorizationCode: authorizationCode,
        userInfo: userInfo,
      );
      
      final response = await _dio.post(
        '/auth/login/apple',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200) {
        final token = AuthToken.fromJson(response.data);
        
        // 获取用户信息
        final userResponse = await _getCurrentUser(token.accessToken);
        
        final authResult = AuthResult(token: token, user: userResponse);
        
        // 保存认证结果
        await TokenStorageService.saveAuthResult(authResult);
        
        return authResult;
      }
      throw Exception('Apple登录失败: ${response.statusMessage}');
    } catch (e) {
      print('Apple登录错误: $e');
      if (e is DioException && e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 'Apple登录失败';
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }

  /// Google登录
  Future<AuthResult> loginWithGoogle({
    required String idToken,
    String? accessToken,
  }) async {
    try {
      final request = GoogleLoginRequest(
        idToken: idToken,
        accessToken: accessToken,
      );
      
      final response = await _dio.post(
        '/auth/login/google',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200) {
        final token = AuthToken.fromJson(response.data);
        
        // 获取用户信息
        final userResponse = await _getCurrentUser(token.accessToken);
        
        final authResult = AuthResult(token: token, user: userResponse);
        
        // 保存认证结果
        await TokenStorageService.saveAuthResult(authResult);
        
        return authResult;
      }
      throw Exception('Google登录失败: ${response.statusMessage}');
    } catch (e) {
      print('Google登录错误: $e');
      if (e is DioException && e.response != null) {
        final errorMessage = e.response?.data?['detail'] ?? 'Google登录失败';
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }

  /// 刷新令牌
  Future<AuthToken?> refreshToken() async {
    try {
      final refreshToken = TokenStorageService.getRefreshToken();
      if (refreshToken == null) {
        print('没有刷新令牌');
        return null;
      }
      
      final request = RefreshTokenRequest(refreshToken: refreshToken);
      
      final response = await _dio.post(
        '/auth/refresh',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200) {
        final newToken = AuthToken.fromJson(response.data);
        await TokenStorageService.saveToken(newToken);
        return newToken;
      }
      
      print('刷新令牌失败: ${response.statusMessage}');
      return null;
    } catch (e) {
      print('刷新令牌错误: $e');
      return null;
    }
  }

  /// 退出登录
  Future<void> logout() async {
    final accessToken = TokenStorageService.getAccessToken();
    
    try {
      // 如果有访问令牌，先发送退出登录请求
      if (accessToken != null) {
        await _dio.post(
          '/auth/logout',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );
        print('✅ 退出登录API调用成功');
      } else {
        print('⚠️ 没有访问令牌，跳过API调用');
      }
    } catch (e) {
      print('⚠️ 退出登录API调用失败: $e');
      // API失败不影响退出登录流程
    } finally {
      // 无论API调用是否成功，都要清除本地数据
      try {
        await TokenStorageService.clearAuth();
        print('✅ 本地认证数据清除成功');
      } catch (e) {
        print('❌ 清除本地认证数据失败: $e');
      }
    }
  }

  /// 获取当前用户信息
  Future<UserResponse> getCurrentUser() async {
    final token = TokenStorageService.getAccessToken();
    if (token == null) {
      throw Exception('未登录');
    }
    
    return await _getCurrentUser(token);
  }

  /// 内部方法：获取用户信息
  Future<UserResponse> _getCurrentUser(String accessToken) async {
    try {
      final response = await _dio.get(
        '/users/me',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      print('📡 获取用户信息响应状态: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return UserResponse.fromJson(response.data);
      }
      throw Exception('获取用户信息失败: ${response.statusMessage}');
    } catch (e) {
      print('获取用户信息错误: $e');
      rethrow;
    }
  }

  /// 内部方法：尝试刷新令牌
  Future<bool> _tryRefreshToken() async {
    try {
      final newToken = await refreshToken();
      return newToken != null;
    } catch (e) {
      print('自动刷新令牌失败: $e');
      return false;
    }
  }

  /// 获取设备信息
  Future<Map<String, String>> _getDeviceInfo() async {
    try {
      // 检查是否为Web平台
      if (kIsWeb) {
        // 为Web平台生成或获取持久化的设备ID
        final webDeviceId = await _getOrCreateWebDeviceId();
        return {
          'deviceId': webDeviceId,
          'deviceType': 'web',
        };
      }
      
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return {
          'deviceId': iosInfo.identifierForVendor ?? 'unknown_ios',
          'deviceType': 'ios',
        };
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return {
          'deviceId': androidInfo.id ?? 'unknown_android',
          'deviceType': 'android',
        };
      } else {
        // 其他平台（Windows, macOS, Linux等）
        final desktopDeviceId = await _getOrCreateDesktopDeviceId();
        return {
          'deviceId': desktopDeviceId,
          'deviceType': 'desktop',
        };
      }
    } catch (e) {
      print('获取设备信息失败: $e');
      // 提供安全的fallback，也使用持久化ID
      final fallbackDeviceId = await _getOrCreateFallbackDeviceId();
      return {
        'deviceId': fallbackDeviceId,
        'deviceType': kIsWeb ? 'web' : 'unknown',
      };
    }
  }

  /// 为Web平台获取或创建持久化的设备ID
  Future<String> _getOrCreateWebDeviceId() async {
    try {
      // 尝试从localStorage获取已存在的设备ID
      final existingId = await TokenStorageService.getWebDeviceId();
      if (existingId != null) {
        print('📱 使用已存在的Web设备ID: $existingId');
        return existingId;
      }
      
      // 生成新的设备ID
      final newId = 'web_${DateTime.now().millisecondsSinceEpoch}';
      await TokenStorageService.saveWebDeviceId(newId);
      print('📱 创建新的Web设备ID: $newId');
      return newId;
    } catch (e) {
      print('⚠️ Web设备ID处理失败: $e');
      return 'web_fallback_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// 为Desktop平台获取或创建持久化的设备ID
  Future<String> _getOrCreateDesktopDeviceId() async {
    try {
      // 尝试从本地存储获取已存在的设备ID
      final existingId = await TokenStorageService.getDesktopDeviceId();
      if (existingId != null) {
        print('🖥️ 使用已存在的Desktop设备ID: $existingId');
        return existingId;
      }
      
      // 生成新的设备ID
      final newId = 'desktop_${DateTime.now().millisecondsSinceEpoch}';
      await TokenStorageService.saveDesktopDeviceId(newId);
      print('🖥️ 创建新的Desktop设备ID: $newId');
      return newId;
    } catch (e) {
      print('⚠️ Desktop设备ID处理失败: $e');
      return 'desktop_fallback_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// 为Fallback情况获取或创建持久化的设备ID
  Future<String> _getOrCreateFallbackDeviceId() async {
    try {
      final existingId = await TokenStorageService.getFallbackDeviceId();
      if (existingId != null) {
        return existingId;
      }
      
      final newId = 'fallback_${DateTime.now().millisecondsSinceEpoch}';
      await TokenStorageService.saveFallbackDeviceId(newId);
      return newId;
    } catch (e) {
      return 'fallback_error_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// 检查API连接状态
  Future<bool> checkConnection() async {
    try {
      final config = AppConfig.instance;
      final healthUrl = config.healthCheckUrl;
      
      print('🔍 发送健康检查请求到: $healthUrl');
      final response = await _dio.get('/health');
      print('📡 健康检查响应: ${response.statusCode} - ${response.data}');
      
      final isHealthy = response.statusCode == 200 && response.data['status'] == 'healthy';
      print('💚 健康检查结果: ${isHealthy ? "健康" : "不健康"}');
      
      return isHealthy;
    } catch (e) {
      final config = AppConfig.instance;
      print('❌ API连接检查失败: $e');
      print('🔧 请确保后端服务在 ${config.apiBaseUrl} 运行');
      return false;
    }
  }
}

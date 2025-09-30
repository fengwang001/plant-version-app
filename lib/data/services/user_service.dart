// lib/data/services/user_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'package:flutter_application_1/core/config/app_config.dart';
import 'package:flutter_application_1/data/services/token_storage_service.dart';
import 'package:flutter_application_1/data/models/auth_models.dart';

class UserService {
   static final Dio _dio = _createDioInstance();
  
  /// 创建Dio实例
  static Dio _createDioInstance() {
    final config = AppConfig.instance;
    final dio = Dio(BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: Duration(seconds: config.apiTimeout),
      receiveTimeout: Duration(seconds: config.apiTimeout),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    if (config.isDebugMode) {
      print('🔧 ApiService 初始化');
      print('   API地址: ${config.apiBaseUrl}');
      print('   超时时间: ${config.apiTimeout}秒');
    }
    
    return dio;
  }
  
  // 获取用户信息
  static Future<UserResponse?> getUserProfile(String userId) async {
    try {
     final response = await _dio.get(
        '/users/me',
        options: Options(
          headers: {'Authorization': 'Bearer ${await _getAuthToken}'},
        ),
      );

      print('📡 获取用户信息响应状态: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return UserResponse.fromJson(response.data);
      }
      throw Exception('获取用户信息失败: ${response.statusMessage}');
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // 获取认证令牌的辅助方法
  static Future<String?> _getAuthToken() async {
    // TODO: 从本地存储或认证服务获取令牌
    // 这里需要根据您的认证实现来调整
     final token = TokenStorageService.getToken();
    return token?.accessToken;
  }
}

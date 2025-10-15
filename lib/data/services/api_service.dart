import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:image_picker/image_picker.dart';
import '../models/plant_identification.dart';
import '../models/plant.dart';
import 'token_storage_service.dart';
import '../../core/config/app_config.dart';
import 'package:flutter_application_1/fitness_app/fitness_app_home_screen.dart';

class ApiService {
  // Dio实例 - 使用配置管理的地址
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
  
  
  /// 获取最近识别列表
  static Future<List<PlantIdentification>> getRecentIdentifications({
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final path = '/api/v1/plants/identifications?skip=$skip&limit=$limit';
      final config = AppConfig.instance;
      print('🌐 发送API请求: ${config.apiBaseUrl}$path');

      // 设置认证头
      final String? token = TokenStorageService.getAccessToken();
      print('🔑 获取最近识别列表  使用访问令牌: ${token != null ? token : '未找到'}');
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      } else {
        print('⚠️ 未找到访问令牌');
        throw Exception('用户未认证，请登录');
      }
      
      final response = await _dio.get(path);
      print('📡 API响应状态: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('❌ API响应内容: ${response.data}');
      }
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => PlantIdentification.fromApiJson(item)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('❌ 认证失败，状态码: ${response.statusCode}');
        if (getx.Get.isRegistered<AppNavigationController>()) {
          AppNavigationController.instance.navigateToLogin();
        }
        throw Exception('认证失败，请重新登录');
      } else {
        throw Exception('获取识别历史失败: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        print('❌ Dio异常: ${e.type} - ${e.message}');
        if (e.response != null) {
          print('❌ 响应状态: ${e.response!.statusCode}');
        }
        if(e.response?.statusCode == 401) {
         
          // 使用新的导航方式，不使用路由跳转
          try {
            if (getx.Get.isRegistered<AppNavigationController>()) {
              AppNavigationController.instance.navigateToLogin();
            }
          } catch (e) {
            print('导航到登录页面失败: $e');
          }
          throw Exception('认证失败，请重新登录');
        }
      } else {
        print('❌ API调用失败: $e');
      }
      throw Exception('网络连接失败，请检查网络设置');
    }
  }
  
  /// 植物识别
  static Future<PlantIdentification> identifyPlant({
    required File imageFile,
    double? latitude,
    double? longitude,
    String? locationName,
  }) async {
    try {
      // 设置认证头
      final String? token = TokenStorageService.getAccessToken();
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
        print('🔑 植物识别使用访问令牌: ${token.substring(0, 20)}...');
      } else {
        print('⚠️ 植物识别未找到访问令牌');
      }
      
      // 创建FormData
      // 创建 FormData
      FormData formData = FormData.fromMap({
        // 文件字段 - 对应后端的 file 参数
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        // 可选参数
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (locationName != null) 'location_name': locationName,
      });
      print('🌱 发送植物识别请求...');
      final response = await _dio.post('/api/v1/plants/identify', data: formData);
      
      print('📡 植物识别响应状态: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        print('✅ 植物识别成功: ${data['common_name']}');
        return PlantIdentification.fromApiJson(data);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        if (getx.Get.isRegistered<AppNavigationController>()) {
          AppNavigationController.instance.navigateToLogin();
        }
        throw Exception('认证失败，请重新登录');
      } else {
        print('❌ 植物识别失败: ${response.data}');
        throw Exception('植物识别失败: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        print('❌ Dio异常: ${e.type} - ${e.message}');
        if (e.response != null) {
          print('❌ 响应状态: ${e.response!.statusCode}');
          print('❌ 响应数据: ${e.response!.data}');
        }
      } else {
        print('❌ 植物识别异常: $e');
      }
      throw Exception('植物识别失败，请检查网络设置');
    }
  }
  
  /// 获取植物详情
  static Future<Map<String, dynamic>?> getPlantDetail(String plantId) async {
    try {
      final path = '/api/v1/plants/$plantId';
      print('🌐 获取植物详情: ${AppConfig.instance.apiBaseUrl}$path');
      
      // 设置认证头
      final String? token = TokenStorageService.getAccessToken();
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await _dio.get(path);
      
      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        if (getx.Get.isRegistered<AppNavigationController>()) {
          AppNavigationController.instance.navigateToLogin();
        }
        throw Exception('认证失败，请重新登录');
      } else {
        print('❌ 获取植物详情失败: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      if (e is DioException) {
        print('❌ 获取植物详情异常: ${e.type} - ${e.message}');
        if (e.response != null) {
          print('❌ 响应状态: ${e.response!.statusCode}');
          print('❌ 响应数据: ${e.response!.data}');
          if(e.response?.statusCode == 401) {
            throw Exception('认证失败，请重新登录');
          }
        }
      } else {
        print('❌ 获取植物详情异常: $e');
      }
      return null;
    }
  }
  
  /// 搜索植物
  static Future<List<Map<String, dynamic>>> searchPlants(String query) async {
    try {
      final path = '/api/v1/plants?q=$query';
      print('🌐 搜索植物: ${AppConfig.instance.apiBaseUrl}$path');
      
      // 设置认证头
      final String? token = TokenStorageService.getAccessToken();
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await _dio.get(path);
      
      if (response.statusCode == 200) {
        final data = response.data;
        return List<Map<String, dynamic>>.from(data['items'] ?? []);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        if (getx.Get.isRegistered<AppNavigationController>()) {
          AppNavigationController.instance.navigateToLogin();
        }
        throw Exception('认证失败，请重新登录');
      } else {
        print('❌ 搜索植物失败: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      if (e is DioException) {
        print('❌ 搜索植物异常: ${e.type} - ${e.message}');
        if (e.response != null) {
          print('❌ 响应状态: ${e.response!.statusCode}');
          print('❌ 响应数据: ${e.response!.data}');
          if(e.response?.statusCode == 401) {
            throw Exception('认证失败，请重新登录');
          }
        }
      } else {
        print('❌ 搜索植物异常: $e');
      }
      return [];
    }
  }
  
  /// 获取推荐植物
  static Future<List<Plant>> getFeaturedPlants({int limit = 10}) async {
    try {
      final path = '/api/v1/plants/featured/list?limit=$limit';
      print('🌐 获取推荐植物: ${AppConfig.instance.apiBaseUrl}$path');
      
      // 设置认证头
      final String? token = TokenStorageService.getAccessToken();
      print('🔑 获取推荐植物  使用访问令牌: ${token != null ? token : '未找到'}');
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await _dio.get(path);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('✅ 获取到 ${data.length} 个推荐植物');
        return data.map((item) => Plant.fromApiJson(item)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        if (getx.Get.isRegistered<AppNavigationController>()) {
          AppNavigationController.instance.navigateToLogin();
        }
        throw Exception('认证失败，请重新登录');
      } else {
        print('❌ 获取推荐植物失败: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      if (e is DioException) {
        print('❌ 获取推荐植物异常: ${e.type} - ${e.message}');
        if (e.response != null) {
          print('❌ 响应状态: ${e.response!.statusCode}');
          print('❌ 响应数据: ${e.response!.data}');
          if(e.response?.statusCode == 401) {
            throw Exception('认证失败，请重新登录');
          }
        }
      } else {
        print('❌ 获取推荐植物异常: $e');
      }
      return [];
    }
  }
  
  /// 获取热门植物
  static Future<List<Map<String, dynamic>>> getPopularPlants() async {
    try {
      final path = '/api/v1/plants/popular/list';
      print('🌐 获取热门植物: ${AppConfig.instance.apiBaseUrl}$path');
      
      // 设置认证头
      final String? token = TokenStorageService.getAccessToken();
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await _dio.get(path);
      
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        if (getx.Get.isRegistered<AppNavigationController>()) {
          AppNavigationController.instance.navigateToLogin();
        }
        throw Exception('认证失败，请重新登录');
      } else {
        print('❌ 获取热门植物失败: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      if (e is DioException) {
        print('❌ 获取热门植物异常: ${e.type} - ${e.message}');
        if (e.response != null) {
          print('❌ 响应状态: ${e.response!.statusCode}');
          print('❌ 响应数据: ${e.response!.data}');
          if(e.response?.statusCode == 401) {
            throw Exception('认证失败，请重新登录');
          }
        }
      } else {
        print('❌ 获取热门植物异常: $e');
      }
      return [];
    }
  }
  
  /// 获取识别记录详情
  static Future<Map<String, dynamic>?> getIdentificationDetail(String identificationId) async {
    try {
      final path = '/api/v1/plants/identifications/$identificationId';
      print('🌐 获取识别详情: ${AppConfig.instance.apiBaseUrl}$path');
      
      // 设置认证头
      final String? token = TokenStorageService.getAccessToken();
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await _dio.get(path);
      
      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        if (getx.Get.isRegistered<AppNavigationController>()) {
          AppNavigationController.instance.navigateToLogin();
        }
        throw Exception('认证失败，请重新登录');
      } else {
        print('❌ 获取识别详情失败: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      if (e is DioException) {
        print('❌ 获取识别详情异常: ${e.type} - ${e.message}');
        if (e.response != null) {
          print('❌ 响应状态: ${e.response!.statusCode}');
          print('❌ 响应数据: ${e.response!.data}');
          if(e.response?.statusCode == 401) {
            throw Exception('认证失败，请重新登录');
          }
        }
      } else {
        print('❌ 获取识别详情异常: $e');
      }
      return null;
    }
  }
  
  /// 提交识别反馈
  static Future<bool> submitIdentificationFeedback(
    String identificationId,
    String feedback,
  ) async {
    try {
      final path = '/api/v1/plants/identifications/$identificationId/feedback';
      
      // 设置认证头
      final String? token = TokenStorageService.getAccessToken();
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await _dio.post(path, data: {'feedback': feedback});
      
      if (response.statusCode == 200) {
        print('✅ 反馈提交成功');
        return true;
      } else {
        print('❌ 反馈提交失败: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      if (e is DioException) {
        print('❌ 提交反馈异常: ${e.type} - ${e.message}');
      } else {
        print('❌ 提交反馈异常: $e');
      }
      return false;
    }
  }
}

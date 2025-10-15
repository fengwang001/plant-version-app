/// 应用配置管理类
/// 使用Flutter标准方式：编译时环境变量（--dart-define）和代码默认值
import 'package:flutter/foundation.dart';

/// 应用配置类
/// 
/// 使用方式：
/// 1. 开发时使用默认值
/// 2. 构建时通过 --dart-define 传递配置
/// 
/// 示例：
/// flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8000
/// flutter build apk --dart-define=API_BASE_URL=https://api.production.com --dart-define=DEBUG_MODE=false
class AppConfig {
  static AppConfig? _instance;
  static AppConfig get instance => _instance ??= AppConfig._internal();
  
  AppConfig._internal();
  
  /// API基础地址
  /// 默认值：本地开发服务器地址
  /// 可通过 --dart-define=API_BASE_URL=xxx 覆盖
  String get apiBaseUrl {
    return const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://172.20.10.7:8000',
      // 192.168.31.189
    );
  }
  
  /// API完整地址（包含版本路径）
  String get apiFullUrl => '$apiBaseUrl/api/v1';
  
  /// API请求超时时间（秒）
  /// 默认值：30秒
  /// 可通过 --dart-define=API_TIMEOUT=60 覆盖
  int get apiTimeout {
    const timeoutStr = String.fromEnvironment('API_TIMEOUT', defaultValue: '30');
    return int.tryParse(timeoutStr) ?? 30;
  }
  
  /// 是否为调试模式
  /// 默认值：根据编译模式自动判断（debug模式为true，release模式为false）
  /// 可通过 --dart-define=DEBUG_MODE=true 覆盖
  bool get isDebugMode {
    const debugStr = String.fromEnvironment('DEBUG_MODE');
    if (debugStr.isNotEmpty) {
      return debugStr.toLowerCase() == 'true';
    }
    return kDebugMode;
  }
  
  /// 日志级别
  /// 默认值：debug模式为'debug'，release模式为'error'
  /// 可通过 --dart-define=LOG_LEVEL=info 覆盖
  String get logLevel {
    const level = String.fromEnvironment('LOG_LEVEL');
    if (level.isNotEmpty) {
      return level;
    }
    return kDebugMode ? 'debug' : 'error';
  }
  
  /// 应用名称
  /// 默认值：PlantVision
  /// 可通过 --dart-define=APP_NAME="自定义名称" 覆盖
  String get appName {
    return const String.fromEnvironment(
      'APP_NAME',
      defaultValue: 'PlantVision',
    );
  }
  
  /// 是否启用模拟数据
  /// 默认值：false
  /// 可通过 --dart-define=ENABLE_MOCK_DATA=true 覆盖
  bool get enableMockData {
    const mockStr = String.fromEnvironment('ENABLE_MOCK_DATA', defaultValue: 'false');
    return mockStr.toLowerCase() == 'true';
  }
  
  /// 是否启用分析功能
  /// 默认值：false
  /// 可通过 --dart-define=ENABLE_ANALYTICS=true 覆盖
  bool get enableAnalytics {
    const analyticsStr = String.fromEnvironment('ENABLE_ANALYTICS', defaultValue: 'false');
    return analyticsStr.toLowerCase() == 'true';
  }
  
  /// 初始化配置（打印当前配置信息）
  static Future<void> initialize() async {
    final instance = AppConfig.instance;
    
    if (kDebugMode) {
      print('🔧 应用配置初始化完成');
      print('🌐 API地址: ${instance.apiBaseUrl}');
      print('🔗 API完整地址: ${instance.apiFullUrl}');
      print('⏱️ 超时时间: ${instance.apiTimeout}秒');
      print('🐛 调试模式: ${instance.isDebugMode}');
      print('📝 日志级别: ${instance.logLevel}');
      print('📱 应用名称: ${instance.appName}');
      print('🧪 模拟数据: ${instance.enableMockData}');
      print('📊 分析功能: ${instance.enableAnalytics}');
      print('');
      print('💡 提示：可通过 --dart-define 参数覆盖配置');
      print('   例如：flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8000');
    }
  }
}

/// 配置扩展方法
extension AppConfigExtension on AppConfig {
  /// 获取健康检查地址
  String get healthCheckUrl => '$apiBaseUrl/health';
  
  /// 获取完整的API端点地址
  String getApiEndpoint(String path) {
    if (path.startsWith('/')) {
      return '$apiFullUrl$path';
    }
    return '$apiFullUrl/$path';
  }
}
import 'dart:io';
import '../models/plant_identification.dart';
import 'api_service.dart';
import 'history_service.dart';

/// 最近识别服务 - 纯API模式
class RecentIdentificationService {
  /// 获取最近识别列表（从API获取）
  static Future<List<PlantIdentification>> getRecentIdentifications({
    int limit = 10,
  }) async {
    try {
      print('📡 从API获取最近识别...');
      // 从API获取
      final List<PlantIdentification> apiResults = 
          await ApiService.getRecentIdentifications(limit: limit);
      
      print('✅ 从API获取到 ${apiResults.length} 条识别记录');
      // 同步到本地存储用于缓存
      for (final identification in apiResults) {
        await HistoryService.saveIdentification(identification);
      }
      return apiResults;
    } catch (e) {
      print('❌ 从API获取最近识别失败: $e');
      rethrow; // 直接抛出异常，不再使用本地数据作为fallback
    }
  }
  
  /// 执行植物识别（纯API模式）
  static Future<PlantIdentification> identifyPlant({
    required File imageFile,
    double? latitude,
    double? longitude,
    String? locationName,
  }) async {
    try {
      print('🌱 使用API进行植物识别...');
      // 使用API进行识别
      final PlantIdentification result = await ApiService.identifyPlant(
        imageFile: imageFile,
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
      );
      
      print('✅ API识别成功: ${result.commonName}');
      // 保存到本地存储
      await HistoryService.saveIdentification(result);
      return result;
    } catch (e) {
      print('❌ API植物识别失败: $e');
      rethrow; // 直接抛出异常，不再使用本地模拟
    }
  }
}

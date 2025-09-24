import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/plant_identification.dart';

class HistoryService {
  static const String _boxName = 'plant_history';
  static Box<String>? _historyBox;

  /// 初始化 Hive 存储
  static Future<void> initialize() async {
    await Hive.initFlutter();
    _historyBox = await Hive.openBox<String>(_boxName);
  }

  /// 保存识别结果到历史记录
  static Future<void> saveIdentification(PlantIdentification identification) async {
    if (_historyBox == null) {
      await initialize();
    }

    try {
      final String key = 'history_${identification.id}';
      final String jsonString = jsonEncode(identification.toJson());
      await _historyBox!.put(key, jsonString);
    } catch (e) {
      print('保存识别历史失败: $e');
    }
  }

  /// 获取所有识别历史记录
  static Future<List<PlantIdentification>> getAllHistory() async {
    if (_historyBox == null) {
      await initialize();
    }

    try {
      final List<PlantIdentification> historyList = [];
      
      for (String key in _historyBox!.keys) {
        final String? jsonString = _historyBox!.get(key);
        if (jsonString != null) {
          final Map<String, dynamic> json = jsonDecode(jsonString);
          historyList.add(PlantIdentification.fromJson(json));
        }
      }

      // 按识别时间倒序排列
      historyList.sort((a, b) => b.identifiedAt.compareTo(a.identifiedAt));
      return historyList;
    } catch (e) {
      print('获取识别历史失败: $e');
      return [];
    }
  }

  /// 获取最近的识别记录（限制数量）
  static Future<List<PlantIdentification>> getRecentHistory({int limit = 10}) async {
    final List<PlantIdentification> allHistory = await getAllHistory();
    return allHistory.take(limit).toList();
  }

  /// 删除指定的识别记录
  static Future<void> deleteIdentification(String identificationId) async {
    if (_historyBox == null) {
      await initialize();
    }

    try {
      final String key = 'history_$identificationId';
      await _historyBox!.delete(key);
    } catch (e) {
      print('删除识别历史失败: $e');
    }
  }

  /// 清空所有历史记录
  static Future<void> clearAllHistory() async {
    if (_historyBox == null) {
      await initialize();
    }

    try {
      await _historyBox!.clear();
    } catch (e) {
      print('清空识别历史失败: $e');
    }
  }

  /// 获取历史记录总数
  static Future<int> getHistoryCount() async {
    if (_historyBox == null) {
      await initialize();
    }

    return _historyBox!.length;
  }

  /// 检查是否存在指定的识别记录
  static Future<bool> hasIdentification(String identificationId) async {
    if (_historyBox == null) {
      await initialize();
    }

    final String key = 'history_$identificationId';
    return _historyBox!.containsKey(key);
  }

  /// 更新识别记录（比如添加用户备注）
  static Future<void> updateIdentification(PlantIdentification identification) async {
    await saveIdentification(identification); // 直接覆盖保存
  }

  /// 关闭存储
  static Future<void> dispose() async {
    await _historyBox?.close();
    _historyBox = null;
  }
}


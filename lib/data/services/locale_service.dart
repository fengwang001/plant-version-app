import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class LocaleService extends GetxService {
  static LocaleService get instance => Get.find<LocaleService>();
  
  late Box _box;
  final String _localeKey = 'selected_locale';
  
  // 支持的语言列表
  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'), // 中文
    Locale('en', 'US'), // 英文
    Locale('ja', 'JP'), // 日语
    Locale('ko', 'KR'), // 韩语
  ];
  
  // 当前语言
  final Rx<Locale> _currentLocale = const Locale('zh', 'CN').obs;
  Locale get currentLocale => _currentLocale.value;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initStorage();
    await _loadSavedLocale();
  }
  
  /// 初始化存储
  Future<void> _initStorage() async {
    _box = await Hive.openBox('locale_settings');
  }
  
  /// 加载已保存的语言设置
  Future<void> _loadSavedLocale() async {
    try {
      final savedLocaleCode = _box.get(_localeKey);
      if (savedLocaleCode != null) {
        final locale = _getLocaleFromCode(savedLocaleCode);
        if (locale != null) {
          _currentLocale.value = locale;
          Get.updateLocale(locale);
          print('📍 加载已保存的语言: ${locale.languageCode}_${locale.countryCode}');
        }
      } else {
        // 首次使用，根据系统语言设置
        final systemLocale = Get.deviceLocale;
        if (systemLocale != null) {
          final matchedLocale = _findBestMatchLocale(systemLocale);
          _currentLocale.value = matchedLocale;
          Get.updateLocale(matchedLocale);
          await _saveLocale(matchedLocale);
          print('📍 使用系统语言: ${matchedLocale.languageCode}_${matchedLocale.countryCode}');
        }
      }
    } catch (e) {
      print('⚠️ 加载语言设置失败: $e');
    }
  }
  
  /// 更改语言
  Future<void> changeLocale(Locale locale) async {
    try {
      _currentLocale.value = locale;
      Get.updateLocale(locale);
      await _saveLocale(locale);
      print('🌍 语言已更改为: ${locale.languageCode}_${locale.countryCode}');
      
      // 显示成功提示
      Get.snackbar(
        '语言设置',
        '语言已更改为 ${getLanguageName(locale)}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ 更改语言失败: $e');
      Get.snackbar(
        '错误',
        '语言更改失败',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
  
  /// 保存语言设置
  Future<void> _saveLocale(Locale locale) async {
    await _box.put(_localeKey, '${locale.languageCode}_${locale.countryCode}');
  }
  
  /// 从代码获取Locale
  Locale? _getLocaleFromCode(String code) {
    for (final locale in supportedLocales) {
      if ('${locale.languageCode}_${locale.countryCode}' == code) {
        return locale;
      }
    }
    return null;
  }
  
  /// 查找最佳匹配的语言
  Locale _findBestMatchLocale(Locale systemLocale) {
    // 首先尝试完全匹配
    for (final locale in supportedLocales) {
      if (locale.languageCode == systemLocale.languageCode &&
          locale.countryCode == systemLocale.countryCode) {
        return locale;
      }
    }
    
    // 然后尝试语言代码匹配
    for (final locale in supportedLocales) {
      if (locale.languageCode == systemLocale.languageCode) {
        return locale;
      }
    }
    
    // 默认返回中文
    return const Locale('zh', 'CN');
  }
  
  /// 获取语言显示名称
  String getLanguageName(Locale locale) {
    switch ('${locale.languageCode}_${locale.countryCode}') {
      case 'zh_CN':
        return '中文 (Chinese)';
      case 'en_US':
        return 'English';
      case 'ja_JP':
        return '日本語 (Japanese)';
      case 'ko_KR':
        return '한국어 (Korean)';
      default:
        return locale.languageCode;
    }
  }
  
  /// 获取当前语言的标志图标
  String getLanguageFlag(Locale locale) {
    switch ('${locale.languageCode}_${locale.countryCode}') {
      case 'zh_CN':
        return '🇨🇳';
      case 'en_US':
        return '🇺🇸';
      case 'ja_JP':
        return '🇯🇵';
      case 'ko_KR':
        return '🇰🇷';
      default:
        return '🌍';
    }
  }
  
  /// 检查是否是RTL语言
  bool isRTL(Locale locale) {
    // 目前支持的语言都是LTR，如果以后支持阿拉伯语等RTL语言可以在这里添加
    return false;
  }
}

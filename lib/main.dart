import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'fitness_app/fitness_app_home_screen.dart';
import 'data/services/history_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/token_storage_service.dart';
import 'data/services/locale_service.dart';
import 'presentation/controllers/home_controller.dart';
import 'core/config/app_config.dart';
import 'l10n/app_localizations.dart';

import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化应用配置
  await AppConfig.initialize();
  
  // 初始化Hive
  await Hive.initFlutter();
  
  // 初始化服务
  await HistoryService.initialize();
  await TokenStorageService.init();
  
  // 注册服务
  Get.put(AuthService());
  Get.put(LocaleService());
  
  // 预注册控制器，避免重复初始化问题
  Get.lazyPut(() => HomeController());
  
  runApp(const PlantApp());
  SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor:Colors.transparent);
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
}

class PlantApp extends StatelessWidget {
  const PlantApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 SystemChrome 来定制设备顶部的状态栏（显示时间、电量、信号的区域）和底部的导航栏（Android 上的返回、主页、任务切换按钮）的样式。
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 设置状态栏为透明
      statusBarIconBrightness: Brightness.dark, // 设置状态栏图标为深色
      statusBarBrightness: kIsWeb ? Brightness.light : Brightness.dark, // 适配 iOS
      // 设置导航栏为白色，图标为深色
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return GetMaterialApp(
      title: 'PlantVision',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: AppTheme.textTheme,
        platform: TargetPlatform.iOS,
        dividerTheme: DividerThemeData(color: Color(0xFFE0E0E0)),
      ),
      
      // 国际化配置
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleService.supportedLocales,
      locale: Get.find<LocaleService>().currentLocale,
      fallbackLocale: const Locale('zh', 'CN'),
      home: FitnessAppHomeScreen(),
    );
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}


import 'package:flutter_application_1/fitness_app/models/tabIcon_data.dart';
import 'package:flutter_application_1/fitness_app/training/training_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/fitness_app/bottom_navigation_view/bottom_bar_view.dart';
import 'fitness_app_theme.dart';
// import 'package:flutter_application_1/fitness_app/my_diary/my_diary_screen.dart';
import 'package:flutter_application_1/presentation/pages/home_page_new.dart';
import 'package:flutter_application_1/presentation/pages/login_page.dart';
import 'package:flutter_application_1/presentation/pages/profile_page.dart';
import 'package:flutter_application_1/presentation/pages/library_page.dart';
import 'package:flutter_application_1/presentation/pages/discover_page.dart';
import 'package:flutter_application_1/presentation/pages/create_page.dart';
import 'package:flutter_application_1/data/services/auth_service.dart';
import 'package:flutter_application_1/presentation/controllers/home_controller.dart';
import 'package:get/get.dart';

class FitnessAppHomeScreen extends StatefulWidget {
  @override
  _FitnessAppHomeScreenState createState() => _FitnessAppHomeScreenState();
}

/// 全局导航控制器 - 提供给其他页面使用的导航方法
class AppNavigationController extends GetxController {
  
  static AppNavigationController get instance => Get.find<AppNavigationController>();
  
  late _FitnessAppHomeScreenState _homeScreenState;
  
  void setHomeScreenState(_FitnessAppHomeScreenState state) {
    _homeScreenState = state;
  }
  
  /// 导航到个人资料页面
  void navigateToProfile() {
    _homeScreenState._navigateToProfile();
  }
  
  /// 导航到图库页面
  void navigateToLibrary() {
    _homeScreenState._navigateToLibrary();
  }
  
  /// 导航到发现页面
  void navigateToDiscover() {
    _homeScreenState._navigateToDiscover();
  }
  
  /// 导航到创建页面
  void navigateToCreate() {
    _homeScreenState._navigateToCreate();
  }
  
  /// 返回主页
  void navigateToHome() {
    _homeScreenState._navigateToHome();
  }

  /// 跳转到登录页面
  void navigateToLogin() {
    _homeScreenState._showLoginScreen();
  }
}

class _FitnessAppHomeScreenState extends State<FitnessAppHomeScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  bool isAnimating = false; // 添加动画状态标志
  bool isLoggedIn = false; // 登录状态
  bool isInitialized = false; // 初始化状态

  List<TabIconData> tabIconsList = TabIconData.tabIconsList;

  Widget tabBody = Container(
    color: FitnessAppTheme.background,
  );

  @override
  void initState() {
    super.initState();
    
    // 注册全局导航控制器
    Get.put(AppNavigationController());
    Get.find<AppNavigationController>().setHomeScreenState(this);
    
    _initializeApp();
  }

  /// 初始化应用
  Future<void> _initializeApp() async {
    // 显示启动画面
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      final authService = AuthService.instance;
      
      if (authService.isLoggedIn) {
        print('✅ 用户已登录，显示主应用');
        _initializeMainApp();
      } else {
        print('❌ 用户未登录，显示登录页');
        _showLoginScreen();
      }
    } catch (e) {
      print('⚠️ 初始化失败: $e，显示登录页');
      _showLoginScreen();
    }
    
    setState(() {
      isInitialized = true;
    });
  }

  /// 初始化主应用
  void _initializeMainApp() {
    tabIconsList.forEach((TabIconData tab) {
      tab.isSelected = false;
    });
    tabIconsList[0].isSelected = true;

    animationController = AnimationController( duration: const Duration(milliseconds: 600), vsync: this);
    tabBody = HomePageNew(animationController: animationController);
    
    isLoggedIn = true;
  }

  /// 显示登录屏幕
  void _showLoginScreen() {
    setState(() {
      isLoggedIn = false;
      tabBody = LoginPage(onLoginSuccess: _onLoginSuccess);
    });
  }

  /// 登录成功回调
  void _onLoginSuccess() {
    print('🎉 登录成功，切换到主应用');
    setState(() {
      _initializeMainApp();
    });
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 如果还没初始化完成，显示启动屏幕
    if (!isInitialized) {
      return _buildSplashScreen();
    }

    // 如果未登录，直接显示登录页面
    if (!isLoggedIn) {
      return tabBody;
    }

    // 已登录，显示主应用界面
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(
                children: <Widget>[
                  tabBody, // 主内容区域
                  bottomBar(), // 底部导航栏
                ],
              );
            }
          },
        ),
      ),
    );
  }

  /// 构建启动屏幕
  Widget _buildSplashScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2196F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_florist_rounded,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'PlantVision',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '智能植物识别',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> getData() async { // 模拟异步数据获取
    await Future<dynamic>.delayed(const Duration(milliseconds: 200)); //
    return true;
  }

  /// 安全的标签页切换处理
  Future<void> _handleTabChange(int index) async {
    // 防止重复点击导致的竞态条件
    if (isAnimating) {
      return;
    }

    try {
      isAnimating = true;
      
      // 使用 Future.microtask 确保在下一个事件循环中执行
      await Future.microtask(() async {
        if (!mounted) return;
        
        await animationController?.reverse();
        
        if (!mounted) return;
        
        setState(() {
          if (index == 0 || index == 2) {
            tabBody = HomePageNew(animationController: animationController);
          } else if (index == 1) {
            tabBody = TrainingScreen(animationController: animationController);
          } else if (index == 3) {
            tabBody = ProfilePage(animationController: animationController);
          }
        });
      });
    } catch (e) {
      print('标签页切换错误: $e');
    } finally {
      if (mounted) {
        isAnimating = false;
      }
    }
  }

  Widget bottomBar() {
    print('🔽 构建底部导航栏');
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: BottomBarView(
        tabIconsList: tabIconsList,
        addClick: () => onAddClick(),
        changeIndex: (int index) => _handleTabChange(index),
      ),
    );
  }

  void onAddClick() {
    print('➕ 底部导航栏添加按钮点击');
    // 调用摄像头 扫描植物
    final controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());
    controller.startPlantIdentification();
  }

  /// 导航到个人资料页面
  void _navigateToProfile() {
    setState(() {
      tabBody = ProfilePage(onLogout: _onLogout);
    });
  }

  /// 导航到图库页面
  void _navigateToLibrary() {
    setState(() {
      tabBody = const LibraryPage();
    });
  }

  /// 导航到发现页面
  void _navigateToDiscover() {
    setState(() {
      tabBody = const DiscoverPage();
    });
  }

  /// 导航到创建页面
  void _navigateToCreate() {
    setState(() {
      tabBody = const CreatePage();
    });
  }

  /// 返回主页
  void _navigateToHome() {
    setState(() {
      tabBody = HomePageNew(animationController: animationController);
    });
  }

  /// 退出登录回调
  void _onLogout() {
    print('👋 FitnessAppHomeScreen: 收到退出登录回调');
    _showLoginScreen();
    print('✅ FitnessAppHomeScreen: 已切换到登录屏幕');
  }
}

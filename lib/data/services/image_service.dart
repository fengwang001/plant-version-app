import 'dart:io';
import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';

// ==================== ImageService 完整代码 ====================

class ImageService {
  static final ImagePicker _picker = ImagePicker();
  static CameraController? _cameraController;
  static List<CameraDescription>? _cameras;
  static bool _isCameraInitialized = false;

  /// 初始化相机
  static Future<bool> _initializeCamera() async {
    try {
      if (_isCameraInitialized && _cameraController != null) {
        return true;
      }

      // 请求相机权限
      final bool hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        return false;
      }

      // 获取可用相机列表
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('未找到可用相机');
      }

      // 优先使用后置摄像头
      final backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      _isCameraInitialized = true;
      return true;
    } catch (e) {
      print('相机初始化失败: $e');
      return false;
    }
  }
  
   /// 释放相机资源
  static Future<void> _disposeCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
      _isCameraInitialized = false;
    }
  }

  /// 请求相机权限
  static Future<bool> _requestCameraPermission() async {
    final PermissionStatus status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  /// 请求相册权限
  static Future<bool> _requestPhotosPermission() async {
    try {
      // 根据平台请求不同的权限
      if (Platform.isIOS) {
        final PermissionStatus status = await Permission.photos.request();
        return status == PermissionStatus.granted || status == PermissionStatus.limited;
      } else if (Platform.isAndroid) {
        // 获取真实的Android版本
        final androidVersion = await _getAndroidVersion();
        print('📱 Android SDK版本: $androidVersion');
        
        // Android 13+ (SDK 33+) 需要请求photos权限
        if (androidVersion >= 33) {
          final PermissionStatus status = await Permission.photos.request();
          return status == PermissionStatus.granted || status == PermissionStatus.limited;
        } else {
          // Android 12及以下使用storage权限
          final PermissionStatus status = await Permission.storage.request();
          return status == PermissionStatus.granted;
        }
      }
      return false;
    } catch (e) {
      print('❌ 请求权限错误: $e');
      return false;
    }
  }
  
  /// 获取Android版本
  static Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      print('📱 获取到的Android版本: SDK ${androidInfo.version.sdkInt}');
      return androidInfo.version.sdkInt;
    } catch (e) {
      print('❌ 获取Android版本失败: $e');
      return 30;
    }
  }

  /// 从相机拍照
  static Future<File?> pickImageFromCamera() async {
    try {
      final bool hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        Get.snackbar('权限不足', '需要相机权限才能拍照');
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      Get.snackbar('拍照失败', '无法打开相机：$e');
      return null;
    }
  }
  
  /// 从相册选择
  static Future<File?> pickImageFromGallery() async {
    try {
      print('🔍 === pickImageFromGallery 开始 ===');
      
      // 获取Android版本
      final androidVersion = await _getAndroidVersion();
      print('📱 当前设备Android版本: SDK $androidVersion');
      
      // 先检查权限
      bool hasPermission = await _checkPhotosPermission();
      print('✅ 权限检查结果: $hasPermission');
      
      if (!hasPermission) {
        print('⚠️ 没有权限，开始请求...');
        hasPermission = await _requestPhotosPermission();
        print('📝 请求权限结果: $hasPermission');
        
        if (!hasPermission) {
          print('❌ 权限被拒绝');
          Get.snackbar(
            '权限不足', 
            '需要相册权限才能选择照片，请在设置中开启',
            duration: Duration(seconds: 3),
            mainButton: TextButton(
              onPressed: () {
                openAppSettings();
                Get.back();
              },
              child: Text('去设置', style: TextStyle(color: Colors.white)),
            ),
          );
          return null;
        }
      }

      print('🎉 权限已获取，打开相册选择器...');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        print('✅ 选择成功: ${image.path}');
        print('🔍 === pickImageFromGallery 结束 (成功) ===');
        return File(image.path);
      }
      print('❌ 用户取消选择');
      print('🔍 === pickImageFromGallery 结束 (取消) ===');
      return null;
    } catch (e, stackTrace) {
      print('❌ 选择照片错误详情: $e');
      print('❌ 堆栈跟踪: $stackTrace');
      Get.snackbar(
        '选择失败', 
        '无法打开相册: $e',
        duration: Duration(seconds: 3),
      );
      print('🔍 === pickImageFromGallery 结束 (异常) ===');
      return null;
    }
  }
  
  /// 检查相册权限
  static Future<bool> _checkPhotosPermission() async {
    try {
      if (Platform.isIOS) {
        final status = await Permission.photos.status;
        return status == PermissionStatus.granted || status == PermissionStatus.limited;
      } else if (Platform.isAndroid) {
        final androidVersion = await _getAndroidVersion();
        print('📱 检查权限 - Android SDK版本: $androidVersion');
        
        if (androidVersion >= 33) {
          final status = await Permission.photos.status;
          print('📂 Photos权限状态: $status');
          return status == PermissionStatus.granted || status == PermissionStatus.limited;
        } else {
          final status = await Permission.storage.status;
          print('📂 Storage权限状态: $status');
          return status == PermissionStatus.granted;
        }
      }
      return false;
    } catch (e) {
      print('❌ 检查权限错误: $e');
      return false;
    }
  }

  /// 显示图片来源选择对话框
  static Future<File?> showImageSourceDialog() async {
    File? selectedImage;
    
    await Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '选择图片来源',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSourceOption(
                    icon: Icons.camera_alt_rounded,
                    title: '拍照',
                    onTap: () async {
                      Get.back();
                      selectedImage = await pickImageFromCamera();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSourceOption(
                    icon: Icons.photo_library_rounded,
                    title: '相册',
                    onTap: () async {
                      Get.back();
                      selectedImage = await pickImageFromGallery();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
    
    return selectedImage;
  }

  

  /// AR相机扫描界面 (彻底修复异步返回问题)
static Future<File?> showHalfScreenCameraScanDialog(BuildContext context) async {
  final Completer<File?> completer = Completer<File?>();
  bool shouldCompleteThen = true; // 控制 .then() 是否应该完成 completer
  
  print('🎬 === showHalfScreenCameraScanDialog 开始 ===');
  
  Get.bottomSheet(
    _ARCameraScanWidget(
      onImageCaptured: (File? image) {
        print('📸 拍照回调触发，图片: ${image?.path}');
        if (!completer.isCompleted) {
          shouldCompleteThen = false; // 防止 .then() 回调干扰
          completer.complete(image);
          Get.back();
        }
      },
      onGallerySelected: () async {
        print('🖼️ === 相册按钮被点击 ===');
        
        // 标记：不要让 .then() 回调完成 completer
        shouldCompleteThen = false;
        
        // 先关闭相机对话框
        print('🔙 关闭相机对话框');
        Get.back();
        
        // 等待对话框关闭动画完成
        print('⏳ 等待400ms让对话框关闭...');
        await Future.delayed(const Duration(milliseconds: 400));
        
        print('📂 调用 pickImageFromGallery');
        final selectedImage = await pickImageFromGallery();
        
        print('📷 pickImageFromGallery 返回结果: ${selectedImage?.path ?? "null"}');
        
        if (!completer.isCompleted) {
          print('✅ 完成 completer，图片: ${selectedImage?.path ?? "null"}');
          completer.complete(selectedImage);
        } else {
          print('⚠️ completer 已经完成，忽略此结果');
        }
      },
      onClose: () {
        print('❌ 关闭按钮被点击');
        if (!completer.isCompleted) {
          shouldCompleteThen = false; // 防止 .then() 回调干扰
          completer.complete(null);
          Get.back();
        }
      },
    ),
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: false,
  ).then((_) {
    print('🔚 BottomSheet.then 回调触发, shouldCompleteThen=$shouldCompleteThen');
    // 只有在用户没有通过按钮操作时，才在这里完成
    if (shouldCompleteThen && !completer.isCompleted) {
      print('⚠️ 用户通过其他方式关闭了对话框（如点击外部），返回 null');
      completer.complete(null);
    }
  });
  
  print('⏳ 等待 completer.future...');
  final result = await completer.future;
  print('✅ completer.future 完成，结果: ${result?.path ?? "null"}');
  print('🎬 === showHalfScreenCameraScanDialog 结束 ===');
  return result;
}
  static Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



/// AR相机扫描Widget - 完全按照图片UI实现
class _ARCameraScanWidget extends StatefulWidget {
  final Function(File?) onImageCaptured;
  final VoidCallback onGallerySelected;
  final VoidCallback onClose;

  const _ARCameraScanWidget({
    required this.onImageCaptured,
    required this.onGallerySelected,
    required this.onClose,
  });

  @override
  State<_ARCameraScanWidget> createState() => _ARCameraScanWidgetState();
}

class _ARCameraScanWidgetState extends State<_ARCameraScanWidget> {
  bool _isCapturing = false;
  bool _cameraInitialized = false;
  CameraController? _cameraController;
  FlashMode _flashMode = FlashMode.auto;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _disposeCamera();
    super.dispose();
  }

  /// 初始化相机
  Future<void> _initializeCamera() async {
    try {
      // 请求相机权限
      final bool hasPermission = await ImageService._requestCameraPermission();
      if (!hasPermission) {
        return;
      }

      // 获取可用相机列表
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('未找到可用相机');
      }

      // 优先使用后置摄像头
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _cameraInitialized = true;
        });
      }
    } catch (e) {
      print('相机初始化失败: $e');
    }
  }

  /// 释放相机资源
  Future<void> _disposeCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
      _cameraInitialized = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Stack(
        children: [
          // 相机预览背景
          if (_cameraInitialized && _cameraController != null)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            )
          else
            Container(
              color: Colors.grey.shade800,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

        
          // 顶部控制栏
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 闪光灯按钮
                _buildTopControlButton(
                  icon: _getFlashIcon(),
                  onTap: _toggleFlash,
                ),
                
                // 信息按钮
                _buildTopControlButton(
                  icon: Icons.info_outline,
                  onTap: () {},
                ),
                
                // 关闭按钮
                _buildTopControlButton(
                  icon: Icons.close,
                  onTap: widget.onClose,
                ),
              ],
            ),
          ),

          // 扫描框
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
              ),
              child: Stack(
                children: [
                  // 四个角的扫描框架
                  ...List.generate(4, (index) {
                    final positions = [
                      const Alignment(-1, -1), // 左上
                      const Alignment(1, -1),  // 右上
                      const Alignment(-1, 1),  // 左下
                      const Alignment(1, 1),   // 右下
                    ];
                    return Align(
                      alignment: positions[index],
                      child: _buildCornerBracket(index),
                    );
                  }),
                ],
              ),
            ),
          ),

          // 底部物体识别区域 (移动到最底部)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 左下角相册图标 - 点击选择照片
                GestureDetector(
                  onTap: () {
                    print('🖼️ 相册图标被点击！');
                    print('🔍 调用 onGallerySelected 回调');
                    widget.onGallerySelected();
                  },
                  behavior: HitTestBehavior.opaque, // 确保整个区域可点击
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade400,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                
                // 植物标签
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    '植物',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                // 占位符保持右侧平衡
                const SizedBox(width: 50),
              ],
            ),
          ),

          // 物体图标行 (移动到底部上方)
          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            height: 60, // 设置固定高度
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildObjectIcon(
                  icon: Icons.medical_services_outlined,
                  color: Colors.teal.shade400,
                  isSelected: false,
                ),
                SizedBox(width: 16),
                _buildObjectIcon(
                  icon: Icons.eco,
                  color: Colors.orange.shade400,
                  isSelected: true, // 植物图标被选中
                ),
                SizedBox(width: 16),
                _buildObjectIcon(
                  icon: Icons.layers_outlined,
                  color: Colors.grey.shade400,
                  isSelected: false,
                ),
                SizedBox(width: 16),
                _buildObjectIcon(
                  icon: Icons.blur_circular,
                  color: Colors.grey.shade400,
                  isSelected: false,
                ),
                SizedBox(width: 16),
                // 可以添加更多按钮
              ],
            ),
          ),

          // 拍照按钮 (隐藏的触摸区域) - 降低优先级，避免覆盖底部按钮
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 200, // 👈 重要：底部留出空间，不覆盖相册按钮
            child: GestureDetector(
              onTap: () {
                print('📸 相机区域被点击，准备拍照');
                _capturePhoto();
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildTopControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Colors.black38,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildCornerBracket(int cornerIndex) {
    return Container(
      width: 60,
      height: 60,
      child: CustomPaint(
        painter: CornerBracketPainter(cornerIndex),
      ),
    );
  }

  Widget _buildObjectIcon({
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.black45,
        shape: BoxShape.circle,
        border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: Icon(
        icon,
        color: isSelected ? color : Colors.white,
        size: 28,
      ),
    );
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.auto:
      default:
        return Icons.flash_auto;
    }
  }

  Future<void> _toggleFlash() async {
    if (!_cameraInitialized || _cameraController == null) return;

    try {
      FlashMode newMode;
      switch (_flashMode) {
        case FlashMode.off:
          newMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          newMode = FlashMode.always;
          break;
        case FlashMode.always:
        default:
          newMode = FlashMode.off;
          break;
      }

      await _cameraController!.setFlashMode(newMode);
      setState(() {
        _flashMode = newMode;
      });
    } catch (e) {
      print('设置闪光灯失败: $e');
    }
  }

  Future<void> _capturePhoto() async {
    if (!_cameraInitialized || 
        _cameraController == null || 
        _isCapturing) return;

    try {
      setState(() {
        _isCapturing = true;
      });

      final XFile photo = await _cameraController!.takePicture();
      final File imageFile = File(photo.path);
      
      widget.onImageCaptured(imageFile);

    } catch (e) {
      print('拍照失败: $e');
      Get.snackbar('拍照失败', '无法保存照片，请重试');
      widget.onImageCaptured(null);
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }
}

/// 自定义绘制扫描框的四个角
class CornerBracketPainter extends CustomPainter {
  final int cornerIndex;
  
  CornerBracketPainter(this.cornerIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const double bracketLength = 30;
    
    switch (cornerIndex) {
      case 0: // 左上角
        canvas.drawLine(Offset(0, bracketLength), Offset(0, 0), paint);
        canvas.drawLine(Offset(0, 0), Offset(bracketLength, 0), paint);
        break;
      case 1: // 右上角
        canvas.drawLine(Offset(size.width - bracketLength, 0), Offset(size.width, 0), paint);
        canvas.drawLine(Offset(size.width, 0), Offset(size.width, bracketLength), paint);
        break;
      case 2: // 左下角
        canvas.drawLine(Offset(0, size.height - bracketLength), Offset(0, size.height), paint);
        canvas.drawLine(Offset(0, size.height), Offset(bracketLength, size.height), paint);
        break;
      case 3: // 右下角
        canvas.drawLine(Offset(size.width - bracketLength, size.height), Offset(size.width, size.height), paint);
        canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - bracketLength), paint);
        break;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ==================== AI识别功能完整代码 ====================

/// AI识别结果模型
class AIRecognitionResult {
  final String objectName;
  final double confidence;
  final String category;
  final String? description;
  
  AIRecognitionResult({
    required this.objectName,
    required this.confidence,
    required this.category,
    this.description,
  });
}

/// AI识别服务（模拟）
class AIRecognitionService {
  /// 模拟AI识别过程
  static Future<AIRecognitionResult> recognizeImage(File imageFile) async {
    // 模拟网络请求延迟
    await Future.delayed(const Duration(seconds: 2));
    
    // 模拟识别结果
    return AIRecognitionResult(
      objectName: '绿萝',
      confidence: 0.95,
      category: '植物',
      description: '常见的室内观叶植物，具有净化空气的作用',
    );
  }
}

/// 照片添加与AI识别页面
class PhotoRecognitionPage extends StatefulWidget {
  const PhotoRecognitionPage({Key? key}) : super(key: key);

  @override
  State<PhotoRecognitionPage> createState() => _PhotoRecognitionPageState();
}

class _PhotoRecognitionPageState extends State<PhotoRecognitionPage> {
  File? _selectedImage;
  bool _isRecognizing = false;
  AIRecognitionResult? _recognitionResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('智能识别'),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 照片展示区域
              _buildPhotoArea(),
              
              const SizedBox(height: 24),
              
              // 操作按钮
              if (_selectedImage == null) _buildActionButtons(),
              
              // AI识别动画
              if (_isRecognizing) _buildRecognitionAnimation(),
              
              // 识别结果
              if (_recognitionResult != null && !_isRecognizing)
                _buildRecognitionResult(),
            ],
          ),
        ),
      ),
    );
  }

  /// 照片展示区域
  Widget _buildPhotoArea() {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _selectedImage == null
          ? _buildEmptyState()
          : _buildImagePreview(),
    );
  }

  /// 空状态
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 80,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 16),
        Text(
          '添加照片开始识别',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 图片预览
  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            _selectedImage!,
            fit: BoxFit.cover,
          ),
          // 操作按钮浮层
          Positioned(
            top: 16,
            right: 16,
            child: Row(
              children: [
                _buildImageActionButton(
                  icon: Icons.refresh,
                  onTap: _retakePhoto,
                ),
                const SizedBox(width: 12),
                _buildImageActionButton(
                  icon: Icons.close,
                  onTap: _clearPhoto,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  /// 操作按钮
  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildMainButton(
          title: 'AR相机扫描',
          icon: Icons.camera_alt_rounded,
          color: Colors.teal,
          onTap: _openARCamera,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSecondaryButton(
                title: '拍照',
                icon: Icons.camera,
                onTap: _takePhoto,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSecondaryButton(
                title: '相册',
                icon: Icons.photo_library_rounded,
                onTap: _pickFromGallery,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.teal, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// AI识别动画
  Widget _buildRecognitionAnimation() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 旋转的AI图标
          _AIRecognitionAnimation(),
          
          const SizedBox(height: 24),
          
          const Text(
            'AI正在识别中...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '分析图像特征',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 进度条动画
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 2),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
            minHeight: 8,
          );
        },
      ),
    );
  }

  /// 识别结果展示
  Widget _buildRecognitionResult() {
    final result = _recognitionResult!;
    
    return Column(
      children: [
        // 成功动画
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // 结果卡片
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      result.category,
                      style: TextStyle(
                        color: Colors.teal[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.verified, color: Colors.green, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${(result.confidence * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Text(
                result.objectName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              if (result.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  result.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _retakePhoto,
                      icon: const Icon(Icons.refresh),
                      label: const Text('重新识别'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // 保存或分享结果
                        Get.snackbar('成功', '识别结果已保存');
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('确认'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 操作方法
  Future<void> _openARCamera() async {
    final File? image = await ImageService.showHalfScreenCameraScanDialog(context);
    if (image != null) {
      _handleImageSelected(image);
    }
  }

  Future<void> _takePhoto() async {
    final File? image = await ImageService.pickImageFromCamera();
    if (image != null) {
      _handleImageSelected(image);
    }
  }

  Future<void> _pickFromGallery() async {
    final File? image = await ImageService.pickImageFromGallery();
    if (image != null) {
      _handleImageSelected(image);
    }
  }

  void _handleImageSelected(File image) {
    setState(() {
      _selectedImage = image;
      _recognitionResult = null;
    });
    
    // 自动开始识别
    _startRecognition();
  }

  Future<void> _startRecognition() async {
    if (_selectedImage == null) return;
    
    setState(() {
      _isRecognizing = true;
    });

    try {
      final result = await AIRecognitionService.recognizeImage(_selectedImage!);
      
      setState(() {
        _isRecognizing = false;
        _recognitionResult = result;
      });
    } catch (e) {
      setState(() {
        _isRecognizing = false;
      });
      Get.snackbar('识别失败', '请重试');
    }
  }

  void _retakePhoto() {
    setState(() {
      _selectedImage = null;
      _recognitionResult = null;
      _isRecognizing = false;
    });
  }

  void _clearPhoto() {
    setState(() {
      _selectedImage = null;
      _recognitionResult = null;
    });
  }
}

/// AI识别动画Widget
class _AIRecognitionAnimation extends StatefulWidget {
  @override
  State<_AIRecognitionAnimation> createState() => _AIRecognitionAnimationState();
}

class _AIRecognitionAnimationState extends State<_AIRecognitionAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 外圈旋转光环
          RotationTransition(
            turns: _controller,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.teal.withOpacity(0.3),
                  width: 3,
                ),
              ),
              child: CustomPaint(
                painter: _CircleArcPainter(),
              ),
            ),
          ),
          
          // 中圈脉冲效果
          ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Curves.easeInOut,
              ),
            ),
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.teal.withOpacity(0.1),
              ),
            ),
          ),
          
          // 中心AI图标
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.teal,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

/// 圆弧绘制器
class _CircleArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // 绘制多个圆弧
    canvas.drawArc(rect, 0, 1.5, false, paint);
    canvas.drawArc(rect, 3.14, 1.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==================== 使用示例 ====================

/// 主应用入口示例
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AI识别应用',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const HomePage(),
    );
  }
}

/// 主页示例
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI植物识别'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.eco,
                size: 100,
                color: Colors.teal,
              ),
              const SizedBox(height: 20),
              const Text(
                '智能植物识别',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '拍照或上传图片，AI帮你识别植物',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Get.to(() => const PhotoRecognitionPage());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  '开始识别',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';

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
    final PermissionStatus status = await Permission.photos.request();
    return status == PermissionStatus.granted;
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
      final bool hasPermission = await _requestPhotosPermission();
      if (!hasPermission) {
        Get.snackbar('权限不足', '需要相册权限才能选择照片');
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      Get.snackbar('选择失败', '无法打开相册：$e');
      return null;
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

  /// AR相机扫描界面 (完全按照图片UI实现)
  static Future<File?> showHalfScreenCameraScanDialog(BuildContext context) async {
    File? selectedImage;
    
    await Get.bottomSheet(
      _ARCameraScanWidget(
        onImageCaptured: (File? image) {
          selectedImage = image;
          Get.back();
        },
        onGallerySelected: () async {
          Get.back();
          selectedImage = await pickImageFromGallery();
        },
        onClose: () {
          Get.back();
        },
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: false,
    );
    
    return selectedImage;
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
                // 左下角植物图标
                GestureDetector(
                  onTap: widget.onGallerySelected,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_florist,
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

          // 拍照按钮 (隐藏的触摸区域)
          Positioned.fill(
            child: GestureDetector(
              onTap: _capturePhoto,
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
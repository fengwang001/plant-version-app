// lib/presentation/pages/create_post_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/image_service.dart';

/// 创建帖子控制器
class CreatePostController extends GetxController {
  final RxList<File> selectedImages = <File>[].obs;
  final RxString title = ''.obs;
  final RxString content = ''.obs;
  final RxList<String> tags = <String>[].obs;
  final RxString selectedPlant = ''.obs;
  final RxInt privacyMode = 0.obs; // 0=Public, 1=Followers, 2=Private
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController tagController = TextEditingController();
  final TextEditingController plantController = TextEditingController();
  
  final ImagePicker _picker = ImagePicker();

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    tagController.dispose();
    plantController.dispose();
    super.onClose();
  }

  /// 选择图片
  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      
      if (images.isNotEmpty) {
        // 最多选择9张图片
        final remainingSlots = 9 - selectedImages.length;
        final imagesToAdd = images.take(remainingSlots);
        
        for (final image in imagesToAdd) {
          selectedImages.add(File(image.path));
        }
        
        if (images.length > remainingSlots) {
          Get.snackbar(
            '提示',
            '最多只能选择9张图片',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange.withOpacity(0.8),
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '选择图片失败: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  /// 拍照
  Future<void> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      
      if (photo != null) {
        if (selectedImages.length < 9) {
          selectedImages.add(File(photo.path));
        } else {
          Get.snackbar(
            '提示',
            '最多只能选择9张图片',
            snackPosition: SnackPosition.TOP,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '拍照失败: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  /// 移除图片
  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  /// 添加标签
  void addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !tags.contains(trimmedTag)) {
      // 添加#前缀如果没有的话
      final formattedTag = trimmedTag.startsWith('#') ? trimmedTag : '#$trimmedTag';
      tags.add(formattedTag);
      tagController.clear();
    }
  }

  /// 移除标签
  void removeTag(String tag) {
    tags.remove(tag);
  }

  /// 选择隐私模式
  void selectPrivacy(int mode) {
    privacyMode.value = mode;
  }

  /// 发布帖子
  Future<void> publishPost() async {
    // 验证
    if (selectedImages.isEmpty) {
      Get.snackbar(
        '提示',
        '请至少添加一张图片',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    try {
      // 显示加载
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        ),
        barrierDismissible: false,
      );

      // 模拟上传延迟
      await Future.delayed(const Duration(seconds: 2));

      // TODO: 实际的API调用
      // await uploadPost(...)

      Get.back(); // 关闭加载对话框
      Get.back(); // 返回上一页
      
      Get.snackbar(
        '发布成功',
        '你的帖子已成功发布',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.primaryGreen.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      Get.back(); // 关闭加载对话框
      Get.snackbar(
        '发布失败',
        '发布帖子时出错: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  /// 是否可以发布
  bool get canPublish => selectedImages.isNotEmpty;
}

/// 创建帖子页面
class CreatePostPage extends StatelessWidget {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreatePostController());

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F7),
        elevation: 0,
        leading: TextButton(
          onPressed: () => Get.back(),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF122017),
              fontSize: 16,
            ),
          ),
        ),
        title: const Text(
          'New Post',
          style: TextStyle(
            color: Color(0xFF122017),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() => TextButton(
            onPressed: controller.canPublish ? controller.publishPost : null,
            child: Text(
              'Post',
              style: TextStyle(
                color: controller.canPublish 
                    ? AppTheme.primaryGreen 
                    : Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片网格
            _buildImageGrid(controller),
            const SizedBox(height: 24),

            // 标题输入
            _buildTextField(
              controller: controller.titleController,
              hint: 'Add a title (optional)',
              maxLines: 1,
            ),
            const SizedBox(height: 16),

            // 内容输入
            _buildTextField(
              controller: controller.contentController,
              hint: 'Describe your work or share a plant story...',
              maxLines: 5,
            ),
            const SizedBox(height: 24),

            // 标签输入
            _buildTagSection(controller),
            const SizedBox(height: 24),

            // 关联植物
            _buildPlantSection(controller),
            const SizedBox(height: 24),

            // 隐私设置
            _buildPrivacySection(controller),
            const SizedBox(height: 100), // 底部留白
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(CreatePostController controller) {
    return Obx(() {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: controller.selectedImages.length + 
            (controller.selectedImages.length < 9 ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < controller.selectedImages.length) {
            // 显示已选择的图片
            return _buildImageItem(controller, index);
          } else {
            // 显示添加按钮
            return _buildAddButton(controller);
          }
        },
      );
    });
  }

  Widget _buildImageItem(CreatePostController controller, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (value * 0.2),
            child: child,
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: FileImage(controller.selectedImages[index]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => controller.removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(CreatePostController controller) {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(controller),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 32,
              color: AppTheme.primaryGreen.withOpacity(0.5),
            ),
            const SizedBox(height: 4),
            Text(
              'Add more',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog(CreatePostController controller) {
    Get.bottomSheet(
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
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSourceOption(
                    icon: Icons.camera_alt,
                    label: '拍照',
                    onTap: () {
                      Get.back();
                      controller.takePhoto();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSourceOption(
                    icon: Icons.photo_library,
                    label: '相册',
                    onTap: () {
                      Get.back();
                      controller.pickImages();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
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
            Icon(icon, size: 32, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              label,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: AppTheme.primaryGreen.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildTagSection(CreatePostController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller.tagController,
          decoration: InputDecoration(
            hintText: 'Add tags',
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: AppTheme.primaryGreen.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
            suffixIcon: IconButton(
              icon: Icon(Icons.add_circle, color: Colors.grey[500]),
              onPressed: () {
                controller.addTag(controller.tagController.text);
              },
            ),
          ),
          onSubmitted: (value) => controller.addTag(value),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.tags.isEmpty) return const SizedBox.shrink();
          
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => controller.removeTag(tag),
                      child: const Icon(
                        Icons.cancel,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildPlantSection(CreatePostController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Associate Plant (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.plantController,
          decoration: InputDecoration(
            hintText: 'Search for a plant',
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: AppTheme.primaryGreen.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
            suffixIcon: Icon(Icons.search, color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySection(CreatePostController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Privacy (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildPrivacyButton(
                  icon: Icons.public,
                  label: 'Public',
                  isSelected: controller.privacyMode.value == 0,
                  onTap: () => controller.selectPrivacy(0),
                ),
              ),
              Expanded(
                child: _buildPrivacyButton(
                  icon: Icons.group,
                  label: 'Followers',
                  isSelected: controller.privacyMode.value == 1,
                  onTap: () => controller.selectPrivacy(1),
                ),
              ),
              Expanded(
                child: _buildPrivacyButton(
                  icon: Icons.lock,
                  label: 'Private',
                  isSelected: controller.privacyMode.value == 2,
                  onTap: () => controller.selectPrivacy(2),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildPrivacyButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppTheme.primaryGreen : Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xFF122017) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
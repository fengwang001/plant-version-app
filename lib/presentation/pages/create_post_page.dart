// lib/presentation/pages/create_post_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';

/// 媒体项模型
class MediaItem {
  final String id;
  final String path;
  final bool isVideo;
  final String? thumbnailPath;

  MediaItem({
    required this.id,
    required this.path,
    this.isVideo = false,
    this.thumbnailPath,
  });
}

/// 创建帖子控制器
class CreatePostController extends GetxController {
  final RxList<File> selectedImages = <File>[].obs;
  final RxList<MediaItem> availableMedia = <MediaItem>[].obs;
  final RxList<String> selectedMediaIds = <String>[].obs;
  final RxString title = ''.obs;
  final RxString content = ''.obs;
  final RxList<String> tags = <String>[].obs;
  final RxString selectedPlant = ''.obs;
  final RxInt privacyMode = 0.obs;
  final RxInt currentTab = 0.obs;
  final RxBool isLoadingMedia = true.obs;
  final RxBool isPublishing = false.obs;
  
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController tagController = TextEditingController();
  final TextEditingController plantController = TextEditingController();
  
  final ImagePicker _picker = ImagePicker();

  // 常用标签
  final List<String> popularTags = [
    '#PlantCare',
    '#GardeningTips',
    '#IndoorPlants',
    '#Succulents',
    '#GreenThumb',
    '#PlantParent',
    '#UrbanJungle',
    '#Monstera',
  ];

  @override
  void onInit() {
    super.onInit();
    tags.addAll(['#PlantCare', '#GardeningTips']);
    _loadAvailableMedia();
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    tagController.dispose();
    plantController.dispose();
    super.onClose();
  }

  Future<void> _loadAvailableMedia() async {
    isLoadingMedia.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    
    availableMedia.value = [
      MediaItem(
        id: 'img1',
        path: 'https://images.unsplash.com/photo-1466781783364-36c955e42a7f?w=400',
      ),
      MediaItem(
        id: 'img2',
        path: 'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=400',
      ),
      MediaItem(
        id: 'img3',
        path: 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?w=400',
      ),
      MediaItem(
        id: 'img4',
        path: 'https://images.unsplash.com/photo-1509937528035-ad76254b0356?w=400',
      ),
      MediaItem(
        id: 'img5',
        path: 'https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?w=400',
      ),
      MediaItem(
        id: 'video1',
        path: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400',
        isVideo: true,
      ),
    ];
    
    isLoadingMedia.value = false;
  }

  void switchTab(int index) {
    currentTab.value = index;
  }

  void toggleMediaSelection(String mediaId) {
    if (selectedMediaIds.contains(mediaId)) {
      selectedMediaIds.remove(mediaId);
    } else {
      if (selectedMediaIds.length < 9) {
        selectedMediaIds.add(mediaId);
      } else {
        Get.snackbar(
          '提示',
          '最多只能选择9个媒体项',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
      }
    }
  }

  void confirmMediaSelection() {
    if (selectedMediaIds.isEmpty) return;
    
    // 将选中的媒体添加到图片列表（这里简化处理）
    Get.back();
    Get.snackbar(
      '已添加',
      '已添加 ${selectedMediaIds.length} 个媒体项',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppTheme.primaryGreen.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      
      if (images.isNotEmpty) {
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

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  void addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isEmpty) return;
    
    final formattedTag = trimmedTag.startsWith('#') ? trimmedTag : '#$trimmedTag';
    
    if (!tags.contains(formattedTag)) {
      if (tags.length >= 10) {
        Get.snackbar(
          '提示',
          '最多只能添加10个标签',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
        return;
      }
      tags.add(formattedTag);
      tagController.clear();
    }
  }

  void removeTag(String tag) {
    tags.remove(tag);
  }

  void selectPrivacy(int mode) {
    privacyMode.value = mode;
  }

  Future<void> publishPost() async {
    if (selectedImages.isEmpty) {
      Get.snackbar(
        '提示',
        '请至少添加一张图片',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      );
      return;
    }

    try {
      isPublishing.value = true;

      // 模拟上传过程
      await Future.delayed(const Duration(seconds: 2));

      isPublishing.value = false;
      Get.back();
      
      Get.snackbar(
        '发布成功',
        '你的帖子已成功发布',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.primaryGreen.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      isPublishing.value = false;
      Get.snackbar(
        '发布失败',
        '发布帖子时出错: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    }
  }

  bool get canPublish => selectedImages.isNotEmpty && !isPublishing.value;
}

/// 创建帖子页面
class CreatePostPage extends StatelessWidget {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreatePostController());

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(controller),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageGrid(controller),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: controller.titleController,
                      hint: 'Add a title (optional)',
                      maxLines: 1,
                      icon: Icons.title,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: controller.contentController,
                      hint: 'Describe your work or share a plant story...',
                      maxLines: 5,
                      icon: Icons.notes,
                    ),
                    const SizedBox(height: 24),
                    _buildTagSection(controller),
                    const SizedBox(height: 24),
                    _buildPlantSection(controller),
                    const SizedBox(height: 24),
                    _buildPrivacySection(controller),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildBottomButton(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(CreatePostController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, size: 20),
            label: const Text('Cancel'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF122017),
            ),
          ),
          const Text(
            'New Post',
            style: TextStyle(
              color: Color(0xFF122017),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Obx(() => TextButton(
            onPressed: controller.canPublish ? controller.publishPost : null,
            child: controller.isPublishing.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppTheme.primaryGreen),
                    ),
                  )
                : Text(
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
            return _buildImageItem(controller, index);
          } else {
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
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.7 + (value * 0.3),
            child: child,
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              image: DecorationImage(
                image: FileImage(controller.selectedImages[index]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => controller.removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          if (index == 0)
            Positioned(
              bottom: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Cover',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
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
      onTap: () => _showMediaSelectionModal(controller),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: AppTheme.primaryGreen.withOpacity(0.6),
            ),
            const SizedBox(height: 4),
            Text(
              'Add Photo',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMediaSelectionModal(CreatePostController controller) {
    Get.dialog(
      MediaSelectionModal(controller: controller),
      barrierColor: Colors.black.withOpacity(0.6),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
    required IconData icon,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: AppTheme.primaryGreen.withOpacity(0.6)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppTheme.primaryGreen,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildTagSection(CreatePostController controller) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_offer, size: 18, color: AppTheme.primaryGreen),
              SizedBox(width: 8),
              Text(
                'Tags',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF122017),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.tagController,
            decoration: InputDecoration(
              hintText: 'Add tags (e.g., PlantCare)',
              hintStyle: TextStyle(color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.primaryGreen,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: AppTheme.primaryGreen,
                ),
                onPressed: () {
                  controller.addTag(controller.tagController.text);
                },
              ),
            ),
            onSubmitted: (value) => controller.addTag(value),
          ),
          const SizedBox(height: 12),
          
          // 常用标签建议
          Obx(() {
            if (controller.tags.length >= 10) return const SizedBox.shrink();
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Popular Tags',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.popularTags
                      .where((tag) => !controller.tags.contains(tag))
                      .take(5)
                      .map((tag) => GestureDetector(
                            onTap: () => controller.addTag(tag),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.add,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],
            );
          }),
          
          // 已添加的标签
          Obx(() {
            if (controller.tags.isEmpty) return const SizedBox.shrink();
            
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.tags.asMap().entries.map((entry) {
                final index = entry.key;
                final tag = entry.value;
                return TweenAnimationBuilder<double>(
                  key: ValueKey(tag),
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 200 + (index * 50)),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.7 + (value * 0.3),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryGreen.withOpacity(0.8),
                          AppTheme.primaryGreen,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => controller.removeTag(tag),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlantSection(CreatePostController controller) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.yard, size: 18, color: AppTheme.primaryGreen),
              SizedBox(width: 8),
              Text(
                'Associate Plant (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF122017),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.plantController,
            decoration: InputDecoration(
              hintText: 'Search for a plant species',
              hintStyle: TextStyle(color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.primaryGreen,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: Icon(Icons.search, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(CreatePostController controller) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.privacy_tip, size: 18, color: AppTheme.primaryGreen),
              SizedBox(width: 8),
              Text(
                'Privacy',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF122017),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
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
      ),
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
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
                color: isSelected ? AppTheme.primaryGreen : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(CreatePostController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Obx(() => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: controller.canPublish
              ? const LinearGradient(
                  colors: [AppTheme.primaryGreen, Color(0xFF00D2A4)],
                )
              : null,
          color: controller.canPublish ? null : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
          boxShadow: controller.canPublish
              ? [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                    offset: const Offset(0, 8),
                    blurRadius: 20,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: controller.canPublish ? controller.publishPost : null,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: controller.isPublishing.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Publish Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      )),
    );
  }
}

/// 媒体选择模态框
class MediaSelectionModal extends StatelessWidget {
  final CreatePostController controller;

  const MediaSelectionModal({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.9 + (value * 0.1),
            child: child,
          ),
        );
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          constraints: const BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8F7),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildModalHeader(context),
              _buildTabBar(),
              Expanded(child: _buildTabContent()),
              _buildModalFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              controller.selectedMediaIds.clear();
              Get.back();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF122017),
                fontSize: 16,
              ),
            ),
          ),
          const Text(
            'Select Media',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF122017),
            ),
          ),
          Obx(() => TextButton(
            onPressed: controller.selectedMediaIds.isNotEmpty
                ? controller.confirmMediaSelection
                : null,
            child: Text(
              'Done',
              style: TextStyle(
                color: controller.selectedMediaIds.isNotEmpty
                    ? AppTheme.primaryGreen
                    : Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Obx(() {
      final currentTab = controller.currentTab.value;
      
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            _buildTab('Phone Gallery', 0, currentTab),
            _buildTab('Identified', 1, currentTab),
            _buildTab('AI Videos', 2, currentTab),
          ],
        ),
      );
    });
  }

  Widget _buildTab(String label, int index, int currentTab) {
    final isSelected = currentTab == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.switchTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppTheme.primaryGreen : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Obx(() {
      final currentTab = controller.currentTab.value;
      
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: currentTab == 0
            ? _buildPhoneGallery()
            : currentTab == 1
                ? _buildEmptyState('No identified plants yet.', Icons.search_off)
                : _buildEmptyState('No AI videos found.', Icons.video_library_outlined),
      );
    });
  }

  Widget _buildPhoneGallery() {
    return Obx(() {
      if (controller.isLoadingMedia.value) {
        return _buildLoadingSkeleton();
      }

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: controller.availableMedia.length,
        itemBuilder: (context, index) {
          final media = controller.availableMedia[index];
          return _buildMediaItem(media, index);
        },
      );
    });
  }

  Widget _buildLoadingSkeleton() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: 0.3 + (value * 0.7),
              child: Transform.scale(
                scale: 0.9 + (value * 0.1),
                child: child,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMediaItem(MediaItem media, int index) {
    return Obx(() {
      final isSelected = controller.selectedMediaIds.contains(media.id);
      
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
        child: GestureDetector(
          onTap: () => controller.toggleMediaSelection(media.id),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    media.path,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
              if (isSelected)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              if (media.isVideo)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              if (isSelected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalFooter() {
    return Obx(() {
      final hasSelection = controller.selectedMediaIds.isNotEmpty;
      
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        height: hasSelection ? 80 : 0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: hasSelection
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${controller.selectedMediaIds.length} selected',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: controller.confirmMediaSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Add to Post',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      );
    });
  }
}
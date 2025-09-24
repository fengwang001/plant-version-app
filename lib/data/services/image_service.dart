import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

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
      // 请求相机权限
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
      // 请求相册权限
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

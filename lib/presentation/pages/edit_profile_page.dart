import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';

class EditProfileController extends GetxController {
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  
  final RxString selectedGender = ''.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString currentAvatarUrl = ''.obs;
  final RxBool hasChanges = false.obs;
  final RxBool isSaving = false.obs;
  
  final ImagePicker _picker = ImagePicker();
  
  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _setupChangeListeners();
  }
  
  void _loadUserData() {
    // TODO: 从用户服务加载数据
    nicknameController.text = 'Sophia Green';
    bioController.text = 'Plant lover & nature enthusiast 🌿';
    locationController.text = 'San Francisco, CA';
    selectedGender.value = 'female';
    currentAvatarUrl.value = 'https://lh3.googleusercontent.com/aida-public/AB6AXuB75u1MVL51kAfMvqspxCcCIGf0HEXF02EEg6FUIeMCyDw3tqWFAN81jIrLDtoV7Up0jkVg1vingJAuH8oE2YuowERO-NEOc5_tjSL_v4XTVfmAHJHXo-aTiGuQh0DwXeJ8lx_QaLZNTLD6oF5foF3G8B8wsqphcUYz9Uh4uaaMoguOFtrwQ3LBg4wRCd_FiRfLugPXHZMCqXDKSZGKyp4LihMScBtFJnsuVWbwnuJf4uSRxQ_NdfNcSFcKNeCSf6Os-cbVYofFupU0';
  }
  
  void _setupChangeListeners() {
    nicknameController.addListener(_checkForChanges);
    bioController.addListener(_checkForChanges);
    locationController.addListener(_checkForChanges);
    ever(selectedGender, (_) => _checkForChanges());
    ever(selectedImage, (_) => _checkForChanges());
  }
  
  void _checkForChanges() {
    hasChanges.value = true;
  }
  
  Future<void> changeProfilePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }
  
  Future<void> saveProfile() async {
    if (isSaving.value || !hasChanges.value) return;
    
    try {
      isSaving.value = true;
      
      // TODO: 实现保存逻辑
      await Future.delayed(const Duration(seconds: 2));
      
      Get.back(result: true);
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: const Color(0xFF20DF6C),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save profile: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isSaving.value = false;
    }
  }
  
  void cancel() {
    if (hasChanges.value) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Discard Changes?'),
          content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Keep Editing'),
            ),
            TextButton(
              onPressed: () {
                Get.back(); // Close dialog
                Get.back(); // Close edit page
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
    } else {
      Get.back();
    }
  }
  
  @override
  void onClose() {
    nicknameController.dispose();
    bioController.dispose();
    locationController.dispose();
    super.onClose();
  }
}

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileController());
    
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(controller),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildProfilePhoto(controller),
                    const SizedBox(height: 32),
                    _buildForm(controller),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildSaveButton(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(EditProfileController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F7).withOpacity(0.8),
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFFE8F3EC),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: controller.cancel,
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF0E1B13),
              ),
            ),
          ),
          const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0E1B13),
            ),
          ),
          Obx(() => TextButton(
            onPressed: controller.hasChanges.value 
                ? controller.saveProfile 
                : null,
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: controller.hasChanges.value 
                    ? const Color(0xFF20DF6C) 
                    : const Color(0xFF20DF6C).withOpacity(0.5),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildProfilePhoto(EditProfileController controller) {
    return Column(
      children: [
        Stack(
          children: [
            Obx(() => Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: controller.selectedImage.value != null
                    ? Image.file(
                        controller.selectedImage.value!,
                        fit: BoxFit.cover,
                      )
                    : controller.currentAvatarUrl.value.isNotEmpty
                        ? Image.network(
                            controller.currentAvatarUrl.value,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFFE8F3EC),
                                child: const Icon(
                                  Icons.person,
                                  size: 48,
                                  color: Color(0xFF20DF6C),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: const Color(0xFFE8F3EC),
                            child: const Icon(
                              Icons.person,
                              size: 48,
                              color: Color(0xFF20DF6C),
                            ),
                          ),
              ),
            )),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: controller.changeProfilePhoto,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF20DF6C),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: controller.changeProfilePhoto,
          child: const Text(
            'Change Profile Photo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF20DF6C),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(EditProfileController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'Nickname',
            controller: controller.nicknameController,
            placeholder: 'Enter your nickname',
          ),
          const SizedBox(height: 24),
          _buildTextField(
            label: 'Bio',
            controller: controller.bioController,
            placeholder: 'Tell us about yourself',
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          _buildGenderSelector(controller),
          const SizedBox(height: 24),
          _buildTextField(
            label: 'Region/Country',
            controller: controller.locationController,
            placeholder: 'Enter your location',
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0E1B13),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF0E1B13),
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(
              fontSize: 16,
              color: Color(0xFF50956C),
            ),
            filled: true,
            fillColor: const Color(0xFFE8F3EC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF20DF6C),
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector(EditProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0E1B13),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => GestureDetector(
          onTap: () => _showGenderModal(Get.context!, controller),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F3EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _getGenderDisplayText(controller.selectedGender.value),
                    style: TextStyle(
                      fontSize: 16,
                      color: controller.selectedGender.value.isEmpty
                          ? const Color(0xFF50956C)
                          : const Color(0xFF0E1B13),
                    ),
                  ),
                ),
                const Icon(
                  Icons.expand_more_rounded,
                  color: Color(0xFF0E1B13),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  String _getGenderDisplayText(String gender) {
    switch (gender) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'other':
        return 'Other';
      case 'prefer_not_to_say':
        return 'Prefer not to say';
      default:
        return 'Select your gender';
    }
  }

  void _showGenderModal(BuildContext context, EditProfileController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Gender',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              _buildGenderOption(
                context,
                controller,
                'male',
                'Male',
              ),
              _buildGenderOption(
                context,
                controller,
                'female',
                'Female',
              ),
              _buildGenderOption(
                context,
                controller,
                'other',
                'Other',
              ),
              _buildGenderOption(
                context,
                controller,
                'prefer_not_to_say',
                'Prefer not to say',
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(
    BuildContext context,
    EditProfileController controller,
    String value,
    String label,
  ) {
    return Obx(() {
      final isSelected = controller.selectedGender.value == value;
      
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            controller.selectedGender.value = value;
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected 
                          ? const Color(0xFF20DF6C) 
                          : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF20DF6C),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSaveButton(EditProfileController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F7).withOpacity(0.8),
      ),
      child: Obx(() => SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: controller.hasChanges.value && !controller.isSaving.value
              ? controller.saveProfile
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF20DF6C),
            foregroundColor: Colors.black,
            elevation: 0,
            disabledBackgroundColor: const Color(0xFF20DF6C).withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: controller.isSaving.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
              : const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      )),
    );
  }
}
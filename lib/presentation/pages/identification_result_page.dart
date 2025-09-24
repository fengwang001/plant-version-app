import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/plant_identification.dart';
import '../../data/services/history_service.dart';

class IdentificationResultController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rx<IdentificationResult?> result = Rx<IdentificationResult?>(null);
  final RxInt selectedIndex = 0.obs;

  void selectSuggestion(int index) {
    selectedIndex.value = index;
  }

  void retryIdentification() {
    Get.back();
  }

  void goBack() {
    Get.back(result: true); // 返回 true 表示可能有数据更新
  }

  Future<void> saveToHistory() async {
    final IdentificationResult? currentResult = result.value;
    if (currentResult == null || currentResult.suggestions.isEmpty) {
      Get.snackbar('保存失败', '没有可保存的识别结果');
      return;
    }

    try {
      // 保存当前选中的识别结果
      final PlantIdentification selectedPlant = currentResult.suggestions[selectedIndex.value];
      await HistoryService.saveIdentification(selectedPlant);
      Get.snackbar('已保存', '识别结果已保存到历史记录');
    } catch (e) {
      Get.snackbar('保存失败', '保存识别结果时出错：$e');
    }
  }

  void shareResult() {
    // TODO: 实现分享功能
    Get.snackbar('分享', '分享功能开发中');
  }
}

class IdentificationResultPage extends StatelessWidget {
  final File imageFile;
  final IdentificationResult result;

  const IdentificationResultPage({
    super.key,
    required this.imageFile,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final IdentificationResultController controller = Get.put(IdentificationResultController());
    controller.result.value = result;

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 自定义顶部栏
            _buildAppBar(context),
            
            // 内容区域
            Expanded(
              child: result.isSuccess && result.suggestions.isNotEmpty
                  ? _buildSuccessContent(controller)
                  : _buildErrorContent(controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              final IdentificationResultController controller = Get.find();
              controller.goBack();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '识别结果',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              final IdentificationResultController controller = Get.find();
              controller.shareResult();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.share_rounded,
                size: 20,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(IdentificationResultController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片展示
          _buildImageSection(),
          const SizedBox(height: 24),
          
          // 识别结果选项卡
          _buildSuggestionTabs(controller),
          const SizedBox(height: 20),
          
          // 植物详细信息
          Obx(() => _buildPlantDetails(result.suggestions[controller.selectedIndex.value])),
          const SizedBox(height: 24),
          
          // 操作按钮
          _buildActionButtons(controller),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          imageFile,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSuggestionTabs(IdentificationResultController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '识别结果 (${result.suggestions.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: result.suggestions.length,
            itemBuilder: (context, index) {
              final PlantIdentification suggestion = result.suggestions[index];
              return Obx(() => _buildSuggestionCard(
                suggestion,
                index,
                controller.selectedIndex.value == index,
                () => controller.selectSuggestion(index),
              ));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(
    PlantIdentification suggestion,
    int index,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: EdgeInsets.only(right: index == result.suggestions.length - 1 ? 0 : 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen.withOpacity(0.1) : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_florist_rounded,
              size: 32,
              color: isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              suggestion.commonName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppTheme.primaryGreen : AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${(suggestion.confidence * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantDetails(PlantIdentification plant) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 植物名称和置信度
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.commonName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plant.scientificName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(plant.confidence * 100).toInt()}% 匹配',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 植物描述
          if (plant.description != null) ...[
            const Text(
              '植物介绍',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              plant.description!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // 植物特征
          if (plant.characteristics.isNotEmpty) ...[
            const Text(
              '主要特征',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: plant.characteristics.map((characteristic) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    characteristic,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          
          // 养护信息
          if (plant.careInfo != null) ...[
            const Text(
              '养护指南',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildCareInfoItem('光照', plant.careInfo!.sunlight, Icons.wb_sunny_rounded),
            _buildCareInfoItem('浇水', plant.careInfo!.watering, Icons.water_drop_rounded),
            _buildCareInfoItem('土壤', plant.careInfo!.soil, Icons.grass_rounded),
            _buildCareInfoItem('温度', plant.careInfo!.temperature, Icons.thermostat_rounded),
          ],
        ],
      ),
    );
  }

  Widget _buildCareInfoItem(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            '$title：',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(IdentificationResultController controller) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.retryIdentification,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重新识别'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.saveToHistory,
            icon: const Icon(Icons.bookmark_rounded),
            label: const Text('保存'),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent(IdentificationResultController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              result.errorMessage ?? '识别失败',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.retryIdentification,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('重新尝试'),
            ),
          ],
        ),
      ),
    );
  }
}

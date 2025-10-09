import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/plant_identification.dart';
import '../../l10n/app_localizations.dart';
import '../controllers/home_controller.dart';
import 'identification_detail_page.dart';

class IdentificationHistoryPage extends StatefulWidget {
  const IdentificationHistoryPage({Key? key}) : super(key: key);

  @override
  State<IdentificationHistoryPage> createState() => _IdentificationHistoryPageState();
}

class _IdentificationHistoryPageState extends State<IdentificationHistoryPage> {
  final HomeController controller = Get.find<HomeController>();
  String _selectedFilter = 'all'; // all, high, medium, low
  String _selectedSort = 'recent'; // recent, confidence, name

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 顶部AppBar
          _buildSliverAppBar(localizations),

          // 筛选和排序栏
          SliverToBoxAdapter(
            child: _buildFilterBar(),
          ),

          // 识别历史列表
          Obx(() {
            if (controller.isLoadingHistory.value) {
              return SliverToBoxAdapter(
                child: _buildLoadingState(),
              );
            }

            final filteredHistory = _getFilteredHistory();

            if (filteredHistory.isEmpty) {
              return SliverToBoxAdapter(
                child: _buildEmptyState(localizations),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final identification = filteredHistory[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildHistoryCard(identification),
                    );
                  },
                  childCount: filteredHistory.length,
                ),
              ),
            );
          }),

          // 底部间距
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  /// 构建顶部AppBar
  Widget _buildSliverAppBar(AppLocalizations localizations) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryGreen,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          onPressed: () => _showClearHistoryDialog(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.history_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              localizations.recentIdentifications,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryGreen,
                AppTheme.primaryGreen.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Icon(
                  Icons.local_florist_rounded,
                  size: 200,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建筛选栏
  Widget _buildFilterBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 置信度筛选
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                _buildFilterChip(
                  'all',
                  '全部',
                  Icons.apps_rounded,
                  isFilter: true,
                ),
                _buildFilterChip(
                  'high',
                  '高置信',
                  Icons.verified_rounded,
                  isFilter: true,
                ),
                _buildFilterChip(
                  'medium',
                  '中置信',
                  Icons.check_circle_outline_rounded,
                  isFilter: true,
                ),
                _buildFilterChip(
                  'low',
                  '低置信',
                  Icons.help_outline_rounded,
                  isFilter: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // 排序选项
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                _buildFilterChip(
                  'recent',
                  '最新',
                  Icons.schedule_rounded,
                  isFilter: false,
                ),
                _buildFilterChip(
                  'confidence',
                  '置信度',
                  Icons.trending_up_rounded,
                  isFilter: false,
                ),
                _buildFilterChip(
                  'name',
                  '名称',
                  Icons.sort_by_alpha_rounded,
                  isFilter: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建筛选/排序按钮
  Widget _buildFilterChip(String value, String label, IconData icon, {required bool isFilter}) {
    final isSelected = isFilter 
        ? _selectedFilter == value 
        : _selectedSort == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isFilter) {
              _selectedFilter = value;
            } else {
              _selectedSort = value;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryGreen.withOpacity(0.1) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryGreen : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryGreen : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建历史卡片
  Widget _buildHistoryCard(PlantIdentification identification) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // 导航到植物详情页
            Get.to(
               () => PlantIdentificationDetailPage(
                identification: identification,
              ),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 300),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 植物图片
                Hero(
                  tag: 'plant_${identification.id}',
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: identification.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: identification.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppTheme.primaryGreen.withOpacity(0.1),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.primaryGreen,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppTheme.primaryGreen.withOpacity(0.1),
                              child: const Icon(
                                Icons.local_florist_rounded,
                                color: AppTheme.primaryGreen,
                                size: 32,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.local_florist_rounded,
                            color: AppTheme.primaryGreen,
                            size: 32,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // 植物信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        identification.commonName ?? 
                            identification.scientificName ?? 
                            'Unknown Plant',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3436),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      if (identification.scientificName != null &&
                          identification.scientificName != identification.commonName)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            identification.scientificName!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _formatDate(identification.identifiedAt),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (identification.confidence != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getConfidenceColor(
                                  identification.confidence!,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getConfidenceIcon(identification.confidence!),
                                    size: 12,
                                    color: _getConfidenceColor(
                                      identification.confidence!,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${(identification.confidence! * 100).toInt()}%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _getConfidenceColor(
                                        identification.confidence!,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 箭头图标
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return Container(
      height: 400,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
          ),
          const SizedBox(height: 16),
          Text(
            '加载中...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(AppLocalizations localizations) {
    return Container(
      height: 400,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.history_outlined,
              size: 50,
              color: AppTheme.primaryGreen.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            localizations.noRecentIdentifications,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.identifyPlantToStart,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 获取筛选后的历史记录
  List<PlantIdentification> _getFilteredHistory() {
    var history = controller.recentHistory.toList();

    // 根据置信度筛选
    if (_selectedFilter != 'all') {
      history = history.where((item) {
        if (item.confidence == null) return false;
        switch (_selectedFilter) {
          case 'high':
            return item.confidence! >= 0.75;
          case 'medium':
            return item.confidence! >= 0.5 && item.confidence! < 0.75;
          case 'low':
            return item.confidence! < 0.5;
          default:
            return true;
        }
      }).toList();
    }

    // 根据排序方式排序
    switch (_selectedSort) {
      case 'recent':
        history.sort((a, b) => b.identifiedAt!.compareTo(a.identifiedAt!));
        break;
      case 'confidence':
        history.sort((a, b) {
          final aConf = a.confidence ?? 0;
          final bConf = b.confidence ?? 0;
          return bConf.compareTo(aConf);
        });
        break;
      case 'name':
        history.sort((a, b) {
          final aName = a.commonName ?? a.scientificName ?? '';
          final bName = b.commonName ?? b.scientificName ?? '';
          return aName.compareTo(bName);
        });
        break;
    }

    return history;
  }

  /// 显示清空历史对话框
  void _showClearHistoryDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 22),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                '清空历史记录',
                style: TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const Text('确定要清空所有识别历史吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              '取消',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 实现清空历史的功能
              Get.back();
              Get.snackbar(
                '成功',
                '历史记录已清空',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.primaryGreen,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 格式化日期
  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 获取置信度颜色
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.75) {
      return Colors.green;
    } else if (confidence >= 0.5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// 获取置信度图标
  IconData _getConfidenceIcon(double confidence) {
    if (confidence >= 0.75) {
      return Icons.verified_rounded;
    } else if (confidence >= 0.5) {
      return Icons.check_circle_outline_rounded;
    } else {
      return Icons.help_outline_rounded;
    }
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/plant_identification.dart';
import '../../l10n/app_localizations.dart';
import 'ai_video_page.dart';

class PlantIdentificationDetailPage extends StatefulWidget {
  final PlantIdentification identification;

  const PlantIdentificationDetailPage({
    Key? key,
    required this.identification,
  }) : super(key: key);

  @override
  State<PlantIdentificationDetailPage> createState() =>
      _PlantIdentificationDetailPageState();
}

class _PlantIdentificationDetailPageState
    extends State<PlantIdentificationDetailPage> {
  int _selectedSeason = 2; // 0: 春, 1: 夏, 2: 秋, 3: 冬
  bool _showGeneratedVideos = false;

  final List<String> _seasonImages = [
    'https://picsum.photos/800/600?random=1', // 春
    'https://picsum.photos/800/600?random=2', // 夏
    'https://picsum.photos/800/600?random=3', // 秋
    'https://picsum.photos/800/600?random=4', // 冬
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 顶部图片轮播区域
              _buildImageHeader(),

              // 内容区域
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  transform: Matrix4.translationValues(0, -16, 0),
                  child: Column(
                    children: [
                      _buildPlantInfo(),
                      _buildBasicInfo(),
                      _buildGrowthEnvironment(),
                      _buildSeasonalChanges(),
                      _buildAIVideos(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 顶部导航栏
          _buildTopBar(),

          // 底部生成AI视频按钮
          _buildBottomButton(),
        ],
      ),
    );
  }

  /// 构建顶部图片头部
  Widget _buildImageHeader() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: false,
      backgroundColor: Colors.black,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 单张图片展示
            CachedNetworkImage(
              imageUrl: widget.identification.imageUrl ??
                  'https://picsum.photos/800/600?random=5',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_florist_rounded, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      '图片加载失败',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            // 渐变遮罩（底部）
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建图片页面
  // 已移除，不再需要

  /// 构建视频占位符
  // 已移除，不再需要

  /// 构建顶部导航栏
  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.3),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // 返回按钮
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ),
                    onPressed: () => Get.back(),
                    color: const Color(0xFF2D3436),
                  ),
                ),
                const Spacer(),
                // 语言按钮
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.language_rounded,
                      size: 20,
                    ),
                    onPressed: () {
                      // 显示语言选择
                    },
                    color: const Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建植物信息
  Widget _buildPlantInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.identification.commonName ??
                widget.identification.scientificName ??
                'Unknown Plant',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.identification.scientificName ?? '',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryGreen,
            ),
          ),
          if (widget.identification.confidence != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getConfidenceColor(widget.identification.confidence!)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      _getConfidenceColor(widget.identification.confidence!),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_rounded,
                    color:
                        _getConfidenceColor(widget.identification.confidence!),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '置信度: ${(widget.identification.confidence! * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getConfidenceColor(
                          widget.identification.confidence!),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建基本信息
  Widget _buildBasicInfo() {
    return _buildExpandableCard(
      title: '基本信息',
      initiallyExpanded: true,
      child: const Text(
        '枫树是一种落叶乔木，以其充满活力的秋叶而闻名。由于其美丽和提供树荫的特性，它是园林绿化的热门选择。该树的汁液也用于生产枫糖浆。',
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey,
          height: 1.6,
        ),
      ),
    );
  }

  /// 构建生长环境
  Widget _buildGrowthEnvironment() {
    return _buildExpandableCard(
      title: '生长环境',
      child: const Text(
        '枫树在排水良好的土壤的温带地区茁壮成长。它们通常在北美、欧洲和亚洲的森林和公园中被发现。',
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey,
          height: 1.6,
        ),
      ),
    );
  }

  /// 构建季节变化
  Widget _buildSeasonalChanges() {
    return _buildExpandableCard(
      title: '季节变化',
      child: Column(
        children: [
          // 季节图片
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(_seasonImages[_selectedSeason]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 季节滑块
          Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 8,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 12,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 24,
                  ),
                  activeTrackColor: AppTheme.primaryGreen,
                  inactiveTrackColor: Colors.grey[300],
                  thumbColor: AppTheme.primaryGreen,
                  overlayColor: AppTheme.primaryGreen.withOpacity(0.2),
                ),
                child: Slider(
                  value: _selectedSeason.toDouble(),
                  min: 0,
                  max: 3,
                  divisions: 3,
                  onChanged: (value) {
                    setState(() {
                      _selectedSeason = value.toInt();
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['春', '夏', '秋', '冬']
                    .map(
                      (season) => Text(
                        season,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建AI视频区域
  Widget _buildAIVideos() {
    if (!_showGeneratedVideos) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        padding: const EdgeInsets.all(20),
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
        child: Center(
          child: Text(
            '暂无AI视频',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '已生成AI视频',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://picsum.photos/160/100?random=${index + 10}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black.withOpacity(0.3),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_filled_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建可展开卡片
  Widget _buildExpandableCard({
    required String title,
    required Widget child,
    bool initiallyExpanded = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3436),
            ),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          trailing: const Icon(Icons.expand_more_rounded),
          children: [child],
        ),
      ),
    );
  }

  /// 构建底部按钮
  Widget _buildBottomButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF8FAFC).withOpacity(0),
              const Color(0xFFF8FAFC).withOpacity(0.9),
              const Color(0xFFF8FAFC),
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: ElevatedButton(
            onPressed: () {
              // 导航到AI视频生成页面
              Get.to(
                () => AIVideoGenerationPage(
                  identification: widget.identification,
                ),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 300),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 8,
              shadowColor: AppTheme.primaryGreen.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showGeneratedVideos
                      ? Icons.movie_filter_rounded
                      : Icons.movie_rounded,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  _showGeneratedVideos ? '重新生成AI视频' : '生成AI视频',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
}
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_application_1/presentation/pages/plant_detail_page.dart';

/// 热门植物页面 - 展示植物网格列表
class PopularPlantsPage extends StatefulWidget {
  final String title; // 页面标题
  final String category; // 分类名称
  
  const PopularPlantsPage({
    Key? key, 
    this.title = 'Popular Plants',
    this.category = 'Popular Plants',
  }) : super(key: key);

  @override
  State<PopularPlantsPage> createState() => _PopularPlantsPageState();
}

class _PopularPlantsPageState extends State<PopularPlantsPage> with TickerProviderStateMixin {
  // 搜索框控制器
  late final TextEditingController _searchController;
  // 滚动控制器
  final ScrollController _scrollController = ScrollController();
  
  // 是否显示筛选模态框
  bool _showFilterModal = false;
  // 是否正在加载
  bool _isLoading = false;
  
  // 当前选中的排序方式
  String _selectedSort = 'popular';
  // 选中的植物类型
  final List<String> _selectedPlantTypes = [];
  // 选中的内容类型
  final List<String> _selectedContentTypes = [];

  // 淡入淡出动画控制器
  late AnimationController _fadeController;
  
  // 植物数据列表
  final List<PlantItem> _plants = [
    PlantItem(
      name: 'Monstera Deliciosa',
      description: 'Tropical beauty',
      imageUrl: 'https://picsum.photos/400/600?random=11',
      popularity: 2100,
      isNew: false,
      isVideo: false,
    ),
    PlantItem(
      name: 'Fiddle Leaf Fig',
      description: 'Statement piece',
      imageUrl: 'https://picsum.photos/400/600?random=12',
      popularity: 1800,
      isNew: false,
      isVideo: false,
    ),
    PlantItem(
      name: 'Snake Plant',
      description: 'Low maintenance',
      imageUrl: 'https://picsum.photos/400/600?random=13',
      popularity: 0,
      isNew: true,
      isVideo: false,
    ),
    PlantItem(
      name: 'ZZ Plant',
      description: 'Easy care',
      imageUrl: 'https://picsum.photos/400/600?random=14',
      popularity: 0,
      isNew: false,
      isVideo: false,
    ),
    PlantItem(
      name: 'Peace Lily',
      description: 'Elegant blooms',
      imageUrl: 'https://picsum.photos/400/600?random=15',
      popularity: 0,
      isNew: false,
      isVideo: false,
    ),
    PlantItem(
      name: 'Calathea',
      description: 'Striking patterns',
      imageUrl: 'https://picsum.photos/400/600?random=16',
      popularity: 0,
      isNew: false,
      isVideo: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    // 初始化搜索框内容为分类名称
    _searchController = TextEditingController(text: widget.category);
    
    // 初始化淡入淡出动画
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// 应用筛选条件
  void _applyFilters() {
    setState(() {
      _isLoading = true;
      _showFilterModal = false;
    });
    
    // 淡出后延迟再淡入，模拟加载效果
    _fadeController.reverse().then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _fadeController.forward();
        }
      });
    });
  }

  /// 重置所有筛选条件
  void _resetFilters() {
    setState(() {
      _selectedSort = 'popular';
      _selectedPlantTypes.clear();
      _selectedContentTypes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                    child: Column(
                      children: [
                        _buildSearchAndFilter(),
                        const SizedBox(height: 12),
                        _buildGridContent(),
                        if (_isLoading) _buildLoadingIndicator(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // 筛选模态框
          if (_showFilterModal) _buildFilterModal(),
        ],
      ),
    );
  }

  /// 构建顶部标题栏
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F7).withOpacity(0.8),
        border: Border(
          bottom: BorderSide(color: Colors.black.withOpacity(0.05), width: 1),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  // 返回按钮
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: const EdgeInsets.all(8),
                  ),
                  // 页面标题
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF122017),
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 48), // 平衡左侧按钮宽度
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建搜索框和筛选按钮
  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        // 搜索框
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // 搜索图标
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ),
                // 输入框
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Search for plants',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(bottom: 1), // 微调使光标居中
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ),
                // 清除按钮（仅在有文字时显示）
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(
                        Icons.cancel,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 16),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 筛选按钮
        GestureDetector(
          onTap: () => setState(() => _showFilterModal = true),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.tune,
              color: Color(0xFF122017),
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建网格内容
  Widget _buildGridContent() {
    return FadeTransition(
      opacity: _fadeController,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 每行2列
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.68, // 进一步减小比例，给文字更多空间
        ),
        itemCount: _plants.length,
        itemBuilder: (context, index) {
          return _PlantGridItem(plant: _plants[index]);
        },
      ),
    );
  }

  /// 构建加载指示器
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38e07b)),
        ),
      ),
    );
  }

  /// 构建筛选模态框
  Widget _buildFilterModal() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showFilterModal = false),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () {}, // 阻止点击模态框内容时关闭
                child: Container(
                  margin: const EdgeInsets.only(top: 100, left: 16, right: 16),
                  constraints: const BoxConstraints(maxWidth: 480, maxHeight: 580),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F8F7),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 可滚动的筛选选项区域
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSortSection(),
                              const SizedBox(height: 20),
                              _buildPlantTypeSection(),
                              const SizedBox(height: 20),
                              _buildContentTypeSection(),
                            ],
                          ),
                        ),
                      ),
                      _buildModalFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建排序选项区域
  Widget _buildSortSection() {
    final options = [
      {'value': 'popular', 'label': 'Most Popular'},
      {'value': 'newest', 'label': 'Newest'},
      {'value': 'name_asc', 'label': 'Name A-Z'},
      {'value': 'longest_video', 'label': 'Longest Video'},
      {'value': 'most_viewed', 'label': 'Most Viewed'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sort by',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF122017),
          ),
        ),
        const SizedBox(height: 10),
        ...options.map((option) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SortOption(
              label: option['label']!,
              value: option['value']!,
              isSelected: _selectedSort == option['value'],
              onTap: () => setState(() => _selectedSort = option['value']!),
            ),
          );
        }).toList(),
      ],
    );
  }

  /// 构建植物类型筛选区域
  Widget _buildPlantTypeSection() {
    return _ExpandableSection(
      title: 'Plant Type',
      children: [
        _FilterCheckbox(
          label: 'Flowers',
          value: 'flowers',
          isSelected: _selectedPlantTypes.contains('flowers'),
          onChanged: (value) {
            setState(() {
              if (value) {
                _selectedPlantTypes.add('flowers');
              } else {
                _selectedPlantTypes.remove('flowers');
              }
            });
          },
        ),
        _FilterCheckbox(
          label: 'Shrubs',
          value: 'shrubs',
          isSelected: _selectedPlantTypes.contains('shrubs'),
          onChanged: (value) {
            setState(() {
              if (value) {
                _selectedPlantTypes.add('shrubs');
              } else {
                _selectedPlantTypes.remove('shrubs');
              }
            });
          },
        ),
        _FilterCheckbox(
          label: 'Trees',
          value: 'trees',
          isSelected: _selectedPlantTypes.contains('trees'),
          onChanged: (value) {
            setState(() {
              if (value) {
                _selectedPlantTypes.add('trees');
              } else {
                _selectedPlantTypes.remove('trees');
              }
            });
          },
        ),
      ],
    );
  }

  /// 构建内容类型筛选区域
  Widget _buildContentTypeSection() {
    return _ExpandableSection(
      title: 'Content Type',
      children: [
        _FilterCheckbox(
          label: 'Image',
          value: 'image',
          isSelected: _selectedContentTypes.contains('image'),
          onChanged: (value) {
            setState(() {
              if (value) {
                _selectedContentTypes.add('image');
              } else {
                _selectedContentTypes.remove('image');
              }
            });
          },
        ),
        _FilterCheckbox(
          label: 'Video',
          value: 'video',
          isSelected: _selectedContentTypes.contains('video'),
          onChanged: (value) {
            setState(() {
              if (value) {
                _selectedContentTypes.add('video');
              } else {
                _selectedContentTypes.remove('video');
              }
            });
          },
        ),
        _FilterCheckbox(
          label: 'Article',
          value: 'article',
          isSelected: _selectedContentTypes.contains('article'),
          onChanged: (value) {
            setState(() {
              if (value) {
                _selectedContentTypes.add('article');
              } else {
                _selectedContentTypes.remove('article');
              }
            });
          },
        ),
      ],
    );
  }

  /// 构建模态框底部按钮
  Widget _buildModalFooter() {
    // 判断是否有筛选条件变更
    final hasChanges = _selectedSort != 'popular' || 
                       _selectedPlantTypes.isNotEmpty || 
                       _selectedContentTypes.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.1), width: 1),
        ),
      ),
      child: Row(
        children: [
          // 重置按钮
          Expanded(
            child: ElevatedButton(
              onPressed: _resetFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF122017).withOpacity(0.1),
                foregroundColor: const Color(0xFF122017),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text(
                'Reset',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // 应用按钮
          Expanded(
            child: ElevatedButton(
              onPressed: hasChanges ? _applyFilters : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38e07b),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF38e07b).withOpacity(0.5),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 植物网格项组件
class _PlantGridItem extends StatelessWidget {
  final PlantItem plant;

  const _PlantGridItem({required this.plant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 导航到植物详情页
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailPage(
              name: plant.name,
              description: plant.description,
              imageUrl: plant.imageUrl,
              popularity: plant.popularity > 0 ? plant.popularity : null,
              isNew: plant.isNew,
              isVideo: plant.isVideo,
              tags: const [],
              tagColors: const [],
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片容器 - 使用 Expanded
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Hero 动画图片
                    Hero(
                      tag: 'plant_${plant.name}_${plant.imageUrl}',
                      child: Image.network(
                        plant.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50),
                          );
                        },
                      ),
                    ),
                    // 人气徽章（右下角）
                    if (plant.popularity > 0)
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 55),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                color: Colors.red,
                                size: 9,
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  plant.popularity >= 1000
                                      ? '${(plant.popularity / 1000).toStringAsFixed(1)}k'
                                      : plant.popularity.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // NEW 标签（左上角）
                    if (plant.isNew)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38e07b),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Color(0xFF122017),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // 视频播放图标
                    if (plant.isVideo)
                      Container(
                        color: Colors.black.withOpacity(0.2),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          // 植物名称
          Text(
            plant.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF122017),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          // 植物描述
          Text(
            plant.description,
            style: TextStyle(
              fontSize: 10,
              color: const Color(0xFF122017).withOpacity(0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// 排序选项组件
class _SortOption extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF38e07b).withOpacity(0.2)
              : const Color(0xFF122017).withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: const Color(0xFF122017),
                ),
              ),
            ),
            // 选中指示器
            if (isSelected)
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFF38e07b),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 12),
              )
            else
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF122017).withOpacity(0.2),
                    width: 1.5,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 可展开的筛选区域组件
class _ExpandableSection extends StatefulWidget {
  final String title;
  final List<Widget> children;

  const _ExpandableSection({
    required this.title,
    required this.children,
  });

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 点击展开/收起
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF122017),
                ),
              ),
              AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.expand_more, color: Color(0xFF122017), size: 22),
              ),
            ],
          ),
        ),
        // 展开后显示的内容
        if (_isExpanded) ...[
          const SizedBox(height: 10),
          ...widget.children,
        ],
      ],
    );
  }
}

/// 筛选复选框组件
class _FilterCheckbox extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  const _FilterCheckbox({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => onChanged(!isSelected),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF38e07b).withOpacity(0.2)
                : const Color(0xFF122017).withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // 复选框
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF38e07b) : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF38e07b)
                        : const Color(0xFF122017).withOpacity(0.2),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : null,
              ),
              const SizedBox(width: 10),
              // 标签文字
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF122017),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 植物数据模型
class PlantItem {
  final String name; // 植物名称
  final String description; // 植物描述
  final String imageUrl; // 图片URL
  final int popularity; // 人气值
  final bool isNew; // 是否新品
  final bool isVideo; // 是否视频

  PlantItem({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.popularity,
    required this.isNew,
    required this.isVideo,
  });
}
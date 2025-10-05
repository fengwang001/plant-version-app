import 'package:flutter/material.dart';
import 'dart:ui';

class PlantDetailPage extends StatefulWidget {
  final String name;
  final String description;
  final String imageUrl;
  final List<String>? imageUrls; // 新增：支持多张图片
  final int? popularity;
  final bool isNew;
  final bool isVideo;
  final List<String> tags;
  final List<Color> tagColors;

  const PlantDetailPage({
    Key? key,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.imageUrls,
    this.popularity,
    this.isNew = false,
    this.isVideo = false,
    this.tags = const [],
    this.tagColors = const [],
  }) : super(key: key);

  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  bool _showTitle = false;
  bool _isFavorite = false;
  int _currentImageIndex = 0;
  
  late AnimationController _fadeController;
  late AnimationController _heartController;
  
  List<String> _displayImages = [];

  final List<Map<String, String>> _careInfo = [
    {'icon': '💧', 'label': 'Water', 'value': '每周2-3次'},
    {'icon': '☀️', 'label': 'Light', 'value': '明亮散射光'},
    {'icon': '🌡️', 'label': 'Temp', 'value': '18-25°C'},
    {'icon': '💨', 'label': 'Humidity', 'value': '60-80%'},
  ];

  final List<String> _relatedPlants = [
    'https://picsum.photos/300/300?random=21',
    'https://picsum.photos/300/300?random=22',
    'https://picsum.photos/300/300?random=23',
    'https://picsum.photos/300/300?random=24',
  ];

  @override
  void initState() {
    super.initState();
    
    // 初始化图片列表 - 添加调试信息
    if (widget.imageUrls != null && widget.imageUrls!.isNotEmpty) {
      _displayImages = widget.imageUrls!;
      print('Using imageUrls: ${_displayImages.length} images');
    } else {
      _displayImages = [widget.imageUrl];
      print('Using single imageUrl');
    }
    
    print('Display images count: ${_displayImages.length}');
    
    _scrollController.addListener(_onScroll);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeController.forward();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showTitle) {
      setState(() => _showTitle = true);
    } else if (_scrollController.offset <= 200 && _showTitle) {
      setState(() => _showTitle = false);
    }
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    if (_isFavorite) {
      _heartController.forward().then((_) => _heartController.reverse());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _fadeController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeroImage(),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeController,
                  child: Column(
                    children: [
                      _buildMainInfo(),
                      _buildCareGuide(),
                      _buildDescription(),
                      _buildRelatedPlants(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildFloatingHeader(),
          _buildBottomActions(),
          // 确保按钮在最上层
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        print('Back button tapped');
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFF122017),
                          size: 20,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Share feature coming soon!'),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.share,
                          color: Color(0xFF122017),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: _displayImages.isEmpty 
            ? Container(color: Colors.grey[300], child: const Icon(Icons.image, size: 80))
            : Stack(
          children: [
            // 图片轮播 - 确保占满整个区域
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(), // 添加物理效果
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                    print('Swiped to image $index');
                  });
                },
                itemCount: _displayImages.length,
                itemBuilder: (context, index) {
                  return Hero(
                    tag: index == 0 ? 'plant_${widget.name}_${widget.imageUrl}' : 'plant_${widget.name}_extra_$index',
                    child: Image.network(
                      _displayImages[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 80),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            
            // 渐变遮罩 - 不拦截触摸事件
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.transparent,
                        const Color(0xFFF6F8F7),
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            
            // 图片指示器 - 不拦截触摸事件
            if (_displayImages.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_displayImages.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentImageIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentImageIndex == index
                              ? const Color(0xFF38e07b)
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            
            // 图片计数器 - 不拦截触摸事件
            if (_displayImages.length > 1)
              Positioned(
                top: 80,
                right: 16,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentImageIndex + 1}/${_displayImages.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            
            // 人气徽章 - 不拦截触摸事件
            if (widget.popularity != null && widget.popularity! > 0)
              Positioned(
                top: _displayImages.length > 1 ? 120 : 80,
                right: 16,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.red, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          widget.popularity! >= 1000
                              ? '${(widget.popularity! / 1000).toStringAsFixed(1)}k'
                              : widget.popularity.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            // 视频播放按钮 - 只在第一张显示，仅覆盖中心区域
            if (widget.isVideo && _currentImageIndex == 0)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Play video feature coming soon!'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Color(0xFF38e07b),
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingHeader() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _showTitle ? 1.0 : 0.0,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8F7).withOpacity(0.95),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF122017),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFixedTopButtons() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF122017), size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Color(0xFF122017), size: 20),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF122017),
                            ),
                          ),
                        ),
                        if (widget.isVideo) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF38e07b).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.videocam, color: Color(0xFF38e07b), size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Video',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF38e07b),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF122017).withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _toggleFavorite,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.3).animate(
                    CurvedAnimation(parent: _heartController, curve: Curves.easeOut),
                  ),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _isFavorite
                          ? const Color(0xFF38e07b).withOpacity(0.2)
                          : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? const Color(0xFF38e07b) : Colors.grey,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (widget.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(widget.tags.length, (index) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.tagColors[index].withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.tags[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: widget.tagColors[index],
                    ),
                  ),
                );
              }),
            ),
          ],
          if (widget.isVideo) ...[
            const SizedBox(height: 20),
            _buildVideoInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF38e07b).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF38e07b).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF38e07b).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Color(0xFF38e07b),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Video Content',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF122017),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to watch full video tutorial',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF122017).withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF38e07b),
                size: 20,
              ),
            ],
          ),
          if (_displayImages.length > 1) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.photo_library,
                    color: Color(0xFF38e07b),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_displayImages.length - 1} 张配图可左右滑动查看',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF122017).withOpacity(0.7),
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

  Widget _buildCareGuide() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Text(
            'Care Guide',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF122017),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2,
            ),
            itemCount: _careInfo.length,
            itemBuilder: (context, index) {
              final info = _careInfo[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(info['icon']!, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          info['label']!,
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF122017).withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info['value']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF122017),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isVideo ? 'Video Description' : 'About',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF122017),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.isVideo
                ? '这个精彩的视频展示了植物生长的完整过程，包括播种、发芽、成长到开花的全过程。\n\n'
                    '视频时长: 5:32\n'
                    '作者: ${widget.description}\n'
                    '发布时间: 2天前\n\n'
                    '通过延时摄影技术，我们可以清晰地观察到植物每个生长阶段的细微变化，这对于了解植物习性和掌握养护技巧非常有帮助。'
                : '这是一种非常受欢迎的室内植物，以其独特的叶片和易于养护的特性而闻名。它能够适应各种室内环境，是初学者的理想选择。\n\n'
                    '该植物原产于热带地区，喜欢温暖湿润的环境。在适当的护理下，它可以生长多年，并为您的室内空间增添自然气息。\n\n'
                    '养护提示：保持土壤微湿，避免过度浇水。放置在明亮但避免直射阳光的位置。定期喷水以保持湿度。',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: const Color(0xFF122017).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedPlants() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Related Plants',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF122017),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _relatedPlants.length,
            itemBuilder: (context, index) {
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _relatedPlants[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 40),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38e07b),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add to My Garden',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF38e07b), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF38e07b)),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
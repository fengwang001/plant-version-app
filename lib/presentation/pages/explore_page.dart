import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Popular', 'Newest', 'Type'];
  
  double _headerOpacity = 0.0;

  // 模拟数据
  final List<FeaturedItem> _featuredItems = [
    FeaturedItem(
      category: 'Plant of the Day',
      title: 'Redwood',
      description: 'Discover the unique characteristics of the majestic Redwood.',
      imageUrl: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
    ),
    FeaturedItem(
      category: 'Flower Spotlight',
      title: 'Hibiscus',
      description: 'Learn about the vibrant colors of the Hibiscus.',
      imageUrl: 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=800',
    ),
  ];

  final List<KnowledgeArticle> _knowledgeArticles = [
    KnowledgeArticle(
      title: 'The Secret Life of Trees',
      description: 'Explore the fascinating world of trees.',
      imageUrl: 'https://images.unsplash.com/photo-1511497584788-876760111969?w=400',
    ),
    KnowledgeArticle(
      title: 'Understanding Plant Nutrition',
      description: 'Learn about essential nutrients.',
      imageUrl: 'https://images.unsplash.com/photo-1466781783364-36c955e42a7f?w=400',
    ),
  ];

  final List<CommunityHighlight> _communityHighlights = [
    CommunityHighlight(
      title: "User1's Garden Tour",
      description: 'A stunning home garden.',
      imageUrl: 'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?w=400',
    ),
    CommunityHighlight(
      title: 'AI Plant Video',
      description: 'Creative AI-generated video.',
      imageUrl: 'https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?w=400',
    ),
  ];

  final List<VideoShowcase> _videoShowcase = [
    VideoShowcase(
      title: 'Blooming Flower',
      description: 'Stunning AI-generated video.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=400',
    ),
    VideoShowcase(
      title: "Nature's Beauty",
      description: 'AI-created plant animation.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    setState(() {
      _headerOpacity = (offset / 100).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildStickyHeader(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeaturedSection(),
                const SizedBox(height: 32),
                _buildKnowledgeSection(),
                const SizedBox(height: 32),
                _buildCommunitySection(),
                const SizedBox(height: 32),
                _buildVideoSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyHeader() {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: Color(0xFFF6F8F7).withOpacity(0.8 + _headerOpacity * 0.2),
      elevation: _headerOpacity * 2,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ColorFilter.mode(
            Colors.white.withOpacity(0.1),
            BlendMode.srcOver,
          ),
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题栏
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 48),
                      const Text(
                        'Explore',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF122017),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search, color: Color(0xFF122017)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  
                  // 搜索框
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200]?.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for plants, articles...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  
                  // 筛选标签
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedFilter == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(_filters[index]),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() => _selectedFilter = index);
                            },
                            backgroundColor: Colors.grey[200]?.withOpacity(0.5),
                            selectedColor: const Color(0xFF38e07b),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF122017),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 14,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _featuredItems.length,
        itemBuilder: (context, index) {
          return _buildFeaturedCard(_featuredItems[index]);
        },
      ),
    );
  }

  Widget _buildFeaturedCard(FeaturedItem item) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 背景图片
            CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.local_florist, size: 60),
              ),
            ),
            
            // 渐变遮罩
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            
            // 内容
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF38e07b),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(
                        color: Colors.grey[200],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKnowledgeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Plant Knowledge',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF122017),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: _knowledgeArticles.length,
            itemBuilder: (context, index) {
              return _buildKnowledgeCard(_knowledgeArticles[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKnowledgeCard(KnowledgeArticle article) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: article.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.article),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF122017),
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  article.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Community Highlights',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF122017),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: _communityHighlights.length,
            itemBuilder: (context, index) {
              return _buildCommunityCard(_communityHighlights[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityCard(CommunityHighlight highlight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                imageUrl: highlight.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  highlight.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF122017),
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  highlight.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'AI Video Showcase',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF122017),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _videoShowcase.length,
            itemBuilder: (context, index) {
              return _buildVideoCard(_videoShowcase[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCard(VideoShowcase video) {
    return Container(
      width: 256,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.play_circle_outline, size: 48),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            video.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF122017),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            video.description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// 数据模型
class FeaturedItem {
  final String category;
  final String title;
  final String description;
  final String imageUrl;

  FeaturedItem({
    required this.category,
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

class KnowledgeArticle {
  final String title;
  final String description;
  final String imageUrl;

  KnowledgeArticle({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

class CommunityHighlight {
  final String title;
  final String description;
  final String imageUrl;

  CommunityHighlight({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

class VideoShowcase {
  final String title;
  final String description;
  final String thumbnailUrl;

  VideoShowcase({
    required this.title,
    required this.description,
    required this.thumbnailUrl,
  });
}
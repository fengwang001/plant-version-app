import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_application_1/presentation/pages/plant_detail_page.dart';
import 'package:flutter_application_1/presentation/pages/popular_plants_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  bool _showSortModal = false;
  int _selectedSort = 0;
  final List<String> _sortOptions = ['Most Popular', 'Latest Release', 'Name A-Z'];
  final List<String> _filterTags = ['Succulents', 'Flowering', 'Rare', 'Exotic'];
  final List<bool> _selectedFilters = [false, false, false, false];

  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  late AnimationController _pageController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this)..repeat(reverse: true);
    _fabAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _fabController, curve: Curves.easeInOut));
    _pageController = AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    _pageController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _fabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: Stack(
        children: [
          SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: _pageController, curve: Curves.easeOut)),
            child: FadeTransition(
              opacity: _pageController,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildHeader(),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildPopularPlantsSection(),
                        const SizedBox(height: 24),
                        _buildLatestDiscoveriesSection(),
                        const SizedBox(height: 24),
                        _buildGardeningTipsSection(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // _buildIdentifyFAB(),
          if (_showSortModal) _buildSortModal(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFFF6F8F7).withOpacity(0.8),
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for plants',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => setState(() => _showSortModal = true),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: const Icon(Icons.tune, color: Color(0xFF122017), size: 24),
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

  Widget _buildPopularPlantsSection() {
    return _AnimatedSection(
      delay: 100,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Popular Plants', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF122017))),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PopularPlantsPage(title: 'Popular Plants'),
                      ),
                    );
                  },
                  child: const Text('See All', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF38e07b))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 340,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _PlantCard(
                  imageUrl: 'https://picsum.photos/400/400?random=1',
                  title: 'Echeveria Elegans',
                  description: 'A popular succulent known for its tight rosettes of silvery-green leaves.',
                  badge: '1.2M',
                  badgeIcon: Icons.local_fire_department,
                  badgeColor: Colors.red,
                  tags: const ['Easy Care', 'New'],
                  tagColors: const [Color(0xFF10B981), Color(0xFF3B82F6)],
                ),
                _VideoCard(thumbnailUrl: 'https://picsum.photos/400/400?random=2', title: 'Tropical Paradise Tour', author: 'By @PlantLover_AI', likes: '980K'),
                _PlantCard(
                  imageUrl: 'https://picsum.photos/400/400?random=3',
                  title: 'Orchid Care 101',
                  description: 'Master the art of orchid care with these simple tips.',
                  tags: const ['Flowering', 'Care Tips'],
                  tagColors: const [Color(0xFFF59E0B), Color(0xFF8B5CF6)],
                ),
                _PlantCard(
                  imageUrl: 'https://picsum.photos/400/400?random=4',
                  title: 'Desert Gems Collection',
                  description: 'Source: Botanic Gardens',
                  badge: '850K',
                  badgeIcon: Icons.visibility,
                  badgeColor: Colors.blue,
                  tags: const ['Rare'],
                  tagColors: const [Color(0xFFF97316)],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestDiscoveriesSection() {
    return _AnimatedSection(
      delay: 200,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Latest Discoveries', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF122017))),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PopularPlantsPage(
                          title: 'Latest Discoveries',
                          category: 'Latest Discoveries',
                        ),
                      ),
                    );
                  },
                  child: const Text('See All', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF38e07b))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 320,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _DiscoveryCard(imageUrl: 'https://picsum.photos/400/400?random=5', title: 'Monstera Albo', description: 'A stunning variegated plant highly sought after.', stat: '789K', icon: Icons.local_fire_department, iconColor: Colors.red),
                _VideoCard(thumbnailUrl: 'https://picsum.photos/400/400?random=6', title: 'Blooming Timelapse', author: 'By @NatureInMotion', likes: '654K', iconColor: Colors.blue),
                _DiscoveryCard(imageUrl: 'https://picsum.photos/400/400?random=7', title: 'Exotic Species', description: 'Explore the world of exotic plants.', tag: 'Exotic', tagColor: const Color(0xFF8B5CF6)),
                _DiscoveryCard(imageUrl: 'https://picsum.photos/400/400?random=8', title: "Calathea 'White Fusion'", description: 'By @LeafyGreen', stat: '512K', icon: Icons.thumb_up, iconColor: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGardeningTipsSection() {
    return _AnimatedSection(
      delay: 300,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Gardening Tips', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF122017))),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PopularPlantsPage(
                          title: 'Gardening Tips',
                          category: 'Gardening Tips',
                        ),
                      ),
                    );
                  },
                  child: const Text('See All', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF38e07b))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 320,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _DiscoveryCard(imageUrl: 'https://picsum.photos/400/400?random=9', title: 'Essential Gardening Tools', description: 'A guide to must-have tools for every gardener.', tag: 'Techniques', tagColor: Colors.grey),
                _VideoCard(thumbnailUrl: 'https://picsum.photos/400/400?random=10', title: 'DIY Potting Mix', author: 'By @GardeningPro', likes: '432K'),
                _DiscoveryCard(imageUrl: 'https://picsum.photos/400/400?random=11', title: 'Watering Wisely', description: 'Learn when and how to water your plants.', tag: 'Care Tips', tagColor: const Color(0xFF3B82F6)),
                _DiscoveryCard(imageUrl: 'https://picsum.photos/400/400?random=12', title: 'Pruning Practices', description: 'Source: Expert Gardener Mag', stat: '315K', icon: Icons.visibility, iconColor: Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentifyFAB() {
    return Positioned(
      right: 20,
      bottom: 120,
      child: ScaleTransition(
        scale: _fabAnimation,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF38e07b),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: const Color(0xFF38e07b).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.camera_alt, color: Color(0xFF122017), size: 24),
                SizedBox(width: 8),
                Text('Identify Plant', style: TextStyle(color: Color(0xFF122017), fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortModal() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showSortModal = false),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 400),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Transform.translate(offset: Offset(0, -20 * (1 - value)), child: Opacity(opacity: value, child: child));
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    constraints: const BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Sort & Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF122017))),
                              GestureDetector(onTap: () => setState(() => _showSortModal = false), child: const Icon(Icons.close, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Sort by', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                              const SizedBox(height: 12),
                              ...List.generate(_sortOptions.length, (index) {
                                return _SortOption(label: _sortOptions[index], isSelected: _selectedSort == index, onTap: () => setState(() => _selectedSort = index));
                              }),
                              const SizedBox(height: 24),
                              Text('Filter by Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(_filterTags.length, (index) {
                                  final colors = [const Color(0xFF10B981), const Color(0xFFF59E0B), const Color(0xFFF97316), const Color(0xFF8B5CF6)];
                                  return _FilterChip(label: _filterTags[index], color: colors[index], isSelected: _selectedFilters[index], onTap: () => setState(() => _selectedFilters[index] = !_selectedFilters[index]));
                                }),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1))),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => setState(() => _showSortModal = false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF38e07b),
                                foregroundColor: const Color(0xFF122017),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Apply', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedSection extends StatefulWidget {
  final Widget child;
  final int delay;
  const _AnimatedSection({required this.child, this.delay = 0});
  @override
  State<_AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<_AnimatedSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)), child: widget.child),
    );
  }
}

class _PlantCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String? badge;
  final IconData? badgeIcon;
  final Color? badgeColor;
  final List<String> tags;
  final List<Color> tagColors;
  const _PlantCard({required this.imageUrl, required this.title, required this.description, this.badge, this.badgeIcon, this.badgeColor, this.tags = const [], this.tagColors = const []});
  @override
  State<_PlantCard> createState() => _PlantCardState();
}

class _PlantCardState extends State<_PlantCard> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailPage(
              name: widget.title,
              description: widget.description,
              imageUrl: widget.imageUrl,
              imageUrls: [
                widget.imageUrl,
                'https://picsum.photos/400/600?random=101',
                'https://picsum.photos/400/600?random=102',
              ],
              popularity: widget.badge != null ? int.tryParse(widget.badge!.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0 : null,
              isNew: false,
              isVideo: false,
              tags: widget.tags,
              tagColors: widget.tagColors,
            ),
          ),
        );
      },
      child: AnimatedScale(
        scale: _isHovered ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 224,
          margin: const EdgeInsets.only(right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 224,
                height: 224,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'plant_${widget.title}_${widget.imageUrl}',
                        child: Image.network(widget.imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300], child: const Icon(Icons.image, size: 60))),
                      ),
                      if (widget.badge != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(widget.badgeIcon, color: widget.badgeColor, size: 14),
                                const SizedBox(width: 4),
                                Text(widget.badge!, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF122017)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(widget.description, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (widget.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: List.generate(widget.tags.length, (index) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: widget.tagColors[index].withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                            child: Text(widget.tags[index], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: widget.tagColors[index])),
                          );
                        }),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoCard extends StatefulWidget {
  final String thumbnailUrl;
  final String title;
  final String author;
  final String likes;
  final Color iconColor;
  const _VideoCard({required this.thumbnailUrl, required this.title, required this.author, required this.likes, this.iconColor = Colors.red});
  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailPage(
              name: widget.title,
              description: widget.author,
              imageUrl: widget.thumbnailUrl,
              imageUrls: [
                widget.thumbnailUrl,
                'https://picsum.photos/400/600?random=201',
                'https://picsum.photos/400/600?random=202',
                'https://picsum.photos/400/600?random=203',
              ],
              popularity: int.tryParse(widget.likes.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
              isNew: false,
              isVideo: true,
              tags: const [],
              tagColors: const [],
            ),
          ),
        );
      },
      child: AnimatedScale(
        scale: _isHovered ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 224,
          margin: const EdgeInsets.only(right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 224,
                height: 224,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'plant_${widget.title}_${widget.thumbnailUrl}',
                        child: Image.network(widget.thumbnailUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300], child: const Icon(Icons.video_library, size: 60))),
                      ),
                      Container(
                        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.3)])),
                        child: const Center(child: Icon(Icons.play_circle_outline, color: Colors.white, size: 48)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF122017)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(widget.author, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.thumb_up, size: 14, color: widget.iconColor),
                        const SizedBox(width: 4),
                        Text(widget.likes, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF122017)))
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscoveryCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String? stat;
  final IconData? icon;
  final Color? iconColor;
  final String? tag;
  final Color? tagColor;
  const _DiscoveryCard({required this.imageUrl, required this.title, required this.description, this.stat, this.icon, this.iconColor, this.tag, this.tagColor});
  @override
  State<_DiscoveryCard> createState() => _DiscoveryCardState();
}

class _DiscoveryCardState extends State<_DiscoveryCard> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailPage(
              name: widget.title,
              description: widget.description,
              imageUrl: widget.imageUrl,
              popularity: widget.stat != null ? int.tryParse(widget.stat!.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0 : null,
              isNew: false,
              isVideo: false,
              tags: widget.tag != null ? [widget.tag!] : [],
              tagColors: widget.tag != null && widget.tagColor != null ? [widget.tagColor!] : [],
            ),
          ),
        );
      },
      child: AnimatedScale(
        scale: _isHovered ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 224,
          margin: const EdgeInsets.only(right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 224,
                height: 224,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))]),
                child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Hero(
                  tag: 'plant_${widget.title}_${widget.imageUrl}',
                  child: Image.network(widget.imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300], child: const Icon(Icons.image, size: 60))),
                )),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF122017)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(widget.description, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    if (widget.stat != null && widget.icon != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(widget.icon, size: 14, color: widget.iconColor),
                          const SizedBox(width: 4),
                          Text(widget.stat!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF122017)))
                        ],
                      )
                    else if (widget.tag != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: widget.tagColor?.withOpacity(0.15) ?? Colors.grey.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: Text(widget.tag!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: widget.tagColor ?? Colors.grey[700])),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _SortOption({required this.label, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFF38e07b).withOpacity(0.1) : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? const Color(0xFF38e07b) : const Color(0xFF122017))),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF38e07b), size: 20),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.color, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : color)),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_application_1/presentation/pages/plant_detail_page.dart';

class PopularPlantsPage extends StatefulWidget {
  final String title;
  final String category;
  
  const PopularPlantsPage({
    Key? key, 
    this.title = 'Popular Plants',
    this.category = 'Popular Plants',
  }) : super(key: key);

  @override
  State<PopularPlantsPage> createState() => _PopularPlantsPageState();
}

class _PopularPlantsPageState extends State<PopularPlantsPage> with TickerProviderStateMixin {
  late final TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();
  
  bool _showFilterModal = false;
  bool _isLoading = false;
  
  String _selectedSort = 'popular';
  final List<String> _selectedPlantTypes = [];
  final List<String> _selectedContentTypes = [];

  late AnimationController _fadeController;
  
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

  void _applyFilters() {
    setState(() {
      _isLoading = true;
      _showFilterModal = false;
    });
    
    _fadeController.reverse().then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _isLoading = false;
        });
        _fadeController.forward();
      });
    });
  }

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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildSearchAndFilter(),
                        const SizedBox(height: 16),
                        _buildGridContent(),
                        if (_isLoading) _buildLoadingIndicator(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // _buildBottomNavigation(),
          if (_showFilterModal) _buildFilterModal(),
        ],
      ),
    );
  }

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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF122017),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF122017).withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search in ${widget.title}',
                hintStyle: TextStyle(
                  color: const Color(0xFF122017).withOpacity(0.5),
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: const Color(0xFF122017).withOpacity(0.5),
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: const Color(0xFF122017).withOpacity(0.5),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => setState(() => _showFilterModal = true),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF38e07b).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.tune,
              color: Color(0xFF122017),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridContent() {
    return FadeTransition(
      opacity: _fadeController,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.65,
        ),
        itemCount: _plants.length,
        itemBuilder: (context, index) {
          return _PlantGridItem(plant: _plants[index]);
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: const SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38e07b)),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8F7).withOpacity(0.8),
          border: Border(
            top: BorderSide(color: Colors.black.withOpacity(0.1), width: 1),
          ),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(icon: Icons.explore, label: 'Explore', isActive: true),
                    _NavItem(icon: Icons.camera_alt, label: 'Identify', isActive: false),
                    _NavItem(icon: Icons.local_florist, label: 'My Garden', isActive: false),
                    _NavItem(icon: Icons.groups, label: 'Community', isActive: false),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.only(top: 96, left: 16, right: 16),
                  constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
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
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSortSection(),
                              const SizedBox(height: 24),
                              _buildPlantTypeSection(),
                              const SizedBox(height: 24),
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF122017),
          ),
        ),
        const SizedBox(height: 12),
        ...options.map((option) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
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

  Widget _buildModalFooter() {
    final hasChanges = _selectedSort != 'popular' || 
                       _selectedPlantTypes.isNotEmpty || 
                       _selectedContentTypes.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.1), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _resetFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF122017).withOpacity(0.1),
                foregroundColor: const Color(0xFF122017),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Reset',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: hasChanges ? _applyFilters : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38e07b),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF38e07b).withOpacity(0.5),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantGridItem extends StatelessWidget {
  final PlantItem plant;

  const _PlantGridItem({required this.plant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
          Expanded(
            child: Container(
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'plant_${plant.name}_${plant.imageUrl}',
                      child: Image.network(
                        plant.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 60),
                          );
                        },
                      ),
                    ),
                    if (plant.popularity > 0)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                color: Colors.red,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                plant.popularity >= 1000
                                    ? '${(plant.popularity / 1000).toStringAsFixed(1)}k'
                                    : plant.popularity.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (plant.isNew)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38e07b),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Color(0xFF122017),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (plant.isVideo)
                      Container(
                        color: Colors.black.withOpacity(0.2),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plant.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF122017),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            plant.description,
            style: TextStyle(
              fontSize: 13,
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF38e07b) : const Color(0xFF122017).withOpacity(0.6),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? const Color(0xFF38e07b) : const Color(0xFF122017).withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF38e07b).withOpacity(0.2)
              : const Color(0xFF122017).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: const Color(0xFF122017),
              ),
            ),
            if (isSelected)
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFF38e07b),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF122017).withOpacity(0.2),
                    width: 2,
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
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF122017),
                ),
              ),
              AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.expand_more, color: Color(0xFF122017)),
              ),
            ],
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 12),
          ...widget.children,
        ],
      ],
    );
  }
}

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
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => onChanged(!isSelected),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF38e07b).withOpacity(0.2)
                : const Color(0xFF122017).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF38e07b) : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF38e07b)
                        : const Color(0xFF122017).withOpacity(0.2),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
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

class PlantItem {
  final String name;
  final String description;
  final String imageUrl;
  final int popularity;
  final bool isNew;
  final bool isVideo;

  PlantItem({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.popularity,
    required this.isNew,
    required this.isVideo,
  });
}
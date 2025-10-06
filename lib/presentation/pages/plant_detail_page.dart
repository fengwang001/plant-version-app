// lib/presentation/pages/plant_detail_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';

/// 评论模型
class PlantComment {
  final String id;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String content;
  int likeCount;
  final DateTime postedAt;
  bool isLiked;
  List<PlantComment>? replies;

  PlantComment({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.content,
    required this.likeCount,
    required this.postedAt,
    this.isLiked = false,
    this.replies,
  });
}

class PlantDetailPage extends StatefulWidget {
  final String name;
  final String description;
  final String imageUrl;
  final List<String>? imageUrls;
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
  final TextEditingController _commentController = TextEditingController();
  
  bool _showTitle = false;
  bool _isFavorite = false;
  int _currentImageIndex = 0;
  
  late AnimationController _fadeController;
  late AnimationController _heartController;
  
  List<String> _displayImages = [];
  final List<PlantComment> _comments = [];
  bool _isLoadingComments = true;
  PlantComment? _replyingTo;

  @override
  void initState() {
    super.initState();
    
    _displayImages = widget.imageUrls?.isNotEmpty == true 
        ? widget.imageUrls!
        : [widget.imageUrl];
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scrollController.addListener(_onScroll);
    _fadeController.forward();
    
    _loadComments();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _commentController.dispose();
    _fadeController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    setState(() {
      _showTitle = offset > 200;
    });
  }

  Future<void> _loadComments() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _comments.addAll(_getMockComments());
        _isLoadingComments = false;
      });
    }
  }

  List<PlantComment> _getMockComments() {
    return [
      PlantComment(
        id: '1',
        userId: 'user1',
        username: 'Emma Wilson',
        avatarUrl: null, // 使用 null 来避免 SVG 加载错误
        content: 'Beautiful plant! I have one just like this in my garden. The care tips are very helpful!',
        likeCount: 24,
        postedAt: DateTime.now().subtract(const Duration(hours: 3)),
        replies: [
          PlantComment(
            id: '1-1',
            userId: 'user2',
            username: 'James Chen',
            avatarUrl: null,
            content: 'How often do you water yours? Mine seems to need more attention.',
            likeCount: 5,
            postedAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
      ),
      PlantComment(
        id: '2',
        userId: 'user3',
        username: 'Sarah Johnson',
        avatarUrl: null,
        content: 'Does this plant do well in indirect sunlight? I want to get one for my office.',
        likeCount: 12,
        postedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      PlantComment(
        id: '3',
        userId: 'user4',
        username: 'Mike Davis',
        avatarUrl: null,
        content: 'Great information! I learned so much about proper care techniques. 🌱',
        likeCount: 8,
        postedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    _heartController.forward(from: 0);
  }

  void _sendComment() {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = PlantComment(
      id: DateTime.now().toString(),
      userId: 'current_user',
      username: 'You',
      avatarUrl: null, // 使用 null 避免图片加载错误
      content: _commentController.text.trim(),
      likeCount: 0,
      postedAt: DateTime.now(),
    );

    setState(() {
      if (_replyingTo != null) {
        // 查找主评论
        final parentIndex = _comments.indexWhere((c) => c.id == _replyingTo!.id);
        if (parentIndex != -1) {
          // 直接回复主评论
          _comments[parentIndex].replies ??= [];
          _comments[parentIndex].replies!.insert(0, newComment);
        } else {
          // 检查是否回复的是某个回复
          for (var i = 0; i < _comments.length; i++) {
            if (_comments[i].replies != null) {
              final replyIndex = _comments[i].replies!.indexWhere((r) => r.id == _replyingTo!.id);
              if (replyIndex != -1) {
                // 添加到同一个主评论的回复列表中
                _comments[i].replies!.insert(0, newComment);
                break;
              }
            }
          }
        }
        _replyingTo = null;
      } else {
        _comments.insert(0, newComment);
      }
      _commentController.clear();
    });

    Get.snackbar(
      _replyingTo != null ? 'Reply Posted' : 'Comment Posted',
      _replyingTo != null 
          ? 'Your reply has been published'
          : 'Your comment has been published',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppTheme.primaryGreen.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildHeroImage(),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainInfo(),
                    _buildCareGuide(),
                    _buildDescription(),
                    _buildCommentsSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
          _buildFloatingTitle(),
          _buildTopButtons(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildTopButtons() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                print('🔙 返回按钮被点击');
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
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF122017),
                  size: 24,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                print('📤 分享按钮被点击');
                Get.snackbar(
                  'Share',
                  'Share functionality coming soon',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.8),
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.all(16),
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
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.share_outlined,
                  color: Color(0xFF122017),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'post_${widget.name}',
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemCount: _displayImages.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    _displayImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 80),
                      );
                    },
                  );
                },
              ),
            ),
            if (_displayImages.length > 1)
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_currentImageIndex + 1}/${_displayImages.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            if (_displayImages.length > 1)
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _displayImages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ),
            if (widget.isVideo && _currentImageIndex == 0)
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: AppTheme.primaryGreen,
                      size: 48,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  print('返回按钮被点击');
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
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF122017),
                    size: 24,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 50,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  print('分享按钮被点击');
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.share_outlined,
                    color: Color(0xFF122017),
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingTitle() {
    return AnimatedOpacity(
      opacity: _showTitle ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.only(top: 40),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF122017),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF122017),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.isNew) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurple,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _toggleFavorite,
                child: AnimatedBuilder(
                  animation: _heartController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_heartController.value * 0.3),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _isFavorite
                              ? Colors.red.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.grey[600],
                          size: 28,
                        ),
                      ),
                    );
                  },
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (widget.tagColors.isNotEmpty &&
                            index < widget.tagColors.length)
                        ? widget.tagColors[index].withOpacity(0.1)
                        : AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.tags[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: (widget.tagColors.isNotEmpty &&
                              index < widget.tagColors.length)
                          ? widget.tagColors[index]
                          : AppTheme.primaryGreen,
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCareGuide() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _buildCareItem(
                Icons.water_drop_outlined,
                'Water',
                'Every 2-3 days',
                Colors.blue,
              ),
              _buildCareItem(
                Icons.wb_sunny_outlined,
                'Light',
                'Bright indirect',
                Colors.orange,
              ),
              _buildCareItem(
                Icons.thermostat_outlined,
                'Temperature',
                '18-24°C',
                Colors.red,
              ),
              _buildCareItem(
                Icons.opacity_outlined,
                'Humidity',
                'Medium-High',
                Colors.teal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCareItem(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About This Plant',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF122017),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This beautiful plant is known for its lush foliage and air-purifying qualities. '
            'It thrives in bright, indirect light and prefers to be kept moist but not waterlogged. '
            'With proper care, it can grow into a stunning focal point in any room. '
            'Perfect for both beginners and experienced plant enthusiasts.',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Comments (${_comments.length})',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF122017),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showAllComments(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.comment_outlined,
                        size: 14,
                        color: AppTheme.primaryGreen,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingComments)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(
                  color: AppTheme.primaryGreen,
                ),
              ),
            )
          else if (_comments.isEmpty)
            _buildEmptyComments()
          else
            ..._comments.take(3).map((comment) => _CommentItem(
                  comment: comment,
                  onLike: () => _toggleCommentLike(comment),
                  onReply: () => _replyToComment(comment),
                  onReplyToReply: (reply) => _replyToComment(reply),
                )),
          const SizedBox(height: 16),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyComments() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No comments yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your thoughts!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_replyingTo != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.reply,
                    size: 16,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to ${_replyingTo!.username}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _replyingTo = null),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: _replyingTo != null
                        ? 'Write a reply...'
                        : 'Write a comment...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  onChanged: (value) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _commentController.text.trim().isNotEmpty
                    ? _sendComment
                    : null,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: _commentController.text.trim().isNotEmpty
                        ? const LinearGradient(
                            colors: [AppTheme.primaryGreen, Color(0xFF00C896)],
                          )
                        : null,
                    color: _commentController.text.trim().isEmpty
                        ? Colors.grey[300]
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: _commentController.text.trim().isNotEmpty
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryGreen.withOpacity(0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleCommentLike(PlantComment comment) {
    setState(() {
      comment.isLiked = !comment.isLiked;
      if (comment.isLiked) {
        comment.likeCount++;
      } else {
        comment.likeCount--;
      }
    });
  }

  void _replyToComment(PlantComment comment) {
    setState(() {
      _replyingTo = comment;
    });
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _showAllComments() {
    Get.bottomSheet(
      _AllCommentsBottomSheet(
        comments: _comments,
        onSendComment: _sendComment,
        onToggleLike: _toggleCommentLike,
        onReply: _replyToComment,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryGreen, Color(0xFF00C896)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {},
                    child: const Center(
                      child: Text(
                        'Add to My Garden',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {},
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppTheme.primaryPurple,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 评论项组件
class _CommentItem extends StatelessWidget {
  final PlantComment comment;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final Function(PlantComment) onReplyToReply;

  const _CommentItem({
    Key? key,
    required this.comment,
    required this.onLike,
    required this.onReply,
    required this.onReplyToReply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryGreen.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: comment.avatarUrl != null
                      ? NetworkImage(comment.avatarUrl!)
                      : null,
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                  child: comment.avatarUrl == null
                      ? Text(
                          comment.username[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                comment.username,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF122017),
                                ),
                              ),
                              Text(
                                _formatTime(comment.postedAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            comment.content,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF374151),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: onLike,
                          child: Row(
                            children: [
                              Icon(
                                comment.isLiked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 18,
                                color: comment.isLiked
                                    ? Colors.red
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                comment.likeCount.toString(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: comment.isLiked
                                      ? Colors.red
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: onReply,
                          child: Row(
                            children: [
                              Icon(
                                Icons.reply_rounded,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Reply',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.replies != null && comment.replies!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 52, top: 12),
              child: Column(
                children: comment.replies!
                    .map((reply) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CommentReplyItem(
                            comment: reply,
                            onLike: () {
                              reply.isLiked = !reply.isLiked;
                              if (reply.isLiked) {
                                reply.likeCount++;
                              } else {
                                reply.likeCount--;
                              }
                            },
                            onReply: () => onReplyToReply(reply),
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// 回复评论项组件
class _CommentReplyItem extends StatelessWidget {
  final PlantComment comment;
  final VoidCallback onLike;
  final VoidCallback onReply;

  const _CommentReplyItem({
    Key? key,
    required this.comment,
    required this.onLike,
    required this.onReply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: comment.avatarUrl != null
              ? NetworkImage(comment.avatarUrl!)
              : null,
          backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
          child: comment.avatarUrl == null
              ? Text(
                  comment.username[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          comment.username,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF122017),
                          ),
                        ),
                        Text(
                          _formatTime(comment.postedAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.content,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF374151),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  GestureDetector(
                    onTap: onLike,
                    child: Row(
                      children: [
                        Icon(
                          comment.isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 16,
                          color: comment.isLiked ? Colors.red : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          comment.likeCount.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: comment.isLiked ? Colors.red : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: onReply,
                    child: Row(
                      children: [
                        Icon(
                          Icons.reply_rounded,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Reply',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

/// 所有评论底部弹窗
class _AllCommentsBottomSheet extends StatefulWidget {
  final List<PlantComment> comments;
  final VoidCallback onSendComment;
  final Function(PlantComment) onToggleLike;
  final Function(PlantComment) onReply;

  const _AllCommentsBottomSheet({
    Key? key,
    required this.comments,
    required this.onSendComment,
    required this.onToggleLike,
    required this.onReply,
  }) : super(key: key);

  @override
  State<_AllCommentsBottomSheet> createState() =>
      _AllCommentsBottomSheetState();
}

class _AllCommentsBottomSheetState extends State<_AllCommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  PlantComment? _replyingTo;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: widget.comments.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.comments.length,
                    itemBuilder: (context, index) {
                      return _CommentItem(
                        comment: widget.comments[index],
                        onLike: () =>
                            widget.onToggleLike(widget.comments[index]),
                        onReply: () {
                          setState(() {
                            _replyingTo = widget.comments[index];
                          });
                          widget.onReply(widget.comments[index]);
                        },
                        onReplyToReply: (reply) {
                          setState(() {
                            _replyingTo = reply;
                          });
                          widget.onReply(reply);
                        },
                      );
                    },
                  ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40),
              Text(
                'All Comments (${widget.comments.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF122017),
                ),
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF6B7280),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 40,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No comments yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF122017),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_replyingTo != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.reply,
                      size: 16,
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Replying to ${_replyingTo!.username}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _replyingTo = null),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: _replyingTo != null
                            ? 'Write a reply...'
                            : 'Write a comment...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _commentController.text.trim().isNotEmpty
                      ? widget.onSendComment
                      : null,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: _commentController.text.trim().isNotEmpty
                          ? const LinearGradient(
                              colors: [AppTheme.primaryGreen, Color(0xFF00C896)],
                            )
                          : null,
                      color: _commentController.text.trim().isEmpty
                          ? Colors.grey[300]
                          : null,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: _commentController.text.trim().isNotEmpty
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryGreen.withOpacity(0.3),
                                offset: const Offset(0, 4),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
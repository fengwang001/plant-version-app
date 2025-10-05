// lib/presentation/pages/community_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'create_post_page.dart';

/// 社区帖子模型
class CommunityPost {
  final String id;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String? imageUrl;
  final String? videoUrl;
  final bool isVideo;
  int likeCount;
  int bookmarkCount;
  int commentCount;
  final int viewCount;
  final DateTime postedAt;
  bool isLiked;
  bool isBookmarked;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.imageUrl,
    this.videoUrl,
    this.isVideo = false,
    required this.likeCount,
    required this.bookmarkCount,
    required this.commentCount,
    required this.viewCount,
    required this.postedAt,
    this.isLiked = false,
    this.isBookmarked = false,
  });
}

/// 评论模型
class Comment {
  final String id;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String content;
  int likeCount;
  final DateTime postedAt;
  bool isLiked;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.content,
    required this.likeCount,
    required this.postedAt,
    this.isLiked = false,
  });
}

/// 社区控制器
class CommunityController extends GetxController {
  final RxList<CommunityPost> posts = <CommunityPost>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _loadPosts();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= 
        scrollController.position.maxScrollExtent - 200) {
      _loadMorePosts();
    }
  }

  /// 加载帖子
  Future<void> _loadPosts() async {
    if (isLoading.value) return;
    
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 800));
      posts.value = _getMockPosts();
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载更多帖子
  Future<void> _loadMorePosts() async {
    if (isLoadingMore.value || posts.length >= 10) return;
    
    try {
      isLoadingMore.value = true;
      await Future.delayed(const Duration(milliseconds: 500));
      posts.addAll(_getMockPosts().take(2));
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 刷新
  Future<void> refresh() async {
    await _loadPosts();
  }

  /// 点赞
  void toggleLike(CommunityPost post) {
    final index = posts.indexWhere((p) => p.id == post.id);
    if (index != -1) {
      posts[index].isLiked = !posts[index].isLiked;
      if (posts[index].isLiked) {
        posts[index].likeCount++;
      } else {
        posts[index].likeCount--;
      }
      posts.refresh();
    }
  }

  /// 收藏
  void toggleBookmark(CommunityPost post) {
    final index = posts.indexWhere((p) => p.id == post.id);
    if (index != -1) {
      posts[index].isBookmarked = !posts[index].isBookmarked;
      if (posts[index].isBookmarked) {
        posts[index].bookmarkCount++;
      } else {
        posts[index].bookmarkCount--;
      }
      posts.refresh();
    }
  }

  /// 分享
  void share(CommunityPost post) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -4),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Share Post',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF122017),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.link_rounded,
                  label: 'Copy Link',
                  color: AppTheme.primaryPurple,
                ),
                _buildShareOption(
                  icon: Icons.message_rounded,
                  label: 'Message',
                  color: Colors.blue,
                ),
                _buildShareOption(
                  icon: Icons.more_horiz_rounded,
                  label: 'More',
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 显示评论
  void showComments(CommunityPost post) {
    Get.bottomSheet(
      _CommentsBottomSheet(post: post),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// 发布帖子
  void publishPost() {
    Get.to(
      () => const CreatePostPage(),
      transition: Transition.upToDown,
      duration: const Duration(milliseconds: 300),
    );
  }

  /// 模拟数据
  List<CommunityPost> _getMockPosts() {
    return [
      CommunityPost(
        id: '1',
        userId: 'user1',
        username: 'Sophia Chen',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sophia',
        imageUrl: 'https://images.unsplash.com/photo-1466781783364-36c955e42a7f?w=400',
        videoUrl: null,
        isVideo: false,
        likeCount: 234,
        bookmarkCount: 45,
        commentCount: 12,
        viewCount: 1289,
        postedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CommunityPost(
        id: '2',
        userId: 'user2',
        username: 'Ethan Park',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Ethan',
        imageUrl: 'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=400',
        videoUrl: null,
        isVideo: false,
        likeCount: 567,
        bookmarkCount: 89,
        commentCount: 23,
        viewCount: 2345,
        postedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      CommunityPost(
        id: '3',
        userId: 'user3',
        username: 'Oliver Kim',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Oliver',
        imageUrl: 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?w=400',
        videoUrl: null,
        isVideo: true,
        likeCount: 891,
        bookmarkCount: 156,
        commentCount: 45,
        viewCount: 3456,
        postedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}

/// 社区页面
class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key, this.animationController});

  final AnimationController? animationController;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CommunityController());
    
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.posts.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                      strokeWidth: 3,
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  color: AppTheme.primaryGreen,
                  backgroundColor: Colors.white,
                  child: CustomScrollView(
                    controller: controller.scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _PostCard(
                              post: controller.posts[index],
                              controller: controller,
                              index: index,
                            );
                          },
                          childCount: controller.posts.length,
                        ),
                      ),
                      if (controller.isLoadingMore.value)
                        SliverToBoxAdapter(
                          child: _buildLoadingMore(),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(CommunityController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),
          const Text(
            'Community',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF122017),
              letterSpacing: -0.5,
            ),
          ),
          GestureDetector(
            onTap: controller.publishPost,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGreen, Color(0xFF00C896)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMore() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: AppTheme.primaryGreen,
                  strokeWidth: 2.5,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Loading more...',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 帖子卡片
class _PostCard extends StatefulWidget {
  final CommunityPost post;
  final CommunityController controller;
  final int index;

  const _PostCard({
    required this.post,
    required this.controller,
    required this.index,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        setState(() => _isVisible = true);
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _isVisible ? Offset.zero : const Offset(0, 0.1),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                offset: const Offset(0, 4),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfo(),
              _buildContent(),
              _buildActions(),
              if (widget.post.commentCount > 0) _buildCommentsPreview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryGreen.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundImage: widget.post.avatarUrl != null
                  ? NetworkImage(widget.post.avatarUrl!)
                  : null,
              backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
              child: widget.post.avatarUrl == null
                  ? Text(
                      widget.post.username[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
                Text(
                  widget.post.username,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF122017),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(widget.post.postedAt),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 14,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatCount(widget.post.viewCount),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return GestureDetector(
      onTap: _navigateToDetail,
      child: Hero(
        tag: 'post_${widget.post.id}',
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: widget.post.isVideo ? 16 / 9 : 1,
                  child: Container(
                    color: Colors.grey[100],
                    child: widget.post.imageUrl != null
                        ? Image.network(
                            widget.post.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          ),
                  ),
                ),
                if (widget.post.isVideo)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.3),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
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
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToDetail() {
    // 导航到植物详情页
    // 这里假设你有一个 PlantDetailPage，你需要根据实际情况调整
    Get.snackbar(
      'Plant Details',
      'Navigating to plant detail page...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.primaryGreen.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.spa_outlined, color: Colors.white),
    );
    
    // 取消注释并根据你的路由配置调整
    // Get.to(
    //   () => PlantDetailPage(
    //     plantId: widget.post.id,
    //     heroTag: 'post_${widget.post.id}',
    //   ),
    //   transition: Transition.fadeIn,
    //   duration: const Duration(milliseconds: 300),
    // );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildActionButton(
            icon: widget.post.isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            label: _formatCount(widget.post.likeCount),
            color: widget.post.isLiked ? Colors.red : const Color(0xFF6B7280),
            onTap: () => widget.controller.toggleLike(widget.post),
          ),
          const SizedBox(width: 20),
          _buildActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: _formatCount(widget.post.commentCount),
            color: const Color(0xFF6B7280),
            onTap: () => widget.controller.showComments(widget.post),
          ),
          const SizedBox(width: 20),
          _buildActionButton(
            icon: widget.post.isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            label: _formatCount(widget.post.bookmarkCount),
            color: widget.post.isBookmarked
                ? AppTheme.primaryGreen
                : const Color(0xFF6B7280),
            onTap: () => widget.controller.toggleBookmark(widget.post),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => widget.controller.share(widget.post),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.share_outlined,
                size: 20,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsPreview() {
    return GestureDetector(
      onTap: () => widget.controller.showComments(widget.post),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: Row(
          children: [
            Text(
              'View all ${widget.post.commentCount} comments',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey[400],
            ),
          ],
        ),
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

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

/// 评论底部弹窗
class _CommentsBottomSheet extends StatefulWidget {
  final CommunityPost post;

  const _CommentsBottomSheet({required this.post});

  @override
  State<_CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<_CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final List<Comment> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _comments.addAll(_getMockComments());
        _isLoading = false;
      });
    }
  }

  List<Comment> _getMockComments() {
    return [
      Comment(
        id: '1',
        userId: 'user3',
        username: 'Liam Wilson',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Liam',
        content: "Beautiful plant! What's the species?",
        likeCount: 5,
        postedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Comment(
        id: '2',
        userId: 'user4',
        username: 'Olivia Martinez',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Olivia',
        content: 'Looks like a Monstera Deliciosa. I have one too! 🌿',
        likeCount: 3,
        postedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  void _sendComment() {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = Comment(
      id: DateTime.now().toString(),
      userId: 'current_user',
      username: 'You',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=You',
      content: _commentController.text.trim(),
      likeCount: 0,
      postedAt: DateTime.now(),
    );

    setState(() {
      _comments.insert(0, newComment);
      _commentController.clear();
    });

    widget.post.commentCount++;
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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                  )
                : _buildCommentsList(),
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
              const Text(
                'Comments',
                style: TextStyle(
                  fontSize: 20,
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

  Widget _buildCommentsList() {
    if (_comments.isEmpty) {
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
              'Be the first to share your thoughts!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        return _CommentItem(
          comment: _comments[index],
          index: index,
        );
      },
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
        child: Row(
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
                    hintText: 'Write a comment...',
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
                  ? _sendComment
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
      ),
    );
  }
}

/// 评论项
class _CommentItem extends StatefulWidget {
  final Comment comment;
  final int index;

  const _CommentItem({
    required this.comment,
    required this.index,
  });

  @override
  State<_CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<_CommentItem> {
  bool _isLiked = false;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.comment.isLiked;
    
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        setState(() => _isVisible = true);
      }
    });
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        widget.comment.likeCount++;
      } else {
        widget.comment.likeCount--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _isVisible ? Offset.zero : const Offset(0, 0.1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
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
                  backgroundImage: widget.comment.avatarUrl != null
                      ? NetworkImage(widget.comment.avatarUrl!)
                      : null,
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                  child: widget.comment.avatarUrl == null
                      ? Text(
                          widget.comment.username[0].toUpperCase(),
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
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.comment.username,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF122017),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.comment.content,
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
                        Text(
                          _formatTime(widget.comment.postedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: _toggleLike,
                          child: Row(
                            children: [
                              Icon(
                                _isLiked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 16,
                                color: _isLiked ? Colors.red : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.comment.likeCount.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _isLiked ? Colors.red : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
      return 'Just now';
    }
  }
}
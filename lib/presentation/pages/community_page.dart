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
      // 更新点赞数
      if (posts[index].isLiked) {
        posts[index] = CommunityPost(
          id: posts[index].id,
          userId: posts[index].userId,
          username: posts[index].username,
          avatarUrl: posts[index].avatarUrl,
          imageUrl: posts[index].imageUrl,
          videoUrl: posts[index].videoUrl,
          isVideo: posts[index].isVideo,
          likeCount: posts[index].likeCount + 1,
          bookmarkCount: posts[index].bookmarkCount,
          commentCount: posts[index].commentCount,
          viewCount: posts[index].viewCount,
          postedAt: posts[index].postedAt,
          isLiked: true,
          isBookmarked: posts[index].isBookmarked,
        );
        
        // 显示点赞成功提示
        Get.snackbar(
          '已点赞',
          '你赞了这个帖子',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
          margin: const EdgeInsets.all(8),
          icon: const Icon(Icons.favorite, color: Colors.white),
        );
      } else {
        posts[index] = CommunityPost(
          id: posts[index].id,
          userId: posts[index].userId,
          username: posts[index].username,
          avatarUrl: posts[index].avatarUrl,
          imageUrl: posts[index].imageUrl,
          videoUrl: posts[index].videoUrl,
          isVideo: posts[index].isVideo,
          likeCount: posts[index].likeCount - 1,
          bookmarkCount: posts[index].bookmarkCount,
          commentCount: posts[index].commentCount,
          viewCount: posts[index].viewCount,
          postedAt: posts[index].postedAt,
          isLiked: false,
          isBookmarked: posts[index].isBookmarked,
        );
      }
      posts.refresh();
    }
  }

  /// 收藏
  void toggleBookmark(CommunityPost post) {
    final index = posts.indexWhere((p) => p.id == post.id);
    if (index != -1) {
      posts[index].isBookmarked = !posts[index].isBookmarked;
      // 更新收藏数
      if (posts[index].isBookmarked) {
        posts[index] = CommunityPost(
          id: posts[index].id,
          userId: posts[index].userId,
          username: posts[index].username,
          avatarUrl: posts[index].avatarUrl,
          imageUrl: posts[index].imageUrl,
          videoUrl: posts[index].videoUrl,
          isVideo: posts[index].isVideo,
          likeCount: posts[index].likeCount,
          bookmarkCount: posts[index].bookmarkCount + 1,
          commentCount: posts[index].commentCount,
          viewCount: posts[index].viewCount,
          postedAt: posts[index].postedAt,
          isLiked: posts[index].isLiked,
          isBookmarked: true,
        );
        
        // 显示收藏成功提示
        Get.snackbar(
          '已收藏',
          '已添加到你的收藏夹',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppTheme.primaryGreen.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
          margin: const EdgeInsets.all(8),
          icon: const Icon(Icons.bookmark, color: Colors.white),
        );
      } else {
        posts[index] = CommunityPost(
          id: posts[index].id,
          userId: posts[index].userId,
          username: posts[index].username,
          avatarUrl: posts[index].avatarUrl,
          imageUrl: posts[index].imageUrl,
          videoUrl: posts[index].videoUrl,
          isVideo: posts[index].isVideo,
          likeCount: posts[index].likeCount,
          bookmarkCount: posts[index].bookmarkCount - 1,
          commentCount: posts[index].commentCount,
          viewCount: posts[index].viewCount,
          postedAt: posts[index].postedAt,
          isLiked: posts[index].isLiked,
          isBookmarked: false,
        );
        
        // 显示取消收藏提示
        Get.snackbar(
          '已取消收藏',
          '已从收藏夹中移除',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.grey.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
          margin: const EdgeInsets.all(8),
        );
      }
      posts.refresh();
    }
  }

  /// 分享
  void share(CommunityPost post) {
    // 模拟分享功能
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示器
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '分享到',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF122017),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.link_rounded,
                  label: '复制链接',
                  color: AppTheme.primaryPurple,
                  onTap: () {
                    Get.back();
                    Get.snackbar(
                      '链接已复制',
                      '帖子链接已复制到剪贴板',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppTheme.primaryGreen.withOpacity(0.8),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                    );
                  },
                ),
                _buildShareOption(
                  icon: Icons.message_rounded,
                  label: '消息',
                  color: Colors.blue,
                  onTap: () {
                    Get.back();
                    Get.snackbar(
                      '功能开发中',
                      '即将支持分享到消息',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                _buildShareOption(
                  icon: Icons.more_horiz_rounded,
                  label: '更多',
                  color: Colors.grey,
                  onTap: () {
                    Get.back();
                    Get.snackbar(
                      '功能开发中',
                      '更多分享选项即将推出',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
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
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
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
    // 使用无CORS限制的头像服务
    return [
      CommunityPost(
        id: '1',
        userId: 'user1',
        username: 'Sophia',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sophia',
        imageUrl: 'https://images.unsplash.com/photo-1466781783364-36c955e42a7f?w=400',
        videoUrl: null,
        isVideo: true,
        likeCount: 123,
        bookmarkCount: 45,
        commentCount: 12,
        viewCount: 678,
        postedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CommunityPost(
        id: '2',
        userId: 'user2',
        username: 'Ethan',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Ethan',
        imageUrl: 'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=400',
        videoUrl: null,
        isVideo: false,
        likeCount: 234,
        bookmarkCount: 56,
        commentCount: 0,
        viewCount: 789,
        postedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CommunityPost(
        id: '3',
        userId: 'user3',
        username: 'Oliver',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Oliver',
        imageUrl: 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?w=400',
        videoUrl: null,
        isVideo: false,
        likeCount: 456,
        bookmarkCount: 89,
        commentCount: 23,
        viewCount: 1234,
        postedAt: DateTime.now().subtract(const Duration(days: 5)),
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
            _buildHeader(context, controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.posts.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  color: AppTheme.primaryGreen,
                  backgroundColor: Colors.white,
                  displacement: 40,
                  strokeWidth: 3,
                  child: ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.only(bottom: 80),
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.posts.length + 
                        (controller.isLoadingMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.posts.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeInOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: 0.8 + (value * 0.2),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      offset: const Offset(0, 2),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: AppTheme.primaryGreen,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Loading more posts...',
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
                          ),
                        );
                      }
                      
                      return _PostCard(
                        post: controller.posts[index],
                        controller: controller,
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CommunityController controller) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8F7).withOpacity(0.95),
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
            const SizedBox(width: 40),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: const Text(
                'Community',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF122017),
                ),
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Transform.rotate(
                    angle: (1 - value) * 3.14 * 2,
                    child: child,
                  ),
                );
              },
              child: GestureDetector(
                onTap: controller.publishPost,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryGreen, Color(0xFF00D2A4)],
                    ),
                    borderRadius: BorderRadius.circular(12),
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

/// 帖子卡片
class _PostCard extends StatefulWidget {
  final CommunityPost post;
  final CommunityController controller;

  const _PostCard({
    required this.post,
    required this.controller,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLikeAnimating = false;
  bool _isBookmarkAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: const BoxDecoration(
            color: Color(0xFFF6F8F7),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfo(),
              _buildContent(),
              _buildActions(),
              _buildCommentsButton(),
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
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Transform.rotate(
                  angle: (1 - value) * 0.5,
                  child: child,
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.2),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundImage: widget.post.avatarUrl != null
                    ? NetworkImage(widget.post.avatarUrl!)
                    : null,
                backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
                child: widget.post.avatarUrl == null
                    ? Text(
                        widget.post.username[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(-20 * (1 - value), 0),
                    child: child,
                  ),
                );
              },
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
                  Text(
                    _formatTime(widget.post.postedAt),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Hero(
      tag: 'post_${widget.post.id}',
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: widget.post.isVideo ? 16 / 9 : 4 / 3,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[200],
              ),
              clipBehavior: Clip.hardEdge,
              child: widget.post.imageUrl != null
                  ? TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: 0.95 + (value * 0.05),
                            child: child,
                          ),
                        );
                      },
                      child: Image.network(
                        widget.post.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
          if (widget.post.isVideo)
            Positioned.fill(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildActionButton(
                icon: widget.post.isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: widget.post.likeCount.toString(),
                color: widget.post.isLiked ? Colors.red : null,
                onTap: _handleLike,
                isAnimating: _isLikeAnimating,
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: widget.post.isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                label: widget.post.bookmarkCount.toString(),
                color: widget.post.isBookmarked ? AppTheme.primaryGreen : null,
                onTap: _handleBookmark,
                isAnimating: _isBookmarkAnimating,
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: () => widget.controller.share(widget.post),
              ),
            ],
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.8 + (value * 0.2),
                  child: child,
                ),
              );
            },
            child: Row(
              children: [
                const Icon(
                  Icons.visibility_outlined,
                  size: 20,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.post.viewCount.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleLike() {
    setState(() {
      _isLikeAnimating = true;
    });
    
    widget.controller.toggleLike(widget.post);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLikeAnimating = false;
        });
      }
    });
  }

  void _handleBookmark() {
    setState(() {
      _isBookmarkAnimating = true;
    });
    
    widget.controller.toggleBookmark(widget.post);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isBookmarkAnimating = false;
        });
      }
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
    bool isAnimating = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: isAnimating ? 1.3 : 1.0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        onEnd: () {
          if (isAnimating && mounted) {
            setState(() {});
          }
        },
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: Icon(
                    icon,
                    size: 24,
                    color: color ?? const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color ?? const Color(0xFF6B7280),
                  ),
                  child: Text(label),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentsButton() {
    if (widget.post.commentCount == 0) {
      return GestureDetector(
        onTap: () => widget.controller.showComments(widget.post),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
          ),
          child: const Text(
            'Add a comment...',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => widget.controller.showComments(widget.post),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
        child: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(-10 * (1 - value), 0),
                    child: child,
                  ),
                );
              },
              child: Text(
                '${widget.post.commentCount} comments... Add a comment',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
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
}

/// 评论底部弹窗
class _CommentsBottomSheet extends StatefulWidget {
  final CommunityPost post;

  const _CommentsBottomSheet({required this.post});

  @override
  State<_CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<_CommentsBottomSheet> 
    with SingleTickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final List<Comment> _comments = [];
  bool _isLoading = true;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _slideController.forward();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _comments.addAll(_getMockComments());
        _isLoading = false;
      });
    }
  }

  List<Comment> _getMockComments() {
    // 使用无CORS限制的头像服务
    return [
      Comment(
        id: '1',
        userId: 'user3',
        username: 'Liam',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Liam',
        content: "Beautiful plant! What's the species?",
        likeCount: 5,
        postedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Comment(
        id: '2',
        userId: 'user4',
        username: 'Olivia',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Olivia',
        content: 'Looks like a Monstera Deliciosa. I have one too!',
        likeCount: 3,
        postedAt: DateTime.now().subtract(const Duration(days: 1)),
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

    // 更新帖子的评论数
    widget.post.commentCount++;

    Get.snackbar(
      '评论成功',
      '您的评论已发布',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppTheme.primaryGreen.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(8),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFFF6F8F7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 32),
          const Text(
            'Comments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF122017),
            ),
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(
              Icons.close_rounded,
              color: Color(0xFF6B7280),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    if (_comments.isEmpty) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.9 + (value * 0.1),
              child: child,
            ),
          );
        },
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 64,
                color: Color(0xFFD1D5DB),
              ),
              SizedBox(height: 16),
              Text(
                'No comments yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Be the first to comment!',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: _CommentItem(comment: _comments[index]),
        );
      },
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFF6F8F7),
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: IconButton(
                icon: const Icon(
                  Icons.emoji_emotions_outlined,
                  color: Color(0xFF6B7280),
                ),
                onPressed: () {},
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: IconButton(
                icon: const Icon(
                  Icons.image_outlined,
                  color: Color(0xFF6B7280),
                ),
                onPressed: () {},
              ),
            ),
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: child,
                    ),
                  );
                },
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Write your comment...',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFE5E7EB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Transform.rotate(
                    angle: (1 - value) * 3.14,
                    child: child,
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: _commentController.text.trim().isNotEmpty
                      ? const LinearGradient(
                          colors: [AppTheme.primaryGreen, Color(0xFF00D2A4)],
                        )
                      : null,
                  color: _commentController.text.trim().isEmpty
                      ? const Color(0xFFD1D5DB)
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _commentController.text.trim().isNotEmpty
                        ? _sendComment
                        : null,
                    child: const Center(
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
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
}

/// 评论项
class _CommentItem extends StatefulWidget {
  final Comment comment;

  const _CommentItem({required this.comment});

  @override
  State<_CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<_CommentItem> with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeScaleAnimation;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.comment.isLiked;
    
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _likeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      // 更新点赞数
      if (_isLiked) {
        widget.comment.likeCount++;
      } else {
        widget.comment.likeCount--;
      }
    });
    _likeAnimationController.forward(from: 0);
    
    // 显示点赞提示（仅在点赞时）
    if (_isLiked) {
      Get.snackbar(
        '',
        '',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(milliseconds: 800),
        margin: const EdgeInsets.all(8),
        messageText: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.favorite, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('已赞', style: TextStyle(color: Colors.white)),
          ],
        ),
        titleText: const SizedBox.shrink(),
        maxWidth: 150,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: CircleAvatar(
              radius: 20,
              backgroundImage: widget.comment.avatarUrl != null
                  ? NetworkImage(widget.comment.avatarUrl!)
                  : null,
              backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
              child: widget.comment.avatarUrl == null
                  ? Text(
                      widget.comment.username[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(12),
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
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Reply',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: _toggleLike,
                      child: AnimatedBuilder(
                        animation: _likeScaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _likeScaleAnimation.value,
                            child: Row(
                              children: [
                                Icon(
                                  _isLiked
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 16,
                                  color: _isLiked
                                      ? Colors.red
                                      : const Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.comment.likeCount.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _isLiked
                                        ? Colors.red
                                        : const Color(0xFF6B7280),
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
              ],
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
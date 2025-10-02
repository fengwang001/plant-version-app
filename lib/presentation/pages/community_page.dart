import 'package:flutter/material.dart';
import 'dart:math' as math;

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _fabController;
  late Animation<double> _headerAnimation;
  late Animation<double> _fabAnimation;
  
  final ScrollController _scrollController = ScrollController();
  bool _isExpanded = true;
  int _selectedTab = 0;

  final List<Post> _posts = [
    Post(
      author: '张三',
      avatar: '🎨',
      time: '2小时前',
      content: '今天参加了一个很棒的Flutter线下活动,学到了很多关于动画的技巧!',
      likes: 128,
      comments: 23,
      images: ['https://picsum.photos/400/300?random=1'],
    ),
    Post(
      author: '李四',
      avatar: '🚀',
      time: '5小时前',
      content: '分享一个我最近开发的项目,用Flutter实现了一个炫酷的粒子动画效果。',
      likes: 256,
      comments: 45,
      images: [
        'https://picsum.photos/400/300?random=2',
        'https://picsum.photos/400/300?random=3',
      ],
    ),
    Post(
      author: '王五',
      avatar: '💡',
      time: '1天前',
      content: 'Flutter 3.0 的新特性真的太强大了!特别是性能优化方面,应用启动速度提升明显。',
      likes: 89,
      comments: 12,
    ),
    Post(
      author: '赵六',
      avatar: '🎯',
      time: '2天前',
      content: '求助:有没有人知道如何在Flutter中实现类似Instagram的故事功能?',
      likes: 34,
      comments: 56,
      images: ['https://picsum.photos/400/300?random=4'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeInOut,
    );
    
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );
    
    _scrollController.addListener(_onScroll);
    _fabController.forward();
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && _isExpanded) {
      setState(() => _isExpanded = false);
      _headerController.forward();
    } else if (_scrollController.offset <= 50 && !_isExpanded) {
      setState(() => _isExpanded = true);
      _headerController.reverse();
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _fabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          _buildTabBar(),
          _buildPostList(),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.deepPurple,
      flexibleSpace: FlexibleSpaceBar(
        title: AnimatedOpacity(
          opacity: _isExpanded ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: const Text('社区'),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple,
                    Colors.deepPurple.shade700,
                    Colors.purple.shade400,
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: BubblePainter(),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              child: AnimatedOpacity(
                opacity: _isExpanded ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '社区',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '发现精彩内容',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
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

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        selectedTab: _selectedTab,
        onTabSelected: (index) {
          setState(() => _selectedTab = index);
        },
      ),
    );
  }

  Widget _buildPostList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _buildPostCard(_posts[index], index);
        },
        childCount: _posts.length,
      ),
    );
  }

  Widget _buildPostCard(Post post, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPostHeader(post),
                _buildPostContent(post),
                if (post.images.isNotEmpty) _buildPostImages(post),
                _buildPostActions(post),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostHeader(Post post) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Hero(
            tag: 'avatar_${post.author}',
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  post.avatar,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.author,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  post.time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent(Post post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        post.content,
        style: const TextStyle(fontSize: 15, height: 1.5),
      ),
    );
  }

  Widget _buildPostImages(Post post) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: post.images.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            width: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[300],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostActions(Post post) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _ActionButton(
            icon: Icons.favorite_border,
            label: post.likes.toString(),
            color: Colors.red,
          ),
          const SizedBox(width: 24),
          _ActionButton(
            icon: Icons.comment_outlined,
            label: post.comments.toString(),
            color: Colors.blue,
          ),
          const SizedBox(width: 24),
          _ActionButton(
            icon: Icons.share_outlined,
            label: '分享',
            color: Colors.green,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.edit),
        label: const Text('发布动态'),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() => _isActive = !_isActive);
        if (_isActive) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.2).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeOut),
              ),
              child: Icon(
                _isActive ? Icons.favorite : widget.icon,
                size: 20,
                color: _isActive ? widget.color : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: TextStyle(
                color: _isActive ? widget.color : Colors.grey[600],
                fontWeight: _isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  _TabBarDelegate({
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _TabItem(
            label: '推荐',
            isSelected: selectedTab == 0,
            onTap: () => onTabSelected(0),
          ),
          _TabItem(
            label: '关注',
            isSelected: selectedTab == 1,
            onTap: () => onTabSelected(1),
          ),
          _TabItem(
            label: '热门',
            isSelected: selectedTab == 2,
            onTap: () => onTabSelected(2),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.deepPurple : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 20 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 30 + 10;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Post {
  final String author;
  final String avatar;
  final String time;
  final String content;
  final int likes;
  final int comments;
  final List<String> images;

  Post({
    required this.author,
    required this.avatar,
    required this.time,
    required this.content,
    required this.likes,
    required this.comments,
    this.images = const [],
  });
}
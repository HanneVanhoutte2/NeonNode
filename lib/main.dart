import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/screens/post_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:project/firebase_options.dart';
import 'package:project/help_functions/theme_provider.dart';
import 'package:project/help_functions/app_colors.dart';
import 'package:project/help_functions/app_text_styles.dart';
import 'package:project/screens/create_post_screen.dart';
import 'package:project/screens/login_screen.dart';
import 'package:project/screens/register_screen.dart';
import 'package:project/screens/search_screen.dart';
import 'package:project/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: themeProvider.themeMode,
      initialRoute: '/login',
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/feed': (context) => const FeedScreen(),
        '/create-post': (context) => const CreatePostScreen(),
        '/search': (context) => const SearchScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _auth = FirebaseAuth.instance;

  void _onAddPost() {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You must be logged in to post',
            style: AppTextStyles.bodyMedium(false),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.pushNamed(context, '/create-post');
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        _onAddPost();
        break;
      case 2:
        Navigator.pushNamed(context, '/search');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark),
      body: Stack(
        children: [
          // Cyberpunk grid background
          if (isDark)
            Positioned.fill(
              child: CustomPaint(
                painter: GridPainter(),
              ),
            ),
          // Light mode subtle gradient
          if (!isDark)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.getBackgroundGradient(isDark),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                // Cyberpunk header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkCard.withValues(alpha: 0.8)
                        : AppColors.lightCard,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.getPrimaryColor(isDark),
                        width: 2,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? AppColors.neonCyanGlow
                            : AppColors.primaryDark.withValues(alpha: 0.2),
                        blurRadius: isDark ? 15 : 10,
                        spreadRadius: isDark ? 1 : 0,
                        offset: isDark ? Offset.zero : const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Logo
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.getPrimaryColor(isDark),
                            width: 2,
                          ),
                        ),
                        child: Image(
                          image: AssetImage(
                              isDark ? 'assets/logo-dark-mode.png' : 'assets/logo-light-mode.png'
                          ),
                          height: 32,
                        ),
                      ),
                      const Spacer(),
                      // Theme toggle
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard
                              : AppColors.accentDark.withValues(alpha: 0.1),
                          border: Border.all(
                            color: AppColors.getSecondaryColor(isDark),
                            width: 2,
                          ),
                          boxShadow: isDark
                              ? [
                            BoxShadow(
                              color: AppColors.neonPinkGlow,
                              blurRadius: 10,
                            ),
                          ]
                              : null,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                          },
                          icon: Icon(
                            isDark ? Icons.wb_sunny : Icons.nightlight_round,
                            color: isDark
                                ? AppColors.accentSecondary
                                : AppColors.secondaryDark,
                          ),
                          tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'ERROR: LOADING POSTS',
                            style: AppTextStyles.systemMessage(isDark).copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(
                                  color: AppColors.getPrimaryColor(isDark),
                                  strokeWidth: 3,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'LOADING...',
                                style: AppTextStyles.systemMessage(isDark),
                              ),
                            ],
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.getAccentColor(isDark),
                                    width: 3,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: isDark
                                      ? [
                                    BoxShadow(
                                      color: AppColors.neonPurpleGlow,
                                      blurRadius: 20,
                                    ),
                                  ]
                                      : null,
                                ),
                                child: Icon(
                                  Icons.post_add,
                                  size: 64,
                                  color: AppColors.getAccentColor(isDark),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'NO POSTS DETECTED',
                                style: AppTextStyles.systemTitle(isDark),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Be the first to upload',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.systemSubtitle(isDark),
                              ),
                            ],
                          ),
                        );
                      }

                      final posts = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index].data() as Map<String, dynamic>;
                          final postId = posts[index].id;
                          final authorId = post['authorId'] ?? '';
                          final text = post['text'] ?? '';
                          final imageUrl = post['imageUrl'] ?? '';
                          final createdAt = post['createdAt'] as Timestamp?;
                          final likeCount = post['likeCount'] ?? 0;
                          final commentCount = post['commentCount'] ?? 0;

                          return PostCard(
                            postId: postId,
                            authorId: authorId,
                            text: text,
                            imageUrl: imageUrl,
                            createdAt: createdAt,
                            likeCount: likeCount,
                            commentCount: commentCount,
                            isDark: isDark,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCard.withValues(alpha: 0.95)
              : AppColors.lightCard,
          border: Border(
            top: BorderSide(
              color: AppColors.getSecondaryColor(isDark),
              width: 2,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? AppColors.neonPinkGlow
                  : AppColors.secondaryDark.withValues(alpha: 0.2),
              blurRadius: isDark ? 15 : 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 0,
          onTap: _onNavTap,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.getPrimaryColor(isDark),
          unselectedItemColor: isDark ? Colors.white54 : Colors.black54,
          selectedLabelStyle: AppTextStyles.navLabel(isDark),
          unselectedLabelStyle: AppTextStyles.caption(isDark).copyWith(
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'FEED',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box),
              label: 'POST',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'SEARCH',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'PROFILE',
            ),
          ],
        ),
      ),
    );
  }
}

// Grid painter for cyberpunk background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gridDark
      ..strokeWidth = 1;

    const gridSize = 40.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PostCard extends StatefulWidget {
  final String authorId;
  final String text;
  final String imageUrl;
  final Timestamp? createdAt;
  final bool isDark;
  final String postId;
  final int likeCount;
  final int commentCount;

  const PostCard({
    required this.authorId,
    required this.text,
    required this.imageUrl,
    required this.createdAt,
    required this.isDark,
    required this.postId,
    required this.likeCount,
    required this.commentCount,
    super.key,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  String _username = '';
  String _avatarUrl = '';
  bool _isLoading = true;
  bool _isLiked = false;
  late int _likeCount;
  late int _commentCount;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.likeCount;
    _commentCount = widget.commentCount;
    _fetchUsername();
    _checkIfLiked();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsername() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.authorId)
          .get();

      if (!mounted) return;

      if (doc.exists) {
        setState(() {
          _username = doc.data()?['displayName'] ?? 'Anonymous';
          _avatarUrl = doc.data()?['avatarUrl'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _username = 'Anonymous';
          _avatarUrl = '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _username = 'Anonymous';
        _avatarUrl = '';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkIfLiked() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final likeDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('likes')
          .doc(currentUser.uid)
          .get();

      if (!mounted) return;

      setState(() {
        _isLiked = likeDoc.exists;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _toggleLike() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _animationController.forward().then((_) {
      if (mounted) {
        _animationController.reverse();
      }
    });

    try {
      final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
      final likeRef = postRef.collection('likes').doc(currentUser.uid);

      if (_isLiked) {
        await likeRef.delete();
        await postRef.update({
          'likeCount': FieldValue.increment(-1),
        });

        if (!mounted) return;

        setState(() {
          _isLiked = false;
          _likeCount--;
        });
      } else {
        await likeRef.set({
          'createdAt': FieldValue.serverTimestamp(),
        });
        await postRef.update({
          'likeCount': FieldValue.increment(1),
        });

        if (!mounted) return;

        setState(() {
          _isLiked = true;
          _likeCount++;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update like',
              style: AppTextStyles.bodyMedium(false),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _navigateToPostDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(
          postId: widget.postId,
          authorId: widget.authorId,
          text: widget.text,
          imageUrl: widget.imageUrl,
          createdAt: widget.createdAt,
          isDark: widget.isDark,
          avatarUrl: _avatarUrl,
        ),
      ),
    );
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return 'NOW';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}D AGO';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}H AGO';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}M AGO';
    } else {
      return 'NOW';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.getPrimaryColor(widget.isDark);
    final secondaryColor = AppColors.getSecondaryColor(widget.isDark);
    final accentColor = AppColors.getAccentColor(widget.isDark);
    final cardBg = AppColors.getCardColor(widget.isDark);
    final bgColor = AppColors.getBackgroundColor(widget.isDark);

    return GestureDetector(
      onTap: _navigateToPostDetail,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        clipBehavior: Clip.none,
        child: Stack(
          children: [
            // Corner accents
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: widget.isDark
                          ? AppColors.cornerAccent1
                          : AppColors.cornerAccent1Light,
                      width: 3,
                    ),
                    left: BorderSide(
                      color: widget.isDark
                          ? AppColors.cornerAccent1
                          : AppColors.cornerAccent1Light,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: widget.isDark
                          ? AppColors.cornerAccent2
                          : AppColors.cornerAccent2Light,
                      width: 3,
                    ),
                    right: BorderSide(
                      color: widget.isDark
                          ? AppColors.cornerAccent2
                          : AppColors.cornerAccent2Light,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),
            // Main card
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border.all(
                  color: primaryColor,
                  width: 2,
                ),
                boxShadow: widget.isDark
                    ? [
                  BoxShadow(
                    color: AppColors.neonCyanGlow,
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColors.neonPinkGlow,
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ]
                    : [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with diagonal cut
                  ClipPath(
                    clipper: DiagonalClipper(),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.getCardGradient(widget.isDark),
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primaryColor,
                                width: 2,
                              ),
                              boxShadow: widget.isDark
                                  ? [
                                BoxShadow(
                                  color: AppColors.neonCyanGlow,
                                  blurRadius: 10,
                                ),
                              ]
                                  : null,
                            ),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: bgColor,
                              backgroundImage: _avatarUrl.isNotEmpty
                                  ? NetworkImage(_avatarUrl)
                                  : null,
                              child: _avatarUrl.isEmpty
                                  ? Text(
                                _isLoading
                                    ? '?'
                                    : _username.isNotEmpty
                                    ? _username.substring(0, 1).toUpperCase()
                                    : 'A',
                                style: AppTextStyles.h4(widget.isDark).copyWith(
                                  fontSize: 20,
                                  color: primaryColor,
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
                                  _isLoading ? 'LOADING...' : _username.toUpperCase(),
                                  style: AppTextStyles.username(widget.isDark),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: secondaryColor,
                                        shape: BoxShape.circle,
                                        boxShadow: widget.isDark
                                            ? [
                                          BoxShadow(
                                            color: AppColors.neonPinkGlow,
                                            blurRadius: 5,
                                          ),
                                        ]
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatTime(widget.createdAt),
                                      style: AppTextStyles.timeFormat(widget.isDark),
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
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.text,
                          style: AppTextStyles.postContent(widget.isDark),
                        ),
                        if (widget.imageUrl.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ClipPath(
                            clipper: ImageClipper(),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: accentColor,
                                  width: 2,
                                ),
                                boxShadow: widget.isDark
                                    ? [
                                  BoxShadow(
                                    color: AppColors.neonPurpleGlow,
                                    blurRadius: 15,
                                  ),
                                ]
                                    : [
                                  BoxShadow(
                                    color: AppColors.accentDark.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Image.network(
                                widget.imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 200,
                                    color: bgColor,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: primaryColor,
                                        strokeWidth: 3,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 200,
                                  color: bgColor,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 48,
                                          color: AppColors.error,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'IMAGE ERROR',
                                          style: AppTextStyles.error(widget.isDark),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Action bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: primaryColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      gradient: LinearGradient(
                        colors: widget.isDark
                            ? [
                          AppColors.darkCard,
                          AppColors.darkBackground.withValues(alpha: 0.5),
                        ]
                            : [
                          Colors.grey.shade50,
                          AppColors.lightCard,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: InkWell(
                            onTap: _toggleLike,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _isLiked
                                      ? secondaryColor
                                      : (widget.isDark ? Colors.white30 : Colors.grey.shade400),
                                  width: 2,
                                ),
                                boxShadow: _isLiked && widget.isDark
                                    ? [
                                  BoxShadow(
                                    color: AppColors.neonPinkGlow,
                                    blurRadius: 10,
                                  ),
                                ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: _isLiked
                                        ? secondaryColor
                                        : (widget.isDark ? Colors.white70 : Colors.black54),
                                    size: 20,
                                    shadows: _isLiked && widget.isDark
                                        ? [
                                      Shadow(
                                        color: AppColors.neonPinkGlow,
                                        blurRadius: 10,
                                      ),
                                    ]
                                        : null,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _likeCount.toString(),
                                    style: AppTextStyles.actionText(
                                      widget.isDark,
                                      isActive: _isLiked,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: _navigateToPostDetail,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: widget.isDark ? Colors.white30 : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.comment,
                                  color: widget.isDark ? Colors.white70 : Colors.black54,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _commentCount.toString(),
                                  style: AppTextStyles.actionText(widget.isDark),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom corner accents
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: widget.isDark
                          ? AppColors.cornerAccent3
                          : AppColors.cornerAccent3Light,
                      width: 3,
                    ),
                    left: BorderSide(
                      color: widget.isDark
                          ? AppColors.cornerAccent3
                          : AppColors.cornerAccent3Light,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: widget.isDark
                          ? AppColors.cornerAccent1
                          : AppColors.cornerAccent1Light,
                      width: 3,
                    ),
                    right: BorderSide(
                      color: widget.isDark
                          ? AppColors.cornerAccent1
                          : AppColors.cornerAccent1Light,
                      width: 3,
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

// Custom clipper for diagonal header
class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 10);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Custom clipper for images
class ImageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width - 15, size.height);
    path.lineTo(size.width, size.height - 15);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

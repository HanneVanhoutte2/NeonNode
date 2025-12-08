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
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: isDark
            ? const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBackground,
              AppColors.darkBackgroundGradient,
            ],
          ),
        )
            : null,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: Row(
                  children: [
                    Image(
                      image: AssetImage(
                          isDark ? 'assets/logo-dark-mode.png' : 'assets/logo-light-mode.png'
                      ),
                      height: 40,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                      },
                      icon: Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                      tooltip: isDark ? 'Light Mode' : 'Dark Mode',
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
                          'Error loading posts',
                          style: AppTextStyles.bodyLarge(isDark),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: isDark ? AppColors.primary : AppColors.primaryDark,
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.post_add,
                              size: 64,
                              color: (isDark ? AppColors.darkText : AppColors.lightText)
                                  .withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No posts yet.\nBe the first to post!',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyLarge(isDark).copyWith(
                                color: (isDark ? AppColors.darkText : AppColors.lightText)
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final posts = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: _onNavTap,
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        selectedItemColor: isDark ? AppColors.primary : AppColors.primaryDark,
        unselectedItemColor: (isDark ? AppColors.darkText : AppColors.lightText)
            .withValues(alpha: 0.5),
        selectedLabelStyle: AppTextStyles.caption(isDark),
        unselectedLabelStyle: AppTextStyles.caption(isDark),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
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
    if (timestamp == null) return 'Just now';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

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

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.isDark
        ? AppColors.darkCard.withValues(alpha: 0.6)
        : AppColors.lightCard.withValues(alpha: 0.6);

    final borderColor = widget.isDark
        ? AppColors.primary.withValues(alpha: 0.5)
        : AppColors.primaryDark.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: _navigateToPostDetail,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (widget.isDark ? AppColors.primary : AppColors.secondary)
                  .withValues(alpha: widget.isDark ? 0.15 : 0.1),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: widget.isDark ? AppColors.secondary : AppColors.secondaryDark,
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
                    style: AppTextStyles.bodyLarge(false).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLoading ? 'Loading...' : _username,
                        style: AppTextStyles.username(widget.isDark),
                      ),
                      Text(
                        _formatTime(widget.createdAt),
                        style: AppTextStyles.timestamp(widget.isDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.text,
              style: AppTextStyles.bodyLarge(widget.isDark),
            ),
            if (widget.imageUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: 1.0,
                  child: Image.network(
                    widget.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            color: widget.isDark ? AppColors.primary : AppColors.primaryDark,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.broken_image, size: 48),
                            const SizedBox(height: 8),
                            Text(
                              'Image not available',
                              style: AppTextStyles.caption(widget.isDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: IconButton(
                    onPressed: _toggleLike,
                    icon: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked
                          ? Colors.red
                          : (widget.isDark ? AppColors.darkText : AppColors.lightText),
                    ),
                    iconSize: 24,
                  ),
                ),
                Text(
                  _likeCount.toString(),
                  style: AppTextStyles.label(widget.isDark),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _navigateToPostDetail,
                  icon: Icon(
                    Icons.comment_outlined,
                    color: widget.isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                  iconSize: 24,
                ),
                Text(
                  _commentCount.toString(),
                  style: AppTextStyles.label(widget.isDark),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

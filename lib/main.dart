import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:project/firebase_options.dart';
import '../help_functions/theme_provider.dart';
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
        const SnackBar(content: Text('You must be logged in to post')),
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
    final backgroundColor = isDark ? const Color(0xFF0A0E1A) : Colors.grey[50]!;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: isDark
            ? const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E1A),
              Color(0xFF050816),
            ],
          ),
        )
            : null,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: Row(
                  children: [
                    const Image(
                      image: AssetImage('assets/logo-color.png'),
                      height: 40,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        Provider.of<ThemeProvider>(context, listen: false)
                            .toggleTheme();
                      },
                      icon: Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                        color: textColor,
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
                          style: TextStyle(color: textColor),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF22E3FF),
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
                              color: textColor.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No posts yet.\nBe the first to post!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.6),
                                fontSize: 16,
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
                        final post =
                        posts[index].data() as Map<String, dynamic>;
                        final authorId = post['authorId'] ?? '';
                        final text = post['text'] ?? '';
                        final imageUrl = post['imageUrl'] ?? '';
                        final createdAt = post['createdAt'] as Timestamp?;

                        return PostCard(
                          authorId: authorId,
                          text: text,
                          imageUrl: imageUrl,
                          createdAt: createdAt,
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
        backgroundColor: isDark ? const Color(0xFF0F1520) : Colors.white,
        selectedItemColor: const Color(0xFF22E3FF),
        unselectedItemColor: isDark
            ? Colors.white.withValues(alpha: 0.5)
            : Colors.black.withValues(alpha: 0.5),
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

  const PostCard({
    required this.authorId,
    required this.text,
    required this.imageUrl,
    required this.createdAt,
    required this.isDark,
    super.key,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String _username = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.authorId)
          .get();

      if (doc.exists) {
        setState(() {
          _username = doc.data()?['username'] ??
              doc.data()?['displayName'] ??
              'Anonymous';
          _isLoading = false;
        });
      } else {
        setState(() {
          _username = 'Anonymous';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _username = 'Anonymous';
        _isLoading = false;
      });
    }
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
        ? const Color(0xFF0F1520).withValues(alpha: 0.6)
        : Colors.white;
    final borderColor = widget.isDark
        ? const Color(0xFF22E3FF).withValues(alpha: 0.3)
        : Colors.grey[300]!;
    final textColor = widget.isDark ? Colors.white : Colors.black87;
    final subtextColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.6)
        : Colors.black.withValues(alpha: 0.6);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22E3FF)
                .withValues(alpha: widget.isDark ? 0.1 : 0.05),
            blurRadius: 10,
            spreadRadius: 1,
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
                backgroundColor: const Color(0xFF8A00C4),
                child: Text(
                  _isLoading
                      ? '?'
                      : _username.isNotEmpty
                      ? _username.substring(0, 1).toUpperCase()
                      : 'A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isLoading ? 'Loading...' : _username,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _formatTime(widget.createdAt),
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.text,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
            ),
          ),
          if (widget.imageUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 48),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

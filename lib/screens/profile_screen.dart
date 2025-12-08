import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../help_functions/theme_provider.dart';
import '../help_functions/app_colors.dart';
import '../help_functions/app_text_styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _displayName = '';
  String _avatarUrl = '';
  bool _isLoading = true;
  int _postCount = 0;
  int _commentCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists && mounted) {
        setState(() {
          _displayName = userDoc.data()?['displayName'] ?? 'User';
          _avatarUrl = userDoc.data()?['avatarUrl'] ?? '';
        });
      }

      final postsQuery = await FirebaseFirestore.instance
          .collection('posts')
          .where('authorId', isEqualTo: currentUser.uid)
          .get();

      int totalComments = 0;
      for (var post in postsQuery.docs) {
        final commentsQuery = await FirebaseFirestore.instance
            .collection('posts')
            .doc(post.id)
            .collection('comments')
            .where('authorId', isEqualTo: currentUser.uid)
            .get();
        totalComments += commentsQuery.docs.length;
      }

      if (mounted) {
        setState(() {
          _postCount = postsQuery.docs.length;
          _commentCount = totalComments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showUserPosts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserPostsScreen(
          userId: FirebaseAuth.instance.currentUser!.uid,
          displayName: _displayName,
        ),
      ),
    );
  }

  void _showUserComments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserCommentsScreen(
          userId: FirebaseAuth.instance.currentUser!.uid,
          displayName: _displayName,
        ),
      ),
    );
  }

  Future<void> _editDisplayName() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final controller = TextEditingController(text: _displayName);
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Edit Display Name',
          style: AppTextStyles.h4(isDark),
        ),
        content: TextField(
          controller: controller,
          style: AppTextStyles.bodyLarge(isDark),
          decoration: InputDecoration(
            hintText: 'Enter new display name',
            hintStyle: AppTextStyles.bodyMedium(isDark).copyWith(
              color: (isDark ? AppColors.darkText : AppColors.lightText)
                  .withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.darkBackground.withValues(alpha: 0.5)
                : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium(isDark).copyWith(
                color: (isDark ? AppColors.darkText : AppColors.lightText)
                    .withValues(alpha: 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty || newName.length < 2) {
                return;
              }

              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
                    .update({
                  'displayName': newName,
                });

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext, true);
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext, false);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.primary : AppColors.primaryDark,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Save',
              style: AppTextStyles.bodyMedium(false).copyWith(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _fetchUserData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Display name updated! 🚀',
              style: AppTextStyles.bodyMedium(false).copyWith(
                color: Colors.black,
              ),
            ),
            backgroundColor: isDark ? AppColors.primary : AppColors.primaryDark,
          ),
        );
      }
    }
  }

  Future<void> _editAvatarUrl() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final controller = TextEditingController(text: _avatarUrl);
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Edit Profile Picture',
          style: AppTextStyles.h4(isDark),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              style: AppTextStyles.bodyLarge(isDark),
              decoration: InputDecoration(
                hintText: 'Enter image URL',
                hintStyle: AppTextStyles.bodyMedium(isDark).copyWith(
                  color: (isDark ? AppColors.darkText : AppColors.lightText)
                      .withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkBackground.withValues(alpha: 0.5)
                    : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Paste a direct link to your profile image',
              style: AppTextStyles.caption(isDark),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium(isDark).copyWith(
                color: (isDark ? AppColors.darkText : AppColors.lightText)
                    .withValues(alpha: 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUrl = controller.text.trim();

              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
                    .update({
                  'avatarUrl': newUrl,
                });

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext, true);
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext, false);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.primary : AppColors.primaryDark,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Save',
              style: AppTextStyles.bodyMedium(false).copyWith(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _fetchUserData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile picture updated! 🚀',
              style: AppTextStyles.bodyMedium(false).copyWith(
                color: Colors.black,
              ),
            ),
            backgroundColor: isDark ? AppColors.primary : AppColors.primaryDark,
          ),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: currentUser.email!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password reset email sent! Check your inbox.',
            style: AppTextStyles.bodyMedium(false).copyWith(
              color: Colors.black,
            ),
          ),
          backgroundColor: isDark ? AppColors.primary : AppColors.primaryDark,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to send password reset email',
            style: AppTextStyles.bodyMedium(false).copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark
        ? AppColors.darkCard.withValues(alpha: 0.6)
        : AppColors.lightCard;
    final borderColor = isDark
        ? (isDark ? AppColors.primary : AppColors.primaryDark).withValues(alpha: 0.5)
        : AppColors.lightBorder;
    final user = FirebaseAuth.instance.currentUser;

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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: isDark ? AppColors.secondary : AppColors.secondaryDark,
                            backgroundImage: _avatarUrl.isNotEmpty
                                ? NetworkImage(_avatarUrl)
                                : null,
                            child: _avatarUrl.isEmpty
                                ? Text(
                              _isLoading
                                  ? '?'
                                  : _displayName.isNotEmpty
                                  ? _displayName.substring(0, 1).toUpperCase()
                                  : 'U',
                              style: AppTextStyles.h1(false).copyWith(
                                color: Colors.white,
                              ),
                            )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _editAvatarUrl,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.primary : AppColors.primaryDark,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: isDark ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLoading ? 'Loading...' : _displayName,
                            style: AppTextStyles.h2(isDark),
                          ),
                          IconButton(
                            onPressed: _editDisplayName,
                            icon: Icon(
                              Icons.edit,
                              size: 20,
                              color: isDark ? AppColors.primary : AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.email ?? 'No email',
                        style: AppTextStyles.subtitle(isDark),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _showUserPosts,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderColor, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isDark ? AppColors.primary : AppColors.primaryDark)
                                          .withValues(alpha: isDark ? 0.15 : 0.1),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      _postCount.toString(),
                                      style: AppTextStyles.h2(isDark).copyWith(
                                        color: isDark ? AppColors.primary : AppColors.primaryDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Posts',
                                      style: AppTextStyles.bodyMedium(isDark),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _showUserComments,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderColor, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isDark ? AppColors.secondary : AppColors.secondaryDark)
                                          .withValues(alpha: isDark ? 0.15 : 0.1),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      _commentCount.toString(),
                                      style: AppTextStyles.h2(isDark).copyWith(
                                        color: isDark ? AppColors.secondary : AppColors.secondaryDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Comments',
                                      style: AppTextStyles.bodyMedium(isDark),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 2),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(
                                Icons.lock,
                                color: isDark ? AppColors.darkText : AppColors.lightText,
                              ),
                              title: Text(
                                'Change Password',
                                style: AppTextStyles.bodyMedium(isDark),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: (isDark ? AppColors.darkText : AppColors.lightText)
                                    .withValues(alpha: 0.5),
                              ),
                              onTap: _changePassword,
                            ),
                            Divider(
                              height: 1,
                              color: borderColor,
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.notifications,
                                color: isDark ? AppColors.darkText : AppColors.lightText,
                              ),
                              title: Text(
                                'Notifications',
                                style: AppTextStyles.bodyMedium(isDark),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: (isDark ? AppColors.darkText : AppColors.lightText)
                                    .withValues(alpha: 0.5),
                              ),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Coming soon!',
                                      style: AppTextStyles.bodyMedium(false).copyWith(
                                        color: Colors.black,
                                      ),
                                    ),
                                    backgroundColor: isDark ? AppColors.primary : AppColors.primaryDark,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          icon: const Icon(Icons.logout),
                          label: Text(
                            'Logout',
                            style: AppTextStyles.button(isDark).copyWith(
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? AppColors.secondary : AppColors.secondaryDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/feed');
              break;
            case 1:
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.pushNamed(context, '/create-post');
              }
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/search');
              break;
            case 3:
              break;
          }
        },
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

class UserPostsScreen extends StatelessWidget {
  final String userId;
  final String displayName;

  const UserPostsScreen({
    required this.userId,
    required this.displayName,
    super.key,
  });

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
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    Text(
                      '$displayName\'s Posts',
                      style: AppTextStyles.h3(isDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .where('authorId', isEqualTo: userId)
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
                              'No posts yet',
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

                        return PostListItem(
                          postId: postId,
                          text: post['text'] ?? '',
                          imageUrl: post['imageUrl'] ?? '',
                          createdAt: post['createdAt'] as Timestamp?,
                          likeCount: post['likeCount'] ?? 0,
                          commentCount: post['commentCount'] ?? 0,
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
    );
  }
}

class PostListItem extends StatelessWidget {
  final String postId;
  final String text;
  final String imageUrl;
  final Timestamp? createdAt;
  final int likeCount;
  final int commentCount;
  final bool isDark;

  const PostListItem({
    required this.postId,
    required this.text,
    required this.imageUrl,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.isDark,
    super.key,
  });

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
    final cardColor = isDark
        ? AppColors.darkCard.withValues(alpha: 0.6)
        : AppColors.lightCard;
    final borderColor = isDark
        ? AppColors.primary.withValues(alpha: 0.5)
        : AppColors.secondary.withValues(alpha: 0.4);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.primary : AppColors.secondary)
                .withValues(alpha: isDark ? 0.15 : 0.1),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: AppTextStyles.bodyLarge(isDark),
          ),
          if (imageUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
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
                          style: AppTextStyles.caption(isDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.favorite,
                size: 16,
                color: (isDark ? AppColors.darkText : AppColors.lightText)
                    .withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                likeCount.toString(),
                style: AppTextStyles.bodySmall(isDark).copyWith(
                  color: (isDark ? AppColors.darkText : AppColors.lightText)
                      .withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.comment,
                size: 16,
                color: (isDark ? AppColors.darkText : AppColors.lightText)
                    .withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                commentCount.toString(),
                style: AppTextStyles.bodySmall(isDark).copyWith(
                  color: (isDark ? AppColors.darkText : AppColors.lightText)
                      .withValues(alpha: 0.6),
                ),
              ),
              const Spacer(),
              Text(
                _formatTime(createdAt),
                style: AppTextStyles.timestamp(isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserCommentsScreen extends StatelessWidget {
  final String userId;
  final String displayName;

  const UserCommentsScreen({
    required this.userId,
    required this.displayName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark
        ? AppColors.darkCard.withValues(alpha: 0.6)
        : AppColors.lightCard;
    final borderColor = isDark
        ? AppColors.primary.withValues(alpha: 0.5)
        : AppColors.secondary.withValues(alpha: 0.4);

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
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    Text(
                      '$displayName\'s Comments',
                      style: AppTextStyles.h3(isDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchUserComments(userId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error,
                              size: 64,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading comments',
                              style: AppTextStyles.bodyLarge(isDark),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              style: AppTextStyles.caption(isDark),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: isDark ? AppColors.primary : AppColors.primaryDark,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading comments...',
                              style: AppTextStyles.bodyMedium(isDark),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.comment,
                              size: 64,
                              color: (isDark ? AppColors.darkText : AppColors.lightText)
                                  .withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No comments yet',
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

                    final comments = snapshot.data!;

                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: (isDark ? AppColors.primary : AppColors.secondary)
                                    .withValues(alpha: isDark ? 0.15 : 0.1),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comment['text'] ?? '',
                                style: AppTextStyles.bodyMedium(isDark),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'On post: ${comment['postPreview'] ?? 'Unknown'}',
                                style: AppTextStyles.caption(isDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (comment['createdAt'] != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(comment['createdAt'] as Timestamp?),
                                  style: AppTextStyles.timestamp(isDark),
                                ),
                              ],
                            ],
                          ),
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

  Future<List<Map<String, dynamic>>> _fetchUserComments(String userId) async {
    try {
      final posts = await FirebaseFirestore.instance.collection('posts').get();
      final List<Map<String, dynamic>> userComments = [];

      for (var post in posts.docs) {
        final postId = post.id;
        final postText = post.data()['text'] ?? '';

        try {
          final comments = await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .collection('comments')
              .where('authorId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

          for (var comment in comments.docs) {
            final commentData = Map<String, dynamic>.from(comment.data());
            commentData['postPreview'] = postText;
            commentData['commentId'] = comment.id;
            commentData['postId'] = postId;
            userComments.add(commentData);
          }
        } catch (e) {
          // Silently continue on error
        }
      }

      userComments.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      return userComments;
    } catch (e) {
      rethrow;
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../help_functions/theme_provider.dart';
import '../help_functions/app_colors.dart';
import '../help_functions/app_text_styles.dart';
import 'user_posts_screen.dart';
import 'user_comments_screen.dart';

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
  final ImagePicker _picker = ImagePicker();

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
      final allPosts = await FirebaseFirestore.instance.collection('posts').get();

      for (var post in allPosts.docs) {
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
    ).then((_) => _fetchUserData());
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
    ).then((_) => _fetchUserData());
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
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(
            color: AppColors.getPrimaryColor(isDark),
            width: 2,
          ),
        ),
        title: Text(
          'EDIT DISPLAY NAME',
          style: AppTextStyles.h4(isDark),
        ),
        content: TextField(
          controller: controller,
          style: AppTextStyles.input(isDark),
          decoration: InputDecoration(
            hintText: 'ENTER NEW NAME',
            hintStyle: AppTextStyles.inputHint(isDark),
            filled: true,
            fillColor: AppColors.getBackgroundColor(isDark).withValues(alpha: 0.5),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0),
              borderSide: BorderSide(
                color: AppColors.getPrimaryColor(isDark).withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0),
              borderSide: BorderSide(
                color: AppColors.getPrimaryColor(isDark),
                width: 2,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'CANCEL',
              style: AppTextStyles.button(isDark).copyWith(
                color: AppColors.getTextColor(isDark),
                fontSize: 14,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.getPrimaryColor(isDark),
                width: 2,
              ),
            ),
            child: TextButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isEmpty || newName.length < 2) return;

                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser.uid)
                      .update({'displayName': newName});

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext, true);
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext, false);
                  }
                }
              },
              child: Text(
                'SAVE',
                style: AppTextStyles.button(isDark).copyWith(
                  color: AppColors.getPrimaryColor(isDark),
                  fontSize: 14,
                ),
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
            content: Text('NAME UPDATED', style: AppTextStyles.success(isDark)),
            backgroundColor: AppColors.darkCard,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
              side: BorderSide(color: AppColors.success, width: 2),
            ),
          ),
        );
      }
    }
  }

  Future<void> _editAvatarUrl() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    // Show image source dialog
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(
            color: AppColors.getSecondaryColor(isDark),
            width: 2,
          ),
        ),
        title: Text(
          'EDIT PROFILE PICTURE',
          style: AppTextStyles.h4(isDark),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: AppColors.getPrimaryColor(isDark),
              ),
              title: Text(
                'Gallery',
                style: AppTextStyles.bodyLarge(isDark),
              ),
              onTap: () => Navigator.pop(dialogContext, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                color: AppColors.getSecondaryColor(isDark),
              ),
              title: Text(
                'Camera',
                style: AppTextStyles.bodyLarge(isDark),
              ),
              onTap: () => Navigator.pop(dialogContext, ImageSource.camera),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, null),
            child: Text(
              'CANCEL',
              style: AppTextStyles.button(isDark).copyWith(
                color: AppColors.getTextColor(isDark),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );

    if (source == null) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final bytes = await imageFile.readAsBytes();
        final base64String = base64Encode(bytes);
        final base64Image = 'data:image/jpeg;base64,$base64String';

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({'profilePicture': base64Image});

        await _fetchUserData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('AVATAR UPDATED', style: AppTextStyles.success(isDark)),
              backgroundColor: AppColors.darkCard,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
                side: BorderSide(color: AppColors.success, width: 2),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('IMAGE UPLOAD FAILED', style: AppTextStyles.error(isDark)),
            backgroundColor: AppColors.darkCard,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
              side: BorderSide(color: AppColors.error, width: 2),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final user = FirebaseAuth.instance.currentUser;

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
          // Light mode gradient
          if (!isDark)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.getBackgroundGradient(isDark),
                ),
              ),
            ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Cyberpunk Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkCard.withValues(alpha: 0.8)
                        : AppColors.lightCard,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.getAccentColor(isDark),
                        width: 2,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? AppColors.neonPurpleGlow
                            : AppColors.accentDark.withValues(alpha: 0.2),
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
                            color: AppColors.getAccentColor(isDark),
                            width: 2,
                          ),
                        ),
                        child: Image(
                          image: AssetImage(
                              isDark ? 'assets/logo-dark-mode.png' : 'assets/logo-light-mode.png'),
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
                            color: AppColors.getPrimaryColor(isDark),
                            width: 2,
                          ),
                          boxShadow: isDark
                              ? [
                            BoxShadow(
                              color: AppColors.neonCyanGlow,
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
                            color: isDark ? AppColors.accentSecondary : AppColors.primaryDark,
                          ),
                          tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Profile Avatar with edit button
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.getSecondaryColor(isDark),
                                  width: 3,
                                ),
                                boxShadow: isDark
                                    ? [
                                  BoxShadow(
                                    color: AppColors.neonPinkGlow,
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ]
                                    : null,
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: AppColors.getBackgroundColor(isDark),
                                backgroundImage:
                                _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                                child: _avatarUrl.isEmpty
                                    ? Text(
                                  _isLoading
                                      ? '?'
                                      : _displayName.isNotEmpty
                                      ? _displayName.substring(0, 1).toUpperCase()
                                      : 'U',
                                  style: AppTextStyles.h1(isDark).copyWith(
                                    color: AppColors.getSecondaryColor(isDark),
                                  ),
                                )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _editAvatarUrl,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.getSecondaryColor(isDark),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.getBackgroundColor(isDark),
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
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: AppColors.darkBackground,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Display Name with edit button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLoading ? 'LOADING...' : _displayName.toUpperCase(),
                              style: AppTextStyles.h2(isDark).copyWith(
                                color: AppColors.getTextColor(isDark),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.getPrimaryColor(isDark),
                                  width: 2,
                                ),
                              ),
                              child: IconButton(
                                onPressed: _editDisplayName,
                                icon: Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: AppColors.getPrimaryColor(isDark),
                                ),
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user?.email ?? 'NO EMAIL',
                          style: AppTextStyles.subtitle(isDark),
                        ),
                        const SizedBox(height: 24),

                        // Stats Cards
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _showUserPosts,
                                child: AspectRatio(
                                  aspectRatio: 1.5,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Corner brackets
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              top: BorderSide(
                                                color: isDark
                                                    ? AppColors.cornerAccent1
                                                    : AppColors.cornerAccent1Light,
                                                width: 2,
                                              ),
                                              left: BorderSide(
                                                color: isDark
                                                    ? AppColors.cornerAccent1
                                                    : AppColors.cornerAccent1Light,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: isDark
                                                    ? AppColors.cornerAccent1
                                                    : AppColors.cornerAccent1Light,
                                                width: 2,
                                              ),
                                              right: BorderSide(
                                                color: isDark
                                                    ? AppColors.cornerAccent1
                                                    : AppColors.cornerAccent1Light,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Main container
                                      Positioned.fill(
                                        child: Container(
                                          margin: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.getCardColor(isDark)
                                                .withValues(alpha: 0.7),
                                            border: Border.all(
                                              color: AppColors.getPrimaryColor(isDark),
                                              width: 2,
                                            ),
                                            boxShadow: isDark
                                                ? [
                                              BoxShadow(
                                                color: AppColors.neonCyanGlow,
                                                blurRadius: 15,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                                : [
                                              BoxShadow(
                                                color: AppColors.primaryDark
                                                    .withValues(alpha: 0.2),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                _postCount.toString(),
                                                style: AppTextStyles.h2(isDark).copyWith(
                                                  color: AppColors.getPrimaryColor(isDark),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'POSTS',
                                                style: AppTextStyles.label(isDark),
                                              ),
                                            ],
                                          ),
                                        ),
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
                                child: AspectRatio(
                                  aspectRatio: 1.5,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Corner brackets
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              top: BorderSide(
                                                color: isDark
                                                    ? AppColors.cornerAccent2
                                                    : AppColors.cornerAccent2Light,
                                                width: 2,
                                              ),
                                              left: BorderSide(
                                                color: isDark
                                                    ? AppColors.cornerAccent2
                                                    : AppColors.cornerAccent2Light,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: isDark
                                                    ? AppColors.cornerAccent2
                                                    : AppColors.cornerAccent2Light,
                                                width: 2,
                                              ),
                                              right: BorderSide(
                                                color: isDark
                                                    ? AppColors.cornerAccent2
                                                    : AppColors.cornerAccent2Light,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Main container
                                      Positioned.fill(
                                        child: Container(
                                          margin: const EdgeInsets.all(6),
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: AppColors.getCardColor(isDark)
                                                .withValues(alpha: 0.7),
                                            border: Border.all(
                                              color: AppColors.getSecondaryColor(isDark),
                                              width: 2,
                                            ),
                                            boxShadow: isDark
                                                ? [
                                              BoxShadow(
                                                color: AppColors.neonPinkGlow,
                                                blurRadius: 15,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                                : [
                                              BoxShadow(
                                                color: AppColors.secondaryDark
                                                    .withValues(alpha: 0.2),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                _commentCount.toString(),
                                                style: AppTextStyles.h2(isDark).copyWith(
                                                  color: AppColors.getSecondaryColor(isDark),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'COMMENTS',
                                                style: AppTextStyles.label(isDark),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            icon: const Icon(Icons.logout),
                            label: Text(
                              'DISCONNECT',
                              style: AppTextStyles.button(isDark).copyWith(
                                color: AppColors.darkBackground,
                                letterSpacing: 2,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: AppColors.darkBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              elevation: 0,
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
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard.withValues(alpha: 0.95) : AppColors.lightCard,
          border: Border(
            top: BorderSide(
              color: AppColors.getAccentColor(isDark),
              width: 2,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? AppColors.neonPurpleGlow
                  : AppColors.accentDark.withValues(alpha: 0.2),
              blurRadius: isDark ? 15 : 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
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
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.getAccentColor(isDark),
          unselectedItemColor: isDark ? Colors.white54 : Colors.black54,
          selectedLabelStyle: AppTextStyles.navLabel(isDark).copyWith(
            color: AppColors.getAccentColor(isDark),
          ),
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

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

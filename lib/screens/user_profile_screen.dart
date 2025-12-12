import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../help_functions/app_colors.dart';
import '../help_functions/app_text_styles.dart';
import '../help_functions/theme_provider.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isFollowing = false;
  int _postCount = 0;
  int _followerCount = 0;
  int _followingCount = 0;

  StreamSubscription<DocumentSnapshot>? _userStreamSubscription;

  @override
  void initState() {
    super.initState();
    _checkFollowingStatus();
    _loadStats();
  }

  @override
  void dispose() {
    _userStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkFollowingStatus() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('followers')
          .doc(currentUserId)
          .get();

      if (mounted) {
        setState(() {
          _isFollowing = doc.exists;
        });
      }
    } catch (e) {
      debugPrint('Error checking follow status: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      // Get post count
      final posts = await FirebaseFirestore.instance
          .collection('posts')
          .where('authorId', isEqualTo: widget.userId)
          .get();

      // Get follower count
      final followers = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('followers')
          .get();

      // Get following count
      final following = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('following')
          .get();

      if (mounted) {
        setState(() {
          _postCount = posts.docs.length;
          _followerCount = followers.docs.length;
          _followingCount = following.docs.length;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  Future<void> _toggleFollow() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      if (_isFollowing) {
        batch.delete(
          FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('followers')
              .doc(currentUserId),
        );
        batch.delete(
          FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .collection('following')
              .doc(widget.userId),
        );

        if (mounted) {
          setState(() {
            _isFollowing = false;
            _followerCount--;
          });
        }
      } else {
        batch.set(
          FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('followers')
              .doc(currentUserId),
          {'timestamp': FieldValue.serverTimestamp()},
        );
        batch.set(
          FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .collection('following')
              .doc(widget.userId),
          {'timestamp': FieldValue.serverTimestamp()},
        );

        if (mounted) {
          setState(() {
            _isFollowing = true;
            _followerCount++;
          });
        }
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error toggling follow: $e');
      _checkFollowingStatus();
      _loadStats();
    }
  }

  // Helper method to build base64 profile picture
  Widget _buildProfilePicture(bool isDark, String? profilePicture) {
    if (profilePicture == null || profilePicture.isEmpty) {
      return Icon(
        Icons.person,
        size: 50,
        color: AppColors.getPrimaryColor(isDark),
      );
    }

    // Check if it's a base64 string
    if (profilePicture.startsWith('data:image')) {
      try {
        final base64Data = profilePicture.split(',').last;
        final bytes = base64Decode(base64Data);
        return ClipOval(
          child: Image.memory(
            bytes,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.person,
                size: 50,
                color: AppColors.getPrimaryColor(isDark),
              );
            },
          ),
        );
      } catch (e) {
        debugPrint('Error decoding base64 profile picture: $e');
        return Icon(
          Icons.person,
          size: 50,
          color: AppColors.getPrimaryColor(isDark),
        );
      }
    }

    // Regular URL image
    return ClipOval(
      child: Image.network(
        profilePicture,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.person,
            size: 50,
            color: AppColors.getPrimaryColor(isDark),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwnProfile = currentUserId == widget.userId;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark),
      body: Stack(
        children: [
          if (isDark)
            Positioned.fill(
              child: CustomPaint(
                painter: GridPainter(),
              ),
            ),
          if (!isDark)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.getBackgroundGradient(isDark),
                ),
              ),
            ),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.getPrimaryColor(isDark),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ERROR LOADING PROFILE',
                        style: AppTextStyles.h2(isDark),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.getPrimaryColor(isDark),
                  ),
                );
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 48,
                        color: AppColors.getPrimaryColor(isDark),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'USER NOT FOUND',
                        style: AppTextStyles.h2(isDark),
                      ),
                    ],
                  ),
                );
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>;

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    backgroundColor: isDark
                        ? AppColors.darkCard.withValues(alpha: 0.8)
                        : AppColors.lightCard,
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppColors.getPrimaryColor(isDark),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(
                      userData['displayName'] ?? 'Unknown',
                      style: AppTextStyles.h3(isDark).copyWith(
                        color: AppColors.getPrimaryColor(isDark),
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard
                              : AppColors.accentDark.withValues(alpha: 0.1),
                          border: Border.all(
                            color: AppColors.getPrimaryColor(isDark),
                            width: 2,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Provider.of<ThemeProvider>(context, listen: false)
                                .toggleTheme();
                          },
                          icon: Icon(
                            isDark ? Icons.wb_sunny : Icons.nightlight_round,
                            color: isDark
                                ? AppColors.accentSecondary
                                : AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 126,
                                height: 126,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                              color: AppColors.getPrimaryColor(isDark),
                                              width: 3,
                                            ),
                                            left: BorderSide(
                                              color: AppColors.getPrimaryColor(isDark),
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
                                              color: AppColors.getSecondaryColor(isDark),
                                              width: 3,
                                            ),
                                            right: BorderSide(
                                              color: AppColors.getSecondaryColor(isDark),
                                              width: 3,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.getPrimaryColor(isDark),
                                            width: 3,
                                          ),
                                          boxShadow: isDark
                                              ? [
                                            BoxShadow(
                                              color: AppColors.neonCyanGlow,
                                              blurRadius: 20,
                                              spreadRadius: 2,
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
                                        child: _buildProfilePicture(
                                          isDark,
                                          userData['profilePicture'],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),

                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStatCard(
                                      isDark,
                                      _postCount.toString(),
                                      'POSTS',
                                      AppColors.cornerAccent1,
                                      AppColors.cornerAccent1Light,
                                    ),
                                    _buildStatCard(
                                      isDark,
                                      _followerCount.toString(),
                                      'FOLLOWERS',
                                      AppColors.cornerAccent2,
                                      AppColors.cornerAccent2Light,
                                    ),
                                    _buildStatCard(
                                      isDark,
                                      _followingCount.toString(),
                                      'FOLLOWING',
                                      AppColors.cornerAccent3,
                                      AppColors.cornerAccent3Light,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (userData['bio'] != null &&
                              userData['bio'].toString().isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.getCardColor(isDark)
                                    .withValues(alpha: 0.5),
                                border: Border.all(
                                  color: AppColors.getPrimaryColor(isDark),
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                userData['bio'],
                                style: AppTextStyles.bodySmall(isDark),
                              ),
                            ),
                          const SizedBox(height: 16),

                          if (!isOwnProfile)
                            GestureDetector(
                              onTap: _toggleFollow,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _isFollowing
                                      ? Colors.transparent
                                      : AppColors.getPrimaryColor(isDark),
                                  border: Border.all(
                                    color: AppColors.getPrimaryColor(isDark),
                                    width: 2,
                                  ),
                                  boxShadow: !_isFollowing && isDark
                                      ? [
                                    BoxShadow(
                                      color: AppColors.neonCyanGlow,
                                      blurRadius: 15,
                                    ),
                                  ]
                                      : null,
                                ),
                                child: Text(
                                  _isFollowing ? 'UNFOLLOW' : 'FOLLOW',
                                  style: AppTextStyles.label(isDark).copyWith(
                                    color: _isFollowing
                                        ? AppColors.getPrimaryColor(isDark)
                                        : (isDark
                                        ? AppColors.darkBackground
                                        : Colors.white),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(bool isDark, String value, String label,
      Color darkColor, Color lightColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.getCardColor(isDark).withValues(alpha: 0.7),
          border: Border.all(
            color: isDark ? darkColor : lightColor,
            width: 2,
          ),
          boxShadow: isDark
              ? [
            BoxShadow(
              color: darkColor.withValues(alpha: 0.5),
              blurRadius: 8,
            ),
          ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.h3(isDark).copyWith(
                color: isDark ? darkColor : lightColor,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.caption(isDark).copyWith(
                fontSize: 8,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

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

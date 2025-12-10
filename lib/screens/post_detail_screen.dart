import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/help_functions/app_colors.dart';
import 'package:project/help_functions/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../help_functions/theme_provider.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final String authorId;
  final String text;
  final String imageUrl;
  final Timestamp? createdAt;
  final bool isDark;
  final String avatarUrl;

  const PostDetailScreen({
    required this.postId,
    required this.authorId,
    required this.text,
    required this.imageUrl,
    required this.createdAt,
    required this.isDark,
    required this.avatarUrl,
    super.key,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  String _username = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  @override
  void dispose() {
    _commentController.dispose();
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
          _isLoading = false;
        });
      } else {
        setState(() {
          _username = 'Anonymous';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _username = 'Anonymous';
        _isLoading = false;
      });
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final postRef =
      FirebaseFirestore.instance.collection('posts').doc(widget.postId);

      await postRef.collection('comments').add({
        'authorId': currentUser.uid,
        'text': _commentController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      await postRef.update({
        'commentCount': FieldValue.increment(1),
      });

      if (!mounted) return;

      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('COMMENT FAILED', style: AppTextStyles.error(widget.isDark)),
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
                      // Back button
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.getPrimaryColor(isDark),
                            width: 2,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            color: AppColors.getPrimaryColor(isDark),
                          ),
                          iconSize: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
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
                            Provider.of<ThemeProvider>(context, listen: false)
                                .toggleTheme();
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

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Post Card with corner brackets
                        Container(
                          clipBehavior: Clip.none,
                          child: Stack(
                            children: [
                              // Corner brackets
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: isDark
                                            ? AppColors.cornerAccent1
                                            : AppColors.cornerAccent1Light,
                                        width: 3,
                                      ),
                                      left: BorderSide(
                                        color: isDark
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
                                        color: isDark
                                            ? AppColors.cornerAccent2
                                            : AppColors.cornerAccent2Light,
                                        width: 3,
                                      ),
                                      right: BorderSide(
                                        color: isDark
                                            ? AppColors.cornerAccent2
                                            : AppColors.cornerAccent2Light,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Main post container
                              Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.getCardColor(isDark).withValues(alpha: 0.7),
                                  border: Border.all(
                                    color: AppColors.getPrimaryColor(isDark),
                                    width: 2,
                                  ),
                                  boxShadow: isDark
                                      ? [
                                    BoxShadow(
                                      color: AppColors.neonCyanGlow,
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                      : [
                                    BoxShadow(
                                      color: AppColors.primaryDark.withValues(alpha: 0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Author info
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
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
                                          child: CircleAvatar(
                                            radius: 22,
                                            backgroundColor: AppColors.getBackgroundColor(isDark),
                                            backgroundImage: widget.avatarUrl.isNotEmpty
                                                ? NetworkImage(widget.avatarUrl)
                                                : null,
                                            child: widget.avatarUrl.isEmpty
                                                ? Text(
                                              _isLoading
                                                  ? '?'
                                                  : _username.substring(0, 1).toUpperCase(),
                                              style: AppTextStyles.h4(isDark).copyWith(
                                                fontSize: 20,
                                                color: AppColors.getPrimaryColor(isDark),
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
                                                style: AppTextStyles.username(isDark),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _formatTime(widget.createdAt),
                                                style: AppTextStyles.timeFormat(isDark),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Post text
                                    Text(
                                      widget.text,
                                      style: AppTextStyles.postContent(isDark),
                                    ),
                                    // Post image
                                    if (widget.imageUrl.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      ClipPath(
                                        clipper: ImageClipper(),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: AppColors.getAccentColor(isDark),
                                              width: 2,
                                            ),
                                            boxShadow: isDark
                                                ? [
                                              BoxShadow(
                                                color: AppColors.neonPurpleGlow,
                                                blurRadius: 15,
                                              ),
                                            ]
                                                : null,
                                          ),
                                          child: Image.network(
                                            widget.imageUrl,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Container(
                                                  height: 200,
                                                  color: AppColors.getBackgroundColor(isDark),
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
                                                          style: AppTextStyles.error(isDark),
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
                              // Bottom corner brackets
                              Positioned(
                                bottom: 0,
                                left: 0,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: isDark
                                            ? AppColors.cornerAccent3
                                            : AppColors.cornerAccent3Light,
                                        width: 3,
                                      ),
                                      left: BorderSide(
                                        color: isDark
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
                                        color: isDark
                                            ? AppColors.cornerAccent1
                                            : AppColors.cornerAccent1Light,
                                        width: 3,
                                      ),
                                      right: BorderSide(
                                        color: isDark
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
                        const SizedBox(height: 24),

                        // Comments section title
                        Text(
                          'COMMENTS',
                          style: AppTextStyles.h4(isDark).copyWith(
                            color: AppColors.getSecondaryColor(isDark),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Comments list
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('posts')
                              .doc(widget.postId)
                              .collection('comments')
                              .orderBy('createdAt', descending: false)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text(
                                'ERROR LOADING COMMENTS',
                                style: AppTextStyles.error(isDark),
                              );
                            }

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.getPrimaryColor(isDark),
                                  strokeWidth: 3,
                                ),
                              );
                            }

                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return Text(
                                'NO COMMENTS. BE THE FIRST.',
                                style: AppTextStyles.systemSubtitle(isDark),
                              );
                            }

                            final comments = snapshot.data!.docs;

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment =
                                comments[index].data() as Map<String, dynamic>;
                                final commentId = comments[index].id;

                                return CommentCard(
                                  commentId: commentId,
                                  postId: widget.postId,
                                  postAuthorId: widget.authorId,
                                  authorId: comment['authorId'] ?? '',
                                  text: comment['text'] ?? '',
                                  createdAt: comment['createdAt'] as Timestamp?,
                                  isDark: isDark,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Comment input
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: AppTextStyles.input(isDark),
                          decoration: InputDecoration(
                            hintText: 'ADD COMMENT...',
                            hintStyle: AppTextStyles.inputHint(isDark),
                            filled: true,
                            fillColor: AppColors.getBackgroundColor(isDark)
                                .withValues(alpha: 0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: BorderSide(
                                color: AppColors.getSecondaryColor(isDark)
                                    .withValues(alpha: 0.5),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: BorderSide(
                                color: AppColors.getSecondaryColor(isDark)
                                    .withValues(alpha: 0.5),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: BorderSide(
                                color: AppColors.getSecondaryColor(isDark),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
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
                          onPressed: _addComment,
                          icon: const Icon(Icons.send),
                          color: AppColors.getSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Grid painter
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

// Image clipper
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
  bool shouldReclip(covariant CustomClipper<Path> oldDelegate) => false;
}

class CommentCard extends StatefulWidget {
  final String commentId;
  final String postId;
  final String postAuthorId;
  final String authorId;
  final String text;
  final Timestamp? createdAt;
  final bool isDark;

  const CommentCard({
    required this.commentId,
    required this.postId,
    required this.postAuthorId,
    required this.authorId,
    required this.text,
    required this.createdAt,
    required this.isDark,
    super.key,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  String _username = '';
  String _avatarUrl = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
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

  Future<void> _deleteComment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        title: Text(
          'DELETE COMMENT?',
          style: AppTextStyles.h4(widget.isDark),
        ),
        content: Text(
          'This action is permanent.',
          style: AppTextStyles.bodyMedium(widget.isDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'CANCEL',
              style: AppTextStyles.button(widget.isDark).copyWith(
                color: AppColors.getTextColor(widget.isDark),
                fontSize: 14,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.error, width: 2),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                'DELETE',
                style: AppTextStyles.button(widget.isDark).copyWith(
                  color: AppColors.error,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .doc(widget.commentId)
            .delete();

        await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update({
          'commentCount': FieldValue.increment(-1),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'COMMENT DELETED',
                style: AppTextStyles.success(widget.isDark),
              ),
              backgroundColor: AppColors.darkCard,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
                side: BorderSide(color: AppColors.success, width: 2),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'DELETE FAILED',
                style: AppTextStyles.error(widget.isDark),
              ),
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
    final currentUser = FirebaseAuth.instance.currentUser;
    final canDelete = currentUser != null &&
        (currentUser.uid == widget.authorId || currentUser.uid == widget.postAuthorId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.getBackgroundColor(widget.isDark).withValues(alpha: 0.3),
        border: Border.all(
          color: AppColors.getAccentColor(widget.isDark).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.getSecondaryColor(widget.isDark),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.getBackgroundColor(widget.isDark),
              backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
              child: _avatarUrl.isEmpty
                  ? Text(
                _isLoading ? '?' : _username.substring(0, 1).toUpperCase(),
                style: AppTextStyles.bodyMedium(widget.isDark).copyWith(
                  color: AppColors.getSecondaryColor(widget.isDark),
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
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            _isLoading ? 'LOADING...' : _username.toUpperCase(),
                            style: AppTextStyles.label(widget.isDark).copyWith(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(widget.createdAt),
                            style: AppTextStyles.timeFormat(widget.isDark).copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (canDelete)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.error, width: 1),
                        ),
                        child: IconButton(
                          onPressed: _deleteComment,
                          icon: const Icon(Icons.delete),
                          color: AppColors.error,
                          iconSize: 16,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          tooltip: 'Delete',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.text,
                  style: AppTextStyles.bodyMedium(widget.isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

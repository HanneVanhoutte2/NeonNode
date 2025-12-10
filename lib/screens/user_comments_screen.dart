import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../help_functions/theme_provider.dart';
import '../help_functions/app_colors.dart';
import '../help_functions/app_text_styles.dart';

class UserCommentsScreen extends StatelessWidget {
  final String userId;
  final String displayName;

  const UserCommentsScreen({
    required this.userId,
    required this.displayName,
    super.key,
  });

  Future<void> _deleteComment(BuildContext context, String postId, String commentId, bool isDark) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        title: Text(
          'DELETE COMMENT?',
          style: AppTextStyles.h4(isDark),
        ),
        content: Text(
          'This action is permanent.',
          style: AppTextStyles.bodyMedium(isDark),
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
              border: Border.all(color: AppColors.error, width: 2),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                'DELETE',
                style: AppTextStyles.button(isDark).copyWith(
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
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .delete();

        await FirebaseFirestore.instance.collection('posts').doc(postId).update({
          'commentCount': FieldValue.increment(-1),
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('COMMENT DELETED', style: AppTextStyles.success(isDark)),
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('DELETE FAILED', style: AppTextStyles.error(isDark)),
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
                            color: AppColors.getSecondaryColor(isDark),
                            width: 2,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            color: AppColors.getSecondaryColor(isDark),
                          ),
                          iconSize: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '${displayName.toUpperCase()}\'S COMMENTS',
                          style: AppTextStyles.h4(isDark).copyWith(
                            color: AppColors.getSecondaryColor(isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Comments List
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchUserComments(userId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.error,
                                width: 3,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: AppColors.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'ERROR LOADING COMMENTS',
                                  style: AppTextStyles.systemMessage(isDark).copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
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
                                  color: AppColors.getSecondaryColor(isDark),
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

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                                  Icons.comment,
                                  size: 64,
                                  color: AppColors.getAccentColor(isDark),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'NO COMMENTS FOUND',
                                style: AppTextStyles.systemTitle(isDark),
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

                          return CommentCard(
                            text: comment['text'] ?? '',
                            postPreview: comment['postPreview'] ?? '',
                            createdAt: comment['createdAt'] as Timestamp?,
                            isDark: isDark,
                            onDelete: () => _deleteComment(
                              context,
                              comment['postId'],
                              comment['commentId'],
                              isDark,
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
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchUserComments(String userId) async {
    try {
      final posts = await FirebaseFirestore.instance.collection('posts').get();
      final List<Map<String, dynamic>> userComments = [];

      for (var post in posts.docs) {
        final postId = post.id;
        final postText = post.data()['text'] ?? '';

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

// Comment Card Widget
class CommentCard extends StatelessWidget {
  final String text;
  final String postPreview;
  final Timestamp? createdAt;
  final bool isDark;
  final VoidCallback onDelete;

  const CommentCard({
    required this.text,
    required this.postPreview,
    required this.createdAt,
    required this.isDark,
    required this.onDelete,
    super.key,
  });

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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.none,
      child: Stack(
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
          Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.getCardColor(isDark).withValues(alpha: 0.7),
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
                  color: AppColors.secondaryDark.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        text,
                        style: AppTextStyles.bodyMedium(isDark),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.error, width: 1),
                      ),
                      child: IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete),
                        color: AppColors.error,
                        tooltip: 'Delete',
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                        iconSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.getAccentColor(isDark).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'ON: ',
                        style: AppTextStyles.label(isDark).copyWith(fontSize: 10),
                      ),
                      Expanded(
                        child: Text(
                          postPreview,
                          style: AppTextStyles.caption(isDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTime(createdAt),
                  style: AppTextStyles.timeFormat(isDark),
                ),
              ],
            ),
          ),
        ],
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

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
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete Comment?',
          style: AppTextStyles.h4(isDark),
        ),
        content: Text(
          'This will permanently delete this comment.',
          style: AppTextStyles.bodyMedium(isDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium(isDark),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Delete',
              style: AppTextStyles.bodyMedium(false).copyWith(
                color: Colors.white,
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
              content: Text(
                'Comment deleted successfully',
                style: AppTextStyles.bodyMedium(false).copyWith(color: Colors.white),
              ),
              backgroundColor: isDark ? AppColors.primary : AppColors.primaryDark,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to delete comment',
                style: AppTextStyles.bodyMedium(false).copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
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

// Widget: Comment Card
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
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
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete),
                color: AppColors.error,
                tooltip: 'Delete comment',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'On: $postPreview',
            style: AppTextStyles.caption(isDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(createdAt),
            style: AppTextStyles.caption(isDark),
          ),
        ],
      ),
    );
  }
}

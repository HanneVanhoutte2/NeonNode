import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../help_functions/theme_provider.dart';
import '../help_functions/app_colors.dart';
import '../help_functions/app_text_styles.dart';

class UserPostsScreen extends StatefulWidget {
  final String userId;
  final String displayName;

  const UserPostsScreen({
    required this.userId,
    required this.displayName,
    super.key,
  });

  @override
  State<UserPostsScreen> createState() => _UserPostsScreenState();
}

class _UserPostsScreenState extends State<UserPostsScreen> {
  int _selectedTab = 0;

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
                      '${widget.displayName}\'s Posts',
                      style: AppTextStyles.h3(isDark),
                    ),
                  ],
                ),
              ),

              // Tab selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0
                                ? (isDark ? AppColors.primary : AppColors.primaryDark)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'My Posts',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium(isDark).copyWith(
                              color: _selectedTab == 0
                                  ? Colors.black
                                  : (isDark ? AppColors.darkText : AppColors.lightText),
                              fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1
                                ? (isDark ? AppColors.secondary : AppColors.secondaryDark)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Comments on Posts',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium(isDark).copyWith(
                              color: _selectedTab == 1
                                  ? Colors.black
                                  : (isDark ? AppColors.darkText : AppColors.lightText),
                              fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: _selectedTab == 0
                    ? _MyPostsList(userId: widget.userId)
                    : _CommentsOnMyPostsList(userId: widget.userId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tab 1: My Posts
class _MyPostsList extends StatelessWidget {
  final String userId;

  const _MyPostsList({required this.userId});

  Future<void> _deletePost(BuildContext context, String postId, bool isDark) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete Post?',
          style: AppTextStyles.h4(isDark),
        ),
        content: Text(
          'This will permanently delete this post and all its comments.',
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
        final comments = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .get();

        final batch = FirebaseFirestore.instance.batch();
        for (var comment in comments.docs) {
          batch.delete(comment.reference);
        }

        batch.delete(FirebaseFirestore.instance.collection('posts').doc(postId));
        await batch.commit();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Post deleted successfully',
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
                'Failed to delete post',
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

    return StreamBuilder<QuerySnapshot>(
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

            return PostCard(
              postId: postId,
              text: post['text'] ?? '',
              imageUrl: post['imageUrl'] ?? '',
              createdAt: post['createdAt'] as Timestamp?,
              likeCount: post['likeCount'] ?? 0,
              commentCount: post['commentCount'] ?? 0,
              isDark: isDark,
              onDelete: () => _deletePost(context, postId, isDark),
            );
          },
        );
      },
    );
  }
}

// Tab 2: Comments on My Posts
class _CommentsOnMyPostsList extends StatelessWidget {
  final String userId;

  const _CommentsOnMyPostsList({required this.userId});

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
          'This will permanently delete this comment from your post.',
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

  Future<List<Map<String, dynamic>>> _fetchCommentsOnMyPosts(String userId) async {
    try {
      final myPosts = await FirebaseFirestore.instance
          .collection('posts')
          .where('authorId', isEqualTo: userId)
          .get();

      final List<Map<String, dynamic>> allComments = [];

      for (var post in myPosts.docs) {
        final postId = post.id;
        final postText = post.data()['text'] ?? '';

        final comments = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .orderBy('createdAt', descending: true)
            .get();

        for (var comment in comments.docs) {
          final commentData = Map<String, dynamic>.from(comment.data());
          commentData['postPreview'] = postText;
          commentData['commentId'] = comment.id;
          commentData['postId'] = postId;

          try {
            final authorDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(commentData['authorId'])
                .get();
            commentData['authorName'] = authorDoc.data()?['displayName'] ?? 'Unknown';
          } catch (e) {
            commentData['authorName'] = 'Unknown';
          }

          allComments.add(commentData);
        }
      }

      allComments.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      return allComments;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchCommentsOnMyPosts(userId),
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
                  'No comments on your posts yet',
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

            return ModerateCommentCard(
              text: comment['text'] ?? '',
              postPreview: comment['postPreview'] ?? '',
              authorName: comment['authorName'] ?? 'Unknown',
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
    );
  }
}

// Widget: Post Card
class PostCard extends StatelessWidget {
  final String postId;
  final String text;
  final String imageUrl;
  final Timestamp? createdAt;
  final int likeCount;
  final int commentCount;
  final bool isDark;
  final VoidCallback onDelete;

  const PostCard({
    required this.postId,
    required this.text,
    required this.imageUrl,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
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
      margin: const EdgeInsets.only(bottom: 16),
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
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete),
                color: AppColors.error,
                tooltip: 'Delete post',
              ),
            ],
          ),
          const SizedBox(height: 8),
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
                style: AppTextStyles.caption(isDark),
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
                style: AppTextStyles.caption(isDark),
              ),
              const Spacer(),
              Text(
                _formatTime(createdAt),
                style: AppTextStyles.caption(isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget: Moderate Comment Card
class ModerateCommentCard extends StatelessWidget {
  final String text;
  final String postPreview;
  final String authorName;
  final Timestamp? createdAt;
  final bool isDark;
  final VoidCallback onDelete;

  const ModerateCommentCard({
    required this.text,
    required this.postPreview,
    required this.authorName,
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
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: (isDark ? AppColors.darkText : AppColors.lightText)
                          .withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      authorName,
                      style: AppTextStyles.bodyMedium(isDark).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(createdAt),
                      style: AppTextStyles.caption(isDark),
                    ),
                  ],
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
            text,
            style: AppTextStyles.bodyMedium(isDark),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkBackground : AppColors.lightBackground)
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.article,
                  size: 14,
                  color: (isDark ? AppColors.darkText : AppColors.lightText)
                      .withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'On: $postPreview',
                    style: AppTextStyles.caption(isDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

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
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '${widget.displayName.toUpperCase()}\'S POSTS',
                          style: AppTextStyles.h4(isDark).copyWith(
                            color: AppColors.getPrimaryColor(isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab selector
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: _selectedTab == 0
                                  ? AppColors.getPrimaryColor(isDark)
                                  : Colors.transparent,
                              border: Border.all(
                                color: AppColors.getPrimaryColor(isDark),
                                width: 2,
                              ),
                              boxShadow: _selectedTab == 0 && isDark
                                  ? [
                                BoxShadow(
                                  color: AppColors.neonCyanGlow,
                                  blurRadius: 15,
                                ),
                              ]
                                  : null,
                            ),
                            child: Text(
                              'MY POSTS',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.button(isDark).copyWith(
                                color: _selectedTab == 0
                                    ? AppColors.darkBackground
                                    : AppColors.getPrimaryColor(isDark),
                                fontSize: 12,
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: _selectedTab == 1
                                  ? AppColors.getSecondaryColor(isDark)
                                  : Colors.transparent,
                              border: Border.all(
                                color: AppColors.getSecondaryColor(isDark),
                                width: 2,
                              ),
                              boxShadow: _selectedTab == 1 && isDark
                                  ? [
                                BoxShadow(
                                  color: AppColors.neonPinkGlow,
                                  blurRadius: 15,
                                ),
                              ]
                                  : null,
                            ),
                            child: Text(
                              'COMMENTS',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.button(isDark).copyWith(
                                color: _selectedTab == 1
                                    ? AppColors.darkBackground
                                    : AppColors.getSecondaryColor(isDark),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _selectedTab == 0
                      ? _MyPostsList(userId: widget.userId)
                      : _CommentsOnMyPostsList(userId: widget.userId),
                ),
              ],
            ),
          ),
        ],
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
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        title: Text(
          'DELETE POST?',
          style: AppTextStyles.h4(isDark),
        ),
        content: Text(
          'This will permanently delete this post and all comments.',
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
              content: Text('POST DELETED', style: AppTextStyles.success(isDark)),
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
              'ERROR LOADING POSTS',
              style: AppTextStyles.error(isDark),
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
                      color: AppColors.getPrimaryColor(isDark),
                      width: 3,
                    ),
                    boxShadow: isDark
                        ? [
                      BoxShadow(
                        color: AppColors.neonCyanGlow,
                        blurRadius: 20,
                      ),
                    ]
                        : null,
                  ),
                  child: Icon(
                    Icons.post_add,
                    size: 64,
                    color: AppColors.getPrimaryColor(isDark),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'NO POSTS FOUND',
                  style: AppTextStyles.systemTitle(isDark),
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
          'This will permanently delete this comment from your post.',
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
            child: Text(
              'ERROR LOADING COMMENTS',
              style: AppTextStyles.error(isDark),
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
                      color: AppColors.getSecondaryColor(isDark),
                      width: 3,
                    ),
                    boxShadow: isDark
                        ? [
                      BoxShadow(
                        color: AppColors.neonPinkGlow,
                        blurRadius: 20,
                      ),
                    ]
                        : null,
                  ),
                  child: Icon(
                    Icons.comment,
                    size: 64,
                    color: AppColors.getSecondaryColor(isDark),
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
          Container(
            margin: const EdgeInsets.all(6),
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
                  spreadRadius: 1,
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
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color: AppColors.getSecondaryColor(isDark),
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
                      color: AppColors.getAccentColor(isDark),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      commentCount.toString(),
                      style: AppTextStyles.caption(isDark),
                    ),
                    const Spacer(),
                    Text(
                      _formatTime(createdAt),
                      style: AppTextStyles.timeFormat(isDark),
                    ),
                  ],
                ),
              ],
            ),
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
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.getSecondaryColor(isDark),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 14,
                              color: AppColors.getSecondaryColor(isDark),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            authorName.toUpperCase(),
                            style: AppTextStyles.label(isDark).copyWith(
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(createdAt),
                            style: AppTextStyles.timeFormat(isDark).copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ],
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
                        iconSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  text,
                  style: AppTextStyles.bodyMedium(isDark),
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

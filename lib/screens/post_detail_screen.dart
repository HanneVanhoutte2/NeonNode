import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          content: Text(
            'Failed to add comment',
            style: AppTextStyles.bodyMedium(widget.isDark)
          ),
          backgroundColor: AppColors.error,
        ),
      );
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
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final cardColor = isDark
        ? AppColors.darkCard.withValues(alpha: 0.6)
        : AppColors.lightCard.withValues(alpha: 0.6);
    final borderColor = isDark
        ? AppColors.primary.withValues(alpha: 0.3)
        : AppColors.primaryDark.withValues(alpha: 0.3);

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
                padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: textColor),
                    ),
                    Image(
                      image: AssetImage(
                          isDark ? 'assets/logo-dark-mode.png' : 'assets/logo-light-mode.png'
                      ),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ?
                              AppColors.primary.withValues(alpha: 0.1 ) :
                              AppColors.primaryDark.withValues(alpha: 0.1 ),
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
                                  backgroundColor: isDark ? AppColors.secondary : AppColors.secondaryDark,
                                  backgroundImage: widget.avatarUrl.isNotEmpty
                                      ? NetworkImage(widget.avatarUrl)
                                      : null,
                                  child: widget.avatarUrl.isEmpty
                                      ? Text(
                                    _isLoading ? '?' : _username.substring(0, 1).toUpperCase(),
                                    style: AppTextStyles.bodyMedium(true),
                                  )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isLoading ? 'Loading...' : _username,
                                        style: AppTextStyles.bodyMedium(isDark),
                                      ),
                                      Text(
                                        _formatTime(widget.createdAt),
                                        style: AppTextStyles.bodySmall(isDark),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.text,
                              style: AppTextStyles.bodyLarge(isDark),
                            ),
                            if (widget.imageUrl.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  widget.imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        height: 200,
                                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.broken_image, size: 48),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Image not available',
                                                style: AppTextStyles.bodySmall(isDark),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Comments',
                        style: AppTextStyles.bodyLarge(isDark),
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
                              'Error loading comments',
                              style: AppTextStyles.bodyMedium(isDark),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: isDark ? AppColors.primary : AppColors.primaryDark,
                              ),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Text(
                              'No comments yet. Be the first to comment!',
                              style: AppTextStyles.bodyMedium(isDark),
                            );
                          }

                          final comments = snapshot.data!.docs;

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index].data()
                              as Map<String, dynamic>;
                              return CommentCard(
                                authorId: comment['authorId'] ?? '',
                                text: comment['text'] ?? '',
                                createdAt: comment['createdAt'] as Timestamp?,
                                isDark: isDark, avatarUrl: widget.avatarUrl,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                  border: Border(
                    top: BorderSide(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        style: GoogleFonts.rammettoOne(
                          color: textColor,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: GoogleFonts.rammettoOne(
                            color: textColor.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkBackground.withValues(alpha: 0.5)
                              : AppColors.lightBackground.withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addComment,
                      icon: const Icon(Icons.send),
                      color: isDark ? AppColors.primary : AppColors.primaryDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommentCard extends StatefulWidget {
  final String authorId;
  final String text;
  final Timestamp? createdAt;
  final bool isDark;
  final String avatarUrl;

  const CommentCard({
    required this.authorId,
    required this.text,
    required this.createdAt,
    required this.isDark,
    required this.avatarUrl,
    super.key,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
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
      if (!mounted) return; // ✅ Check before setState

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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDark
            ? AppColors.darkBackground.withValues(alpha: 0.3)
            : AppColors.lightBackground.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: widget.isDark ? AppColors.secondary : AppColors.secondaryDark,
            backgroundImage: widget.avatarUrl.isNotEmpty
                ? NetworkImage(widget.avatarUrl)
                : null,
            child: widget.avatarUrl.isEmpty
                ? Text(
              _isLoading ? '?' : _username.substring(0, 1).toUpperCase(),
              style: AppTextStyles.bodyMedium(true),
            )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _isLoading ? 'Loading...' : _username,
                      style: AppTextStyles.bodyMedium(widget.isDark),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(widget.createdAt),
                      style: AppTextStyles.bodySmall(widget.isDark),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
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

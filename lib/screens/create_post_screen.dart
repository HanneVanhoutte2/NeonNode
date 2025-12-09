import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/help_functions/app_colors.dart';
import 'package:project/help_functions/app_text_styles.dart';
import 'package:provider/provider.dart';

import '../help_functions/theme_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isLoading = false;

  Future<void> _onAddPost() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You must be logged in to post',
            style: AppTextStyles.bodyMedium(false),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final userId = user.uid;

    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'authorId': userId,
        'text': _textController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 0,
        'commentCount': 0,
      });

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/feed');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create post',
            style: AppTextStyles.bodyMedium(false).copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark
        ? AppColors.darkCard.withValues(alpha: 0.6)
        : AppColors.lightCard;
    final borderColor = isDark
        ? AppColors.secondary.withValues(alpha: 0.5)
        : AppColors.secondaryDark.withValues(alpha: 0.4);

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
              // Top bar
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

              const SizedBox(height: 24),

              // Centered form card
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 600),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: borderColor,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? AppColors.secondary : AppColors.secondaryDark)
                                  .withValues(alpha: isDark ? 0.15 : 0.1),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Caption field
                              TextFormField(
                                controller: _textController,
                                maxLines: 5,
                                style: AppTextStyles.bodyLarge(isDark),
                                decoration: InputDecoration(
                                  labelText: 'What\'s on your mind?',
                                  labelStyle: AppTextStyles.bodyMedium(isDark).copyWith(
                                    color: (isDark ? AppColors.secondary : AppColors.secondaryDark)
                                        .withValues(alpha: 0.8),
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? AppColors.darkBackground.withValues(alpha: 0.5)
                                      : AppColors.lightBackground.withValues(alpha: 0.5),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: borderColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: isDark ? AppColors.secondary : AppColors.secondaryDark,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: isDark ? AppColors.accent : AppColors.accentDark,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: isDark ? AppColors.accent : AppColors.accentDark,
                                      width: 2,
                                    ),
                                  ),
                                  errorStyle: AppTextStyles.caption(isDark).copyWith(
                                    color: isDark ? AppColors.accent : AppColors.accentDark,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Caption is required';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'Caption must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              // Image URL field
                              TextFormField(
                                controller: _imageUrlController,
                                style: AppTextStyles.bodyLarge(isDark),
                                decoration: InputDecoration(
                                  labelText: 'Image URL (optional)',
                                  labelStyle: AppTextStyles.bodyMedium(isDark).copyWith(
                                    color: (isDark ? AppColors.secondary : AppColors.secondaryDark)
                                        .withValues(alpha: 0.8),
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? AppColors.darkBackground.withValues(alpha: 0.5)
                                      : AppColors.lightBackground.withValues(alpha: 0.5),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: borderColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: isDark ? AppColors.secondary : AppColors.secondaryDark,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Post button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _onAddPost,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark ? AppColors.secondary : AppColors.secondaryDark,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 8,
                                    shadowColor: (isDark ? AppColors.secondary : AppColors.secondaryDark)
                                        .withValues(alpha: 0.5),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                      : Text(
                                    'POST',
                                    style: AppTextStyles.button(isDark).copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/feed');
              break;
            case 1:
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/search');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile');
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

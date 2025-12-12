import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  bool _isLoading = false;

  // Image handling variables
  File? _selectedImage;
  String? _base64Image;
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        await _convertImageToBase64();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'IMAGE SELECTION FAILED',
            style: AppTextStyles.error(true),
          ),
          backgroundColor: AppColors.darkCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
        ),
      );
    }
  }

  // Pick image from camera
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        await _convertImageToBase64();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'CAMERA ACCESS FAILED',
            style: AppTextStyles.error(true),
          ),
          backgroundColor: AppColors.darkCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
        ),
      );
    }
  }

  // Convert image to base64
  Future<void> _convertImageToBase64() async {
    if (_selectedImage == null) return;

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final base64String = base64Encode(bytes);

      setState(() {
        _base64Image = 'data:image/jpeg;base64,$base64String';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'IMAGE ENCODING FAILED',
            style: AppTextStyles.error(true),
          ),
          backgroundColor: AppColors.darkCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
        ),
      );
    }
  }

  // Show image source selection dialog
  void _showImageSourceDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardColor(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(
            color: AppColors.getPrimaryColor(isDark),
            width: 2,
          ),
        ),
        title: Text(
          'SELECT IMAGE SOURCE',
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
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
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
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Remove selected image
  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _base64Image = null;
    });
  }

  Future<void> _onAddPost() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'USER AUTH REQUIRED',
            style: AppTextStyles.error(true),
          ),
          backgroundColor: AppColors.darkCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: BorderSide(
              color: AppColors.error,
              width: 2,
            ),
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
        'imageBase64': _base64Image, // Store base64 string
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
            'POST UPLOAD FAILED',
            style: AppTextStyles.error(true),
          ),
          backgroundColor: AppColors.darkCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
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
    super.dispose();
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
                              isDark ? 'assets/logo-dark-mode.png' : 'assets/logo-light-mode.png'
                          ),
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
                            color: isDark
                                ? AppColors.accentSecondary
                                : AppColors.primaryDark,
                          ),
                          tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Form Container
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 600),
                          clipBehavior: Clip.none,
                          child: Stack(
                            children: [
                              // Corner brackets
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: isDark
                                            ? AppColors.cornerAccent2
                                            : AppColors.cornerAccent2Light,
                                        width: 3,
                                      ),
                                      left: BorderSide(
                                        color: isDark
                                            ? AppColors.cornerAccent2
                                            : AppColors.cornerAccent2Light,
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
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: isDark
                                            ? AppColors.cornerAccent3
                                            : AppColors.cornerAccent3Light,
                                        width: 3,
                                      ),
                                      right: BorderSide(
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
                                left: 0,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
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
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
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
                              // Main container
                              Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkCard.withValues(alpha: 0.7)
                                      : AppColors.lightCard,
                                  border: Border.all(
                                    color: AppColors.getPrimaryColor(isDark),
                                    width: 2,
                                  ),
                                  boxShadow: isDark
                                      ? [
                                    BoxShadow(
                                      color: AppColors.neonPinkGlow,
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                    BoxShadow(
                                      color: AppColors.neonPurpleGlow,
                                      blurRadius: 30,
                                    ),
                                  ]
                                      : [
                                    BoxShadow(
                                      color: AppColors.secondaryDark.withValues(alpha: 0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Title
                                      Text(
                                        'UPLOAD POST',
                                        style: AppTextStyles.h3(isDark).copyWith(
                                          color: AppColors.getSecondaryColor(isDark),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 32),

                                      // Caption field
                                      TextFormField(
                                        controller: _textController,
                                        maxLines: 5,
                                        style: AppTextStyles.input(isDark),
                                        decoration: InputDecoration(
                                          labelText: 'MESSAGE CONTENT',
                                          labelStyle: AppTextStyles.inputHint(isDark).copyWith(
                                            color: AppColors.getSecondaryColor(isDark).withValues(alpha: 0.7),
                                          ),
                                          filled: true,
                                          fillColor: AppColors.getBackgroundColor(isDark).withValues(alpha: 0.5),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(0),
                                            borderSide: BorderSide(
                                              color: AppColors.getSecondaryColor(isDark).withValues(alpha: 0.5),
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
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(0),
                                            borderSide: BorderSide(
                                              color: AppColors.error,
                                              width: 2,
                                            ),
                                          ),
                                          focusedErrorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(0),
                                            borderSide: BorderSide(
                                              color: AppColors.error,
                                              width: 2,
                                            ),
                                          ),
                                          errorStyle: AppTextStyles.error(isDark).copyWith(fontSize: 11),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'MESSAGE REQUIRED';
                                          }
                                          if (value.trim().length < 2) {
                                            return 'MIN 2 CHARACTERS';
                                          }
                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 24),

                                      // Image preview
                                      if (_selectedImage != null)
                                        Stack(
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              height: 200,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: AppColors.getPrimaryColor(isDark),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Image.file(
                                                _selectedImage!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: AppColors.darkCard,
                                                  border: Border.all(
                                                    color: AppColors.error,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: IconButton(
                                                  onPressed: _removeImage,
                                                  icon: Icon(
                                                    Icons.close,
                                                    color: AppColors.error,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                      if (_selectedImage != null)
                                        const SizedBox(height: 16),

                                      // Add/Change Image Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: OutlinedButton.icon(
                                          onPressed: () => _showImageSourceDialog(isDark),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.getPrimaryColor(isDark),
                                            side: BorderSide(
                                              color: AppColors.getPrimaryColor(isDark),
                                              width: 2,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(0),
                                            ),
                                          ),
                                          icon: Icon(
                                            _selectedImage == null ? Icons.add_photo_alternate : Icons.change_circle,
                                          ),
                                          label: Text(
                                            _selectedImage == null ? 'ADD IMAGE [OPTIONAL]' : 'CHANGE IMAGE',
                                            style: AppTextStyles.button(isDark).copyWith(
                                              color: AppColors.getPrimaryColor(isDark),
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 36),

                                      // Post button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: ElevatedButton(
                                          onPressed: _isLoading ? null : _onAddPost,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.getSecondaryColor(isDark),
                                            foregroundColor: AppColors.darkBackground,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(0),
                                            ),
                                            elevation: 0,
                                            shadowColor: Colors.transparent,
                                          ),
                                          child: _isLoading
                                              ? SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: AppColors.darkBackground,
                                              strokeWidth: 3,
                                            ),
                                          )
                                              : Text(
                                            'TRANSMIT POST',
                                            style: AppTextStyles.button(isDark).copyWith(
                                              color: AppColors.darkBackground,
                                              letterSpacing: 2,
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
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
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
        child: BottomNavigationBar(
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
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.getSecondaryColor(isDark),
          unselectedItemColor: isDark ? Colors.white54 : Colors.black54,
          selectedLabelStyle: AppTextStyles.navLabel(isDark).copyWith(
            color: AppColors.getSecondaryColor(isDark),
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

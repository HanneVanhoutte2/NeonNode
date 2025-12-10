import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/help_functions/app_text_styles.dart';
import 'package:project/screens/login_screen.dart';
import '../help_functions/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(true),
      body: Stack(
          children: [
            // Cyberpunk grid background
            Positioned.fill(
              child: CustomPaint(
                painter: GridPainter(),
              ),
            ),
          //Content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with neon border
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primary,
                          width: 3,
                        ),
                      ),
                      child: const Image(
                        image: AssetImage('assets/logo-dark-mode.png'),
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Login/Register Toggle
                    NeonToggle(
                      value: true,
                      onChanged: (v) {
                        if (!v) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        }
                      },
                      activeLabel: 'Register',
                      inactiveLabel: 'Login',
                      activeColor: AppColors.secondary,
                      inactiveColor: AppColors.accent,
                    ),
                    const SizedBox(height: 40),

                    // Register Form Container
                    Container(
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
                                  top: BorderSide(color: AppColors.primary, width: 3),
                                  left: BorderSide(color: AppColors.primary, width: 3),
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
                                  top: BorderSide(color: AppColors.accent, width: 3),
                                  right: BorderSide(color: AppColors.accent, width: 3),
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
                                  bottom: BorderSide(color: AppColors.secondary, width: 3),
                                  left: BorderSide(color: AppColors.secondary, width: 3),
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
                                  bottom: BorderSide(color: AppColors.accent, width: 3),
                                  right: BorderSide(color: AppColors.accent, width: 3),
                                ),
                              ),
                            ),
                          ),
                          // Main container
                          Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: AppColors.darkCard.withValues(alpha: 0.7),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.neonCyanGlow,
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: AppColors.neonPurpleGlow,
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                            child: buildRegisterForm(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]
      ),
    );
  }

  Widget buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Title
          Text(
            'CREATE IDENTITY',
            style: AppTextStyles.h3(true),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          //Display Name Field
          TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: AppTextStyles.input(true),
            decoration: InputDecoration(
              labelText: 'DISPLAY NAME',
              labelStyle: AppTextStyles.inputHint(true).copyWith(
                color: AppColors.secondaryDark.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: AppColors.darkBackground.withValues(alpha: 0.5),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: BorderSide(
                  color: AppColors.secondary.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(
                  color: AppColors.secondary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 2,
                ),
              ),
              errorStyle: AppTextStyles.error(true).copyWith(fontSize: 11),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter a display name';
              if (value.trim().length < 2) return 'Name must be at least 2 characters';
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Email/Username Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            style: AppTextStyles.input(true),
            decoration: InputDecoration(
              labelText: 'EMAIL',
              labelStyle: AppTextStyles.inputHint(true).copyWith(
                color: AppColors.secondaryDark.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: AppColors.darkBackground.withValues(alpha: 0.5),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: BorderSide(
                  color: AppColors.secondary.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(
                  color: AppColors.secondary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 2,
                ),
              ),
              errorStyle: AppTextStyles.error(true).copyWith(fontSize: 11),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter an email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Please enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Password
          TextFormField(
            controller: _passwordController,
            style: AppTextStyles.input(true),
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'PASSWORD',
              labelStyle: AppTextStyles.inputHint(true).copyWith(
                color: AppColors.secondaryDark.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: AppColors.darkBackground.withValues(alpha: 0.5),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: BorderSide(
                  color: AppColors.secondary.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(
                  color: AppColors.secondary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 2,
                ),
              ),
              errorStyle: AppTextStyles.error(true).copyWith(fontSize: 11),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter a password';
              if (value.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            style: AppTextStyles.bodyLarge(true),
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'CONFIRM PASSWORD',
              labelStyle: AppTextStyles.inputHint(true).copyWith(
                color: AppColors.secondaryDark.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: AppColors.darkBackground.withValues(alpha: 0.5),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: BorderSide(
                  color: AppColors.secondary.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(
                  color: AppColors.secondary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 2,
                ),
              ),
              errorStyle: AppTextStyles.error(true).copyWith(fontSize: 11),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please confirm your password';
              if (value != _passwordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.darkText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                elevation: 8,
                shadowColor: AppColors.secondary.withValues(alpha: 0.5),
              ),
              child: _isLoading
                  ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: AppColors.darkBackground,
                  strokeWidth: 3,
                ),
              )
                  : Text(
                'INITIALIZE REGISTER',
                style: AppTextStyles.button(true).copyWith(
                  color: AppColors.darkBackground,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'displayName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/feed');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Registration failed',
            style: GoogleFonts.rammettoOne(fontSize: 14),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred',
            style: GoogleFonts.rammettoOne(fontSize: 14),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

class NeonToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String activeLabel;
  final String inactiveLabel;
  final Color activeColor;
  final Color inactiveColor;

  const NeonToggle({
    required this.value,
    required this.onChanged,
    required this.activeLabel,
    required this.inactiveLabel,
    required this.activeColor,
    required this.inactiveColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final currentColor = value ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 240,
        height: 52,
        decoration: BoxDecoration(
          border: Border.all(
            color: currentColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: currentColor.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background fill animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: value ? Alignment.centerLeft : Alignment.centerRight,
                  end: value ? Alignment.centerRight : Alignment.centerLeft,
                  colors: [
                    currentColor.withValues(alpha: 0.3),
                    currentColor.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
            // Labels
            Row(
              children: [
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: AppTextStyles.button(true).copyWith(
                      color: !value ? inactiveColor : Colors.white.withValues(alpha: 0.4),
                      fontSize: 14,
                      shadows: !value
                          ? [
                        Shadow(
                          color: inactiveColor.withValues(alpha: 0.6),
                          blurRadius: 10,
                        ),
                      ]
                          : null,
                    ),
                    child: Text(
                      inactiveLabel.toUpperCase(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(
                  width: 2,
                  height: double.infinity,
                  color: currentColor.withValues(alpha: 0.5),
                ),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: AppTextStyles.button(true).copyWith(
                      color: value ? activeColor : Colors.white.withValues(alpha: 0.4),
                      fontSize: 14,
                      shadows: value
                          ? [
                        Shadow(
                          color: activeColor.withValues(alpha: 0.6),
                          blurRadius: 10,
                        ),
                      ]
                          : null,
                    ),
                    child: Text(
                      activeLabel.toUpperCase(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

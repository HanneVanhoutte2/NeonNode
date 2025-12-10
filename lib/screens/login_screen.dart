import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/help_functions/app_text_styles.dart';
import '../help_functions/app_colors.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrUsernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String input = _emailOrUsernameController.text.trim();
      String email = input;

      if (!input.contains('@')) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('displayName', isEqualTo: input)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'USERNAME NOT FOUND',
                style: AppTextStyles.error(true),
              ),
              backgroundColor: AppColors.darkCard,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: AppColors.error,
                  width: 2,
                ),
              ),
            ),
          );
          setState(() => _isLoading = false);
          return;
        }

        email = querySnapshot.docs.first.data()['email'] as String;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/feed');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (e.message ?? 'LOGIN FAILED').toUpperCase(),
            style: AppTextStyles.error(true),
          ),
          backgroundColor: AppColors.darkCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'SYSTEM ERROR',
            style: AppTextStyles.error(true),
          ),
          backgroundColor: AppColors.darkCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // Cyberpunk grid background
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(),
            ),
          ),
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
                      value: false,
                      onChanged: (v) {
                        if (v) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        }
                      },
                      activeLabel: 'Register',
                      inactiveLabel: 'Login',
                      activeColor: AppColors.secondary,
                      inactiveColor: AppColors.primary,
                    ),

                    const SizedBox(height: 40),

                    // Login Form Container
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
                            child: buildLoginForm(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Title
          Text(
            'ACCESS TERMINAL',
            style: AppTextStyles.h3(true),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Email/Username Field
          TextFormField(
            controller: _emailOrUsernameController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            style: AppTextStyles.input(true),
            decoration: InputDecoration(
              labelText: 'EMAIL / USERNAME',
              labelStyle: AppTextStyles.inputHint(true).copyWith(
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: AppColors.darkBackground.withValues(alpha: 0.5),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: BorderSide(
                  color: AppColors.primary,
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
              errorStyle: AppTextStyles.error(true).copyWith(fontSize: 11),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'FIELD REQUIRED';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Password Field
          TextFormField(
            controller: _passwordController,
            style: AppTextStyles.input(true),
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'PASSWORD',
              labelStyle: AppTextStyles.inputHint(true).copyWith(
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: AppColors.darkBackground.withValues(alpha: 0.5),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: BorderSide(
                  color: AppColors.primary,
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
              errorStyle: AppTextStyles.error(true).copyWith(fontSize: 11),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'PASSWORD REQUIRED';
              if (value.length < 6) return 'MIN 6 CHARACTERS';
              return null;
            },
          ),
          const SizedBox(height: 36),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.darkBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
                side: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ).copyWith(
                overlayColor: WidgetStateProperty.all(
                  AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyanGlow,
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
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
                  'INITIALIZE LOGIN',
                  style: AppTextStyles.button(true).copyWith(
                    color: AppColors.darkBackground,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailOrUsernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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

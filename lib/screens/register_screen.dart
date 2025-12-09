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
      Navigator.pushReplacementNamed(context, '/login');
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBackground,
              AppColors.darkBackgroundGradient,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Image(
                    image: AssetImage('assets/logo-dark-mode.png'),
                    height: 120,
                  ),
                  const SizedBox(height: 48),

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

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.darkBackground.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: buildRegisterForm(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.rammettoOne(
              color: AppColors.darkText,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              labelText: 'Display Name',
              labelStyle: GoogleFonts.rammettoOne(
                color: AppColors.secondary.withValues(alpha: 0.8),
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.darkBackground.withValues(alpha: 0.5),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.secondary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.secondary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 2,
                ),
              ),
              errorStyle: GoogleFonts.rammettoOne(
                color: AppColors.accent,
                fontSize: 12,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter a display name';
              if (value.trim().length < 2) return 'Name must be at least 2 characters';
              return null;
            },
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            style: GoogleFonts.rammettoOne(
              color: AppColors.darkText,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: GoogleFonts.rammettoOne(
                color: AppColors.secondary.withValues(alpha: 0.8),
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.darkBackground.withValues(alpha: 0.5),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.secondary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.secondary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 2,
                ),
              ),
              errorStyle: GoogleFonts.rammettoOne(
                color: AppColors.accent,
                fontSize: 12,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter an email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Please enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: _passwordController,
            style: AppTextStyles.bodyLarge(true),
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: GoogleFonts.rammettoOne(
                color: AppColors.secondary.withValues(alpha: 0.8),
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.darkBackground.withValues(alpha: 0.5),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.secondary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.secondary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.secondary,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 2,
                ),
              ),
              errorStyle: GoogleFonts.rammettoOne(
                color: AppColors.accent,
                fontSize: 12,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter a password';
              if (value.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: _confirmPasswordController,
            style: AppTextStyles.bodyLarge(true),
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              labelStyle: GoogleFonts.rammettoOne(
                color: AppColors.secondary.withValues(alpha: 0.8),
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.darkBackground.withValues(alpha: 0.5),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.secondary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.secondary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 2,
                ),
              ),
              errorStyle: GoogleFonts.rammettoOne(
                color: AppColors.accent,
                fontSize: 12,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: AppColors.secondary.withValues(alpha: 0.5),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: AppColors.darkText)
                  : Text(
                'Create Account',
                style: AppTextStyles.h4(true),
              ),
            ),
          ),
        ],
      ),
    );
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
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        width: 200,
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          color: value ? activeColor : inactiveColor,
          boxShadow: [
            BoxShadow(
              color: (value ? activeColor : inactiveColor).withValues(alpha: 0.6),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkText,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkBackground.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ],
                ),
              ),
            ),
            Center(
              child: Text(
                (value ? activeLabel : inactiveLabel).toUpperCase(),
                style: GoogleFonts.rammettoOne(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.2,
                  shadows: const [
                    Shadow(
                      color: AppColors.darkBackground,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

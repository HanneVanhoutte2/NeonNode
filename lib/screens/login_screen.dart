import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
            const SnackBar(content: Text('Username not found')),
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
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
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
              Color(0xFF0A0E1A),
              Color(0xFF050816),
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
                  Image(
                    image: AssetImage('assets/logo-color.png'),
                    height: 120,
                  ),
                  const SizedBox(height: 48),

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
                    activeColor: const Color(0xFF8A00C4),
                    inactiveColor: const Color(0xFF39FF14),
                  ),

                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1520).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF39FF14).withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF39FF14).withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: buildLoginForm(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailOrUsernameController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Email or Username',
              labelStyle: TextStyle(
                color: const Color(0xFF39FF14).withValues(alpha: 0.8),
                fontSize: 15,
              ),
              filled: true,
              fillColor: const Color(0xFF0A0E1A).withValues(alpha: 0.5),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFF39FF14).withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF39FF14),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFFF2CD6),
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFFF2CD6),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter email or username';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(
                color: const Color(0xFF39FF14).withValues(alpha: 0.8),
                fontSize: 15,
              ),
              filled: true,
              fillColor: const Color(0xFF0A0E1A).withValues(alpha: 0.5),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFF39FF14).withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF39FF14),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFFF2CD6),
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFFF2CD6),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter a password';
              if (value.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF39FF14),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: const Color(0xFF39FF14).withValues(alpha: 0.5),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        width: 160,
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
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
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

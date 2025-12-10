import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../help_functions/app_colors.dart';
import '../help_functions/app_text_styles.dart';
import '../help_functions/theme_provider.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

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
                            color: AppColors.getSecondaryColor(isDark),
                            width: 2,
                          ),
                        ),
                        child: Image(
                          image: AssetImage(
                              isDark ? 'assets/logo-dark-mode.png' : 'assets/logo-light-mode.png'),
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
                            Provider.of<ThemeProvider>(context, listen: false)
                                .toggleTheme();
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
                const SizedBox(height: 12),

                // Main Content
                Expanded(
                  child: Center(
                    child: Container(
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
                            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 80),
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
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.getSecondaryColor(isDark),
                                      width: 2,
                                    ),
                                    boxShadow: isDark
                                        ? [
                                      BoxShadow(
                                        color: AppColors.neonPinkGlow,
                                        blurRadius: 15,
                                      ),
                                    ]
                                        : null,
                                  ),
                                  child: Icon(
                                    Icons.search,
                                    size: 64,
                                    color: AppColors.getSecondaryColor(isDark),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'SEARCH MODULE',
                                  style: AppTextStyles.h3(isDark).copyWith(
                                    color: AppColors.getSecondaryColor(isDark),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'UNDER DEVELOPMENT',
                                  style: AppTextStyles.systemSubtitle(isDark),
                                  textAlign: TextAlign.center,
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
          ),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard.withValues(alpha: 0.95) : AppColors.lightCard,
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
          currentIndex: 2,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/feed');
                break;
              case 1:
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  Navigator.pushNamed(context, '/create-post');
                }
                break;
              case 2:
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/screens/post_detail_screen.dart';
import 'package:project/screens/user_profile_screen.dart';
import 'package:provider/provider.dart';
import '../help_functions/app_colors.dart';
import '../help_functions/app_text_styles.dart';
import '../help_functions/theme_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedTab = 'accounts'; // 'accounts' or 'posts'

  @override
  void dispose() {
    _searchController.dispose();
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

                // Search Bar
                Container(
                  margin: const EdgeInsets.all(16),
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
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase().trim();
                      });
                    },
                    style: AppTextStyles.input(isDark),
                    decoration: InputDecoration(
                      hintText: 'Search $_selectedTab...',
                      hintStyle: AppTextStyles.inputHint(isDark).copyWith(
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.getPrimaryColor(isDark),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.getPrimaryColor(isDark),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),

                // Tab Selector
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTab = 'accounts';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedTab == 'accounts'
                                  ? AppColors.getPrimaryColor(isDark)
                                  : AppColors.getCardColor(isDark).withValues(alpha: 0.5),
                              border: Border.all(
                                color: AppColors.getPrimaryColor(isDark),
                                width: 2,
                              ),
                              boxShadow: _selectedTab == 'accounts' && isDark
                                  ? [
                                BoxShadow(
                                  color: AppColors.neonCyanGlow,
                                  blurRadius: 10,
                                ),
                              ]
                                  : null,
                            ),
                            child: Text(
                              'ACCOUNTS',
                              style: AppTextStyles.label(isDark).copyWith(
                                color: _selectedTab == 'accounts'
                                    ? (isDark ? AppColors.darkBackground : Colors.white)
                                    : AppColors.getPrimaryColor(isDark),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTab = 'posts';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedTab == 'posts'
                                  ? AppColors.getSecondaryColor(isDark)
                                  : AppColors.getCardColor(isDark).withValues(alpha: 0.5),
                              border: Border.all(
                                color: AppColors.getSecondaryColor(isDark),
                                width: 2,
                              ),
                              boxShadow: _selectedTab == 'posts' && isDark
                                  ? [
                                BoxShadow(
                                  color: AppColors.neonPinkGlow,
                                  blurRadius: 10,
                                ),
                              ]
                                  : null,
                            ),
                            child: Text(
                              'POSTS',
                              style: AppTextStyles.label(isDark).copyWith(
                                color: _selectedTab == 'posts'
                                    ? (isDark ? AppColors.darkBackground : Colors.white)
                                    : AppColors.getSecondaryColor(isDark),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Results
                Expanded(
                  child: _searchQuery.isEmpty
                      ? _buildEmptyState(isDark)
                      : _selectedTab == 'accounts'
                      ? _buildAccountResults(isDark)
                      : _buildPostResults(isDark),
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
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
                  color: AppColors.getPrimaryColor(isDark),
                  width: 2,
                ),
                boxShadow: isDark
                    ? [
                  BoxShadow(
                    color: AppColors.neonCyanGlow,
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
                    : [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.2),
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
                        color: AppColors.getPrimaryColor(isDark),
                        width: 2,
                      ),
                      boxShadow: isDark
                          ? [
                        BoxShadow(
                          color: AppColors.neonCyanGlow,
                          blurRadius: 15,
                        ),
                      ]
                          : null,
                    ),
                    child: Icon(
                      Icons.search,
                      size: 64,
                      color: AppColors.getPrimaryColor(isDark),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'SEARCH',
                    style: AppTextStyles.h3(isDark).copyWith(
                      color: AppColors.getPrimaryColor(isDark),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Start typing to search\n${_selectedTab.toUpperCase()}',
                    style: AppTextStyles.systemSubtitle(isDark),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountResults(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('displayNameLower')
          .startAt([_searchQuery])
          .endAt(['$_searchQuery\\uf8ff'])
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.getPrimaryColor(isDark),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.getCardColor(isDark).withValues(alpha: 0.7),
                border: Border.all(
                  color: AppColors.getPrimaryColor(isDark),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_off,
                    size: 48,
                    color: AppColors.getPrimaryColor(isDark),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'NO ACCOUNTS FOUND',
                    style: AppTextStyles.label(isDark),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final userData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final userId = snapshot.data!.docs[index].id;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfileScreen(userId: userId),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
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
                      blurRadius: 10,
                    ),
                  ]
                      : [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Profile picture
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.getPrimaryColor(isDark),
                          width: 2,
                        ),
                        image: userData['avatarUrl'] != null
                            ? DecorationImage(
                          image: NetworkImage(userData['avatarUrl']),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: userData['avatarUrl'] == null
                          ? Icon(
                        Icons.person,
                        color: AppColors.getPrimaryColor(isDark),
                        size: 30,
                      )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    // User info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData['displayName'] ?? 'Unknown',
                            style: AppTextStyles.h3(isDark).copyWith(
                              color: AppColors.getPrimaryColor(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: AppColors.getPrimaryColor(isDark),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPostResults(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.getSecondaryColor(isDark),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.getCardColor(isDark).withValues(alpha: 0.7),
                border: Border.all(
                  color: AppColors.getSecondaryColor(isDark),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.post_add,
                    size: 48,
                    color: AppColors.getSecondaryColor(isDark),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'NO POSTS FOUND',
                    style: AppTextStyles.label(isDark),
                  ),
                ],
              ),
            ),
          );
        }

        // Filter posts based on search query
        final filteredDocs = snapshot.data!.docs.where((doc) {
          final postData = doc.data() as Map<String, dynamic>;
          final content = (postData['text'] ?? '').toString().toLowerCase();
          final username = (postData['displayName'] ?? '').toString().toLowerCase();
          return content.contains(_searchQuery) || username.contains(_searchQuery);
        }).toList();

        if (filteredDocs.isEmpty) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.getCardColor(isDark).withValues(alpha: 0.7),
                border: Border.all(
                  color: AppColors.getSecondaryColor(isDark),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.post_add,
                    size: 48,
                    color: AppColors.getSecondaryColor(isDark),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'NO POSTS FOUND',
                    style: AppTextStyles.label(isDark),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final postData = filteredDocs[index].data() as Map<String, dynamic>;
            final postId = filteredDocs[index].id;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailScreen(
                      postId: postId,
                      authorId: postData['userId'] ?? '',
                      text: postData['content'] ?? '',
                      imageUrl: postData['imageUrl'],
                      createdAt: postData['timestamp'],
                      isDark: isDark,
                      avatarUrl: postData['userProfilePicture'],
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                      blurRadius: 10,
                    ),
                  ]
                      : [
                    BoxShadow(
                      color: AppColors.secondaryDark.withValues(alpha: 0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post header
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.getSecondaryColor(isDark),
                              width: 2,
                            ),
                            image: postData['userProfilePicture'] != null
                                ? DecorationImage(
                              image: NetworkImage(postData['userProfilePicture']),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: postData['userProfilePicture'] == null
                              ? Icon(
                            Icons.person,
                            color: AppColors.getSecondaryColor(isDark),
                            size: 24,
                          )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          postData['displayName'] ?? 'Unknown',
                          style: AppTextStyles.label(isDark).copyWith(
                            color: AppColors.getSecondaryColor(isDark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Post content
                    Text(
                      postData['text'] ?? '',
                      style: AppTextStyles.bodyMedium(isDark),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (postData['imageUrl'] != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        child: Image.network(
                          postData['imageUrl'],
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 20,
                          color: AppColors.getSecondaryColor(isDark),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${postData['likeCount']?.length ?? 0}',
                          style: AppTextStyles.caption(isDark),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.comment,
                          size: 20,
                          color: AppColors.getSecondaryColor(isDark),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${postData['commentCount'] ?? 0}',
                          style: AppTextStyles.caption(isDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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

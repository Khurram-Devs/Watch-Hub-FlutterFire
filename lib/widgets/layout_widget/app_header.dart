import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:watch_hub_ep/theme/theme_provider.dart';
import 'package:watch_hub_ep/services/auth_service.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  Future<Map<String, String>> _fetchUserData(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('usersProfile').doc(uid).get();
    final data = doc.data() ?? {};
    return {
      'fullName': data['fullName'] ?? '',
      'avatarUrl': data['avatarUrl'] ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AppBar(
              backgroundColor:
                  theme.appBarTheme.backgroundColor ?? Colors.black,
              elevation: 0,
              toolbarHeight: 60,
              titleSpacing: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Color(0xFFC0A265)),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => themeProvider.toggleTheme(),
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: const Color(0xFFC0A265),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: user == null
                      ? OutlinedButton(
                          onPressed: () => context.push('/auth'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFC0A265)),
                            foregroundColor: theme.colorScheme.secondary,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Login",
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        )
                      : FutureBuilder<Map<String, String>>(
                          future: _fetchUserData(user.uid),
                          builder: (context, snapshot) {
                            final fullName = snapshot.data?['fullName'] ?? user.displayName ?? 'User';
                            final avatar = snapshot.data?['avatarUrl'] ?? user.photoURL ?? '';
                            return PopupMenuButton<String>(
                              offset: const Offset(0, 60),
                              color: theme.cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              onSelected: (value) async {
                                if (value == 'profile') {
                                  context.go('/profile/profile');
                                } else if (value == 'wishlist') {
                                  context.go('/profile/wishlist');
                                } else if (value == 'logout') {
                                  final shouldLogout = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirm Logout'),
                                      content: const Text('Are you sure you want to log out?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Logout'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (shouldLogout == true) {
                                    await AuthService.logout(context);
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  enabled: false,
                                  padding: const EdgeInsets.all(0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    width: MediaQuery.of(context).size.width > 400 ? 250 : 200,
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundImage: avatar.isNotEmpty
                                              ? NetworkImage(avatar)
                                              : const AssetImage('assets/images/default_user.png')
                                                  as ImageProvider,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          fullName,
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        const Divider(thickness: 1),
                                      ],
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'profile',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.person_outline),
                                      const SizedBox(width: 10),
                                      Text('Profile', style: theme.textTheme.bodyMedium),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'wishlist',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.favorite_border),
                                      const SizedBox(width: 10),
                                      Text('Wishlist', style: theme.textTheme.bodyMedium),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'logout',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.logout),
                                      const SizedBox(width: 10),
                                      Text('Logout', style: theme.textTheme.bodyMedium),
                                    ],
                                  ),
                                ),
                              ],
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage: avatar.isNotEmpty
                                    ? NetworkImage(avatar)
                                    : const AssetImage('assets/images/default_user.png')
                                        as ImageProvider,
                              ),
                            );
                          },
                        ),
                ),
              ],
              title: const SizedBox(),
            ),
            const Positioned(
              child: Icon(
                Icons.diamond_rounded,
                color: Color(0xFFC0A265),
                size: 20,
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0x84C0A265), width: 0.5),
              top: BorderSide(color: Color(0x84C0A265), width: 0.5),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            'WATCH-HUB',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.secondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

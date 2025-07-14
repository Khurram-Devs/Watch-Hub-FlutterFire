import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../../theme/theme_provider.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Drawer header
          DrawerHeader(
            decoration: BoxDecoration(color: theme.cardColor),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(Icons.watch, size: 40, color: Color(0xFFC0A265)),
                SizedBox(width: 16),
                Text(
                  'WatchHub',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFFC0A265),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Navigation items
          Expanded(
            child: ListView(
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  route: '/home',
                  context: context,
                ),
                _buildNavItem(
                  icon: Icons.storefront,
                  label: 'Catalog',
                  route: '/catalog',
                  context: context,
                ),
                _buildNavItem(
                  icon: Icons.favorite_border,
                  label: 'Wishlist',
                  route: '/wishlist',
                  context: context,
                ),
                _buildNavItem(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Cart',
                  route: '/cart',
                  context: context,
                ),
                _buildNavItem(
                  icon: Icons.shopping_cart_checkout,
                  label: 'Orders',
                  route: '/orders',
                  context: context,
                ),
                _buildNavItem(
                  icon: Icons.location_on_outlined,
                  label: 'Address Book',
                  route: '/address-book',
                  context: context,
                ),
                _buildNavItem(
                  icon: Icons.info_outline,
                  label: 'About Us',
                  route: '/about-us',
                  context: context,
                ),
              ],
            ),
          ),

          const Divider(),

          // Bottom Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Theme Toggle
                IconButton(
                  tooltip:
                      isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: const Color(0xFFC0A265),
                  ),
                  onPressed: () => themeProvider.toggleTheme(),
                ),

                // Auth Actions
                user == null
                    ? ElevatedButton.icon(
                      onPressed: () => context.go('/auth'),
                      icon: const Icon(Icons.login),
                      label: const Text('Login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC0A265),
                        foregroundColor: Colors.white,
                      ),
                    )
                    : StreamBuilder<DocumentSnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('usersProfile')
                              .doc(user.uid)
                              .snapshots(),
                      builder: (context, snapshot) {
                        final data =
                            snapshot.data?.data() as Map<String, dynamic>?;

                        final avatar =
                            data?['avatarUrl'] ?? user.photoURL ?? '';

                        return Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.go('/profile'),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    avatar.isNotEmpty
                                        ? NetworkImage(avatar)
                                        : const AssetImage(
                                              'assets/images/default_user.png',
                                            )
                                            as ImageProvider,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Logout',
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.redAccent,
                              ),
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                if (context.mounted) {
                                  context.go('/auth');
                                }
                              },
                            ),
                          ],
                        );
                      },
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String route,
    required BuildContext context,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFC0A265)),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}

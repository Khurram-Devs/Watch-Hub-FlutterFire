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
    final colorScheme = theme.colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.cardColor),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.watch, size: 40, color: colorScheme.secondary),
                const SizedBox(width: 16),
                Text(
                  'WatchHub',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  route: '/home',
                  context: context,
                  color: colorScheme.secondary,
                ),
                _buildNavItem(
                  icon: Icons.storefront,
                  label: 'Catalog',
                  route: '/catalog',
                  context: context,
                  color: colorScheme.secondary,
                ),

                // Wishlist
                if (user != null)
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('usersProfile')
                        .doc(user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      int count = 0;
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data = snapshot.data!.data() as Map<String, dynamic>?;
                        count = (data?['wishlist'] as List?)?.length ?? 0;
                      }

                      return ListTile(
                        leading: Icon(Icons.favorite_border, color: colorScheme.secondary),
                        title: Row(
                          children: [
                            const Text('Wishlist'),
                            const SizedBox(width: 6),
                            if (count > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/wishlist');
                        },
                      );
                    },
                  ),

                // Cart
                if (user != null)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('usersProfile')
                        .doc(user.uid)
                        .collection('cart')
                        .snapshots(),
                    builder: (context, snapshot) {
                      int totalQty = 0;
                      if (snapshot.hasData) {
                        for (var doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          totalQty += (data['quantity'] ?? 1) as int;
                        }
                      }

                      return ListTile(
                        leading: Icon(Icons.shopping_bag_outlined, color: colorScheme.secondary),
                        title: Row(
                          children: [
                            const Text('Cart'),
                            const SizedBox(width: 6),
                            if (totalQty > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$totalQty',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/cart');
                        },
                      );
                    },
                  )
                else
                  _buildNavItem(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Cart',
                    route: '/cart',
                    context: context,
                    color: colorScheme.secondary,
                  ),

                if (user != null) ...[
                  _buildNavItem(
                    icon: Icons.shopping_cart_checkout,
                    label: 'Orders',
                    route: '/orders',
                    context: context,
                    color: colorScheme.secondary,
                  ),
                  _buildNavItem(
                    icon: Icons.location_on_outlined,
                    label: 'Address Book',
                    route: '/address-book',
                    context: context,
                    color: colorScheme.secondary,
                  ),
                ],

                _buildNavItem(
                  icon: Icons.info_outline,
                  label: 'About Us',
                  route: '/about-us',
                  context: context,
                  color: colorScheme.secondary,
                ),
              ],
            ),
          ),

          const Divider(),

          // Bottom section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: colorScheme.secondary,
                  ),
                  onPressed: () => themeProvider.toggleTheme(),
                ),

                // Auth
                user == null
                    ? ElevatedButton.icon(
                        onPressed: () => context.go('/auth/login'),
                        icon: const Icon(Icons.login),
                        label: const Text('Login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: Colors.white,
                        ),
                      )
                    : StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('usersProfile')
                            .doc(user.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          final data = snapshot.data?.data() as Map<String, dynamic>?;
                          final avatar = data?['avatarUrl'] ?? user.photoURL ?? '';

                          return Row(
                            children: [
                              GestureDetector(
                                onTap: () => context.go('/profile'),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: avatar.isNotEmpty
                                      ? NetworkImage(avatar)
                                      : const AssetImage('assets/images/default_user.png') as ImageProvider,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Logout',
                                icon: const Icon(Icons.logout, color: Colors.redAccent),
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  if (context.mounted) context.go('/auth/login');
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
    required Color color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}

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
    final doc = await FirebaseFirestore.instance
        .collection('usersProfile')
        .doc(uid)
        .get();
    final data = doc.data() ?? {};
    return {
      'fullName': data['fullName'] ?? '',
      'avatarUrl': data['avatarUrl'] ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor ?? Colors.black,
          elevation: 0,
          toolbarHeight: 60,
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Color(0xFFC0A265)),
                onPressed: () {
                  final scaffold = Scaffold.maybeOf(context);
                  if (scaffold?.hasDrawer ?? false) {
                    scaffold?.openDrawer();
                  } else {
                    debugPrint('No drawer found in parent Scaffold');
                  }
                },
              );
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.diamond_rounded, color: Color(0xFFC0A265), size: 20),
              SizedBox(width: 6),
              Text(
                'WATCH-HUB',
                style: TextStyle(
                  fontSize: 20,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC0A265),
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            // Cart icon with item count
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

                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined,
                            color: Color(0xFFC0A265)),
                        onPressed: () => context.push('/cart'),
                      ),
                      if (totalQty > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$totalQty',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

            // Theme toggle
            IconButton(
              onPressed: () => themeProvider.toggleTheme(),
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: const Color(0xFFC0A265),
              ),
            ),

            // User Profile or Login
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: user == null
                  ? OutlinedButton(
                      onPressed: () => context.push('/auth'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFC0A265)),
                        foregroundColor: theme.colorScheme.secondary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Login"),
                    )
                  : FutureBuilder<Map<String, String>>(
                      future: _fetchUserData(user.uid),
                      builder: (context, snapshot) {
                        final fullName = snapshot.data?['fullName'] ??
                            user.displayName ??
                            'User';
                        final avatar = snapshot.data?['avatarUrl'] ??
                            user.photoURL ??
                            '';

                        return PopupMenuButton<String>(
                          offset: const Offset(0, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (value) async {
                            if (value == 'profile') {
                              context.go('/profile/profile');
                            } else if (value == 'wishlist') {
                              context.go('/profile/wishlist');
                            } else if (value == 'logout') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Confirm Logout'),
                                  content: const Text(
                                      'Are you sure you want to log out?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: const Text('Logout'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await AuthService.logout(context);
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              enabled: false,
                              padding: EdgeInsets.zero,
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundImage: avatar.isNotEmpty
                                        ? NetworkImage(avatar)
                                        : const AssetImage(
                                                'assets/images/default_user.png')
                                            as ImageProvider,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    fullName,
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const Divider(thickness: 1),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'profile',
                              child: ListTile(
                                leading: Icon(Icons.person_outline),
                                title: Text('Profile'),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'wishlist',
                              child: ListTile(
                                leading: Icon(Icons.favorite_border),
                                title: Text('Wishlist'),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'logout',
                              child: ListTile(
                                leading: Icon(Icons.logout),
                                title: Text('Logout'),
                              ),
                            ),
                          ],
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: avatar.isNotEmpty
                                ? NetworkImage(avatar)
                                : const AssetImage(
                                        'assets/images/default_user.png')
                                    as ImageProvider,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.cardColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.watch, size: 40, color: Color(0xFFC0A265)),
                SizedBox(height: 12),
                Text(
                  'WatchHub',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFFC0A265),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFFC0A265)),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              context.go('/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.store, color: Color(0xFFC0A265)),
            title: const Text('Catalog'),
            onTap: () {
              Navigator.pop(context);
              context.go('/catalog');
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: const Color(0xFFC0A265),
            ),
            title: Text(isDark ? 'Light Theme' : 'Dark Theme'),
            onTap: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

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
                builder:
                    (context) => IconButton(
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
              ],
              title:
                  const SizedBox(), // leave empty to avoid centering conflict
            ),

            // Center Icon Overlay
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
          padding: const EdgeInsets.only(bottom: 4, top: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0x84C0A265), width: 0.5),
              top: BorderSide(color: Color(0x84C0A265), width: 0.5),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            'ROLEX WATCHES',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
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

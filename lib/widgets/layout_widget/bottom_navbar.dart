import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdaptiveBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AdaptiveBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    if (!isMobile) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/catalog');
            break;
          case 2:
            context.go('/wishlist');
            break;
          case 3:
            context.go('/profile');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: theme.colorScheme.secondary,
      unselectedItemColor: theme.disabledColor,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: theme.navigationBarTheme.backgroundColor,
      elevation: 12,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.storefront), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
      ],
    );
  }
}

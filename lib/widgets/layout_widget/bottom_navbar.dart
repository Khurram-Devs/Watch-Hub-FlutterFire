import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdaptiveBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AdaptiveBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    if (!isMobile) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: ''),
      const BottomNavigationBarItem(icon: Icon(Icons.storefront), label: ''),
    ];

    if (user != null) {
      items.add(
        BottomNavigationBarItem(
          icon: StreamBuilder<DocumentSnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('usersProfile')
                    .doc(user.uid)
                    .snapshots(),
            builder: (context, snapshot) {
              int count = 0;
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                count = (data?['wishlist'] as List?)?.length ?? 0;
              }

              return Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.favorite_border),
                  if (count > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 10,
                          minHeight: 10,
                        ),
                        child: Text(
                          '$count',
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
          label: '',
        ),
      );
    }

    items.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: '',
      ),
    );

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 0) {
          context.go('/home');
        } else if (index == 1) {
          context.go('/catalog');
        } else if (user != null && index == 2 && items.length == 4) {
          context.go('/wishlist');
        } else {
          context.go('/profile');
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: theme.colorScheme.secondary,
      unselectedItemColor: theme.disabledColor,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: theme.navigationBarTheme.backgroundColor,
      elevation: 12,
      items: items,
    );
  }
}

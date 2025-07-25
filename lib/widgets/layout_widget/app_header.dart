import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          backgroundColor:
              theme.appBarTheme.backgroundColor ??
              theme.scaffoldBackgroundColor,
          elevation: 0,
          toolbarHeight: 60,
          leading: Builder(
            builder:
                (context) => IconButton(
                  icon: Icon(Icons.menu, color: colorScheme.secondary),
                  onPressed: () {
                    final scaffold = Scaffold.maybeOf(context);
                    if (scaffold?.hasDrawer ?? false) {
                      scaffold?.openDrawer();
                    } else {
                      debugPrint('No drawer found in parent Scaffold');
                    }
                  },
                ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.diamond_rounded,
                color: colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'WATCH-HUB',
                style: TextStyle(
                  fontSize: 20,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            if (user != null)
              Row(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('usersProfile')
                            .doc(user.uid)
                            .collection('notifications')
                            .where('isRead', isEqualTo: false)
                            .snapshots(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;

                      return Stack(
                        alignment: Alignment.topRight,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.notifications_none_rounded,
                              color: colorScheme.secondary,
                            ),
                            onPressed: () => context.push('/notifications'),
                          ),
                          if (count > 0)
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

                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
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
                            icon: Icon(
                              Icons.shopping_cart_outlined,
                              color: colorScheme.secondary,
                            ),
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
                ],
              )
            else
              const SizedBox(
                width: kToolbarHeight,
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.transparent,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

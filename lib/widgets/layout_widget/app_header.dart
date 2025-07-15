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
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor ?? Colors.black,
          elevation: 0,
          toolbarHeight: 60,
          leading: Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Color(0xFFC0A265)),
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
            if (user != null)
              Row(
                children: [
                  // Notifications badge
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
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: Color(0xFFC0A265),
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

                  // Cart badge
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
                            icon: const Icon(
                              Icons.shopping_cart_outlined,
                              color: Color(0xFFC0A265),
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
                width: kToolbarHeight * 2,
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

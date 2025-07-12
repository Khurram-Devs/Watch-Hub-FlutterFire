import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import './theme/theme_provider.dart';
import './screens/user/home_screen.dart';
import './screens/user/catalog_screen.dart';
import './screens/user/redirect_auth_screen.dart';
import './screens/user/cart_screen.dart';
import './screens/user/checkout_screen.dart';
import './screens/user/order_success_screen.dart';
import './screens/user/product_detail_screen.dart';
import './screens/user/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthChangeNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

/// Notify GoRouter when auth state changes
class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final router = GoRouter(
      initialLocation: '/home',
      refreshListenable: Provider.of<AuthChangeNotifier>(context),
      redirect: (context, state) {
        final isLoggedIn = FirebaseAuth.instance.currentUser != null;
        final isAuthPage = state.matchedLocation == '/auth';

        final protectedRoutes = [
          '/cart',
          '/checkout',
          '/profile',
          '/profile/profile',
          '/profile/wishlist',
          '/profile/address',
          '/profile/orders',
        ];

        if (!isLoggedIn &&
            protectedRoutes.any((route) => state.matchedLocation.startsWith(route))) {
          return '/auth';
        }

        if (isLoggedIn && isAuthPage) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/catalog', builder: (context, state) => const CatalogScreen()),
        GoRoute(path: '/auth', builder: (context, state) => const RedirectAuthScreen()),
        GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
        GoRoute(
          path: '/checkout',
          name: 'checkout',
          builder: (context, state) {
            final cartData = state.extra as Map<String, dynamic>;
            return CheckoutScreen(
              cartItems: cartData['items'],
              subtotal: cartData['subtotal'],
              tax: cartData['tax'],
              shipping: cartData['shipping'],
              total: cartData['total'],
            );
          },
        ),
        GoRoute(
          path: '/product/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ProductDetailScreen(productId: id);
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(tab: 'profile'),
        ),
        GoRoute(
          path: '/profile/:tab',
          builder: (context, state) {
            final tab = state.pathParameters['tab']!;
            return ProfileScreen(tab: tab);
          },
        ),
        GoRoute(
          path: '/order-success/:orderId',
          name: 'order-success',
          builder: (context, state) {
            final orderId = state.pathParameters['orderId']!;
            return OrderSuccessScreen(orderId: orderId);
          },
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
    );
  }
}

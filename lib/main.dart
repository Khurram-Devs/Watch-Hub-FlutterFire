import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_hub_ep/screens/about_us_screen.dart';
import 'package:watch_hub_ep/screens/login_screen.dart';
import 'package:watch_hub_ep/screens/signup_screen.dart';

import 'firebase_options.dart';
import 'theme/theme_provider.dart';

import 'screens/home_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/order_success_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/address_book_screen.dart';
import 'screens/wishlist_screen.dart';
import 'screens/orders_screen.dart';

import 'widgets/layout_widget/main_scaffold.dart';

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
        final isAuthPage = state.matchedLocation.startsWith('/auth');

        final protectedRoutes = [
          '/cart',
          '/checkout',
          '/order-success',
          '/profile',
          '/address-book',
          '/wishlist',
          '/orders',
        ];

        if (!isLoggedIn &&
            protectedRoutes.any((r) => state.matchedLocation.startsWith(r))) {
          return '/auth/signup';
        }

        if (isLoggedIn && isAuthPage) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/home',
          builder:
              (context, state) =>
                  const MainScaffold(currentIndex: 0, child: HomeScreen()),
        ),
        GoRoute(
          path: '/catalog',
          builder:
              (context, state) =>
                  const MainScaffold(currentIndex: 1, child: CatalogScreen()),
        ),
        GoRoute(
          path: '/auth/login',
          builder:
              (context, state) =>
                  const MainScaffold(currentIndex: 2, child: LoginScreen()),
        ),
        GoRoute(
          path: '/auth/signup',
          builder:
              (context, state) =>
                  const MainScaffold(currentIndex: 2, child: SignupScreen()),
        ),
        GoRoute(
          path: '/profile',
          builder:
              (context, state) =>
                  const MainScaffold(currentIndex: 3, child: ProfileScreen()),
        ),
        GoRoute(
          path: '/address-book',
          builder:
              (context, state) =>
                  MainScaffold(currentIndex: 3, child: AddressBookScreen()),
        ),
        GoRoute(
          path: '/wishlist',
          builder:
              (context, state) =>
                  MainScaffold(currentIndex: 2, child: WishlistScreen()),
        ),
        GoRoute(
          path: '/about-us',
          builder:
              (context, state) =>
                  const MainScaffold(currentIndex: 0, child: AboutUsScreen()),
        ),
        GoRoute(
          path: '/orders',
          builder:
              (context, state) =>
                  MainScaffold(currentIndex: 3, child: OrdersScreen()),
        ),
        GoRoute(
          path: '/cart',
          builder:
              (context, state) =>
                  const MainScaffold(currentIndex: 2, child: CartScreen()),
        ),
        GoRoute(
          path: '/checkout',
          name: 'checkout',
          builder: (context, state) {
            final cartData = state.extra as Map<String, dynamic>;
            return const MainScaffold(
              child: CheckoutScreen(
                cartItems: [],
                subtotal: 0,
                tax: 0,
                shipping: 0,
                total: 0,
              ),
            );
          },
        ),
        GoRoute(
          path: '/product/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return MainScaffold(
              currentIndex: 1,
              child: ProductDetailScreen(productId: id),
            );
          },
        ),
        GoRoute(
          path: '/order-success/:orderId',
          name: 'order-success',
          builder: (context, state) {
            final orderId = state.pathParameters['orderId']!;
            return const MainScaffold(
              currentIndex: 0,
              child: OrderSuccessScreen(orderId: ''),
            );
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

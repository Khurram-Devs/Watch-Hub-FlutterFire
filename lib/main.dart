import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_hub_ep/screens/user/product_detail_screen.dart';

import 'firebase_options.dart';
import './theme/theme_provider.dart';
import './screens/user/home_screen.dart';
import './screens/user/catalog_screen.dart';
import './screens/user/redirect_auth_screen.dart';
import './screens/user/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    final GoRouter _router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/catalog',
          builder: (context, state) => const CatalogScreen(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => const RedirectAuthScreen(),
        ),
        GoRoute(
          path: '/product/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ProductDetailScreen(productId: id);
          },
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
    );
  }
}

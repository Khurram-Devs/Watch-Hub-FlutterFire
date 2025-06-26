import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import './theme/theme_provider.dart';
import './screens/user/home_screen.dart';
import './screens/admin/faq_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.lightTheme.copyWith(
        textTheme: GoogleFonts.audiowideTextTheme(),
      ),
      darkTheme: themeProvider.darkTheme.copyWith(
        textTheme: GoogleFonts.audiowideTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: themeProvider.themeMode,
      initialRoute: '/home',
      routes: {
        '/home': (_) => const HomeScreen(),
        '/faq': (_) => const FAQScreen(),
      },
    );
  }
}

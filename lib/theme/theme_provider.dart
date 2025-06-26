import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  static const Color goldenColor = Color(0xFFC0A265);

  TextTheme _customTextTheme(Brightness brightness) {
    final baseTextColor = brightness == Brightness.dark ? Colors.white : Colors.black;

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: baseTextColor,
      ),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: baseTextColor,
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseTextColor.withValues(alpha:0.9),
      ),
      titleSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: baseTextColor.withValues(alpha:0.85),
      ),
      bodyLarge: GoogleFonts.lato(
        fontSize: 16,
        color: baseTextColor.withValues(alpha:0.95),
      ),
      bodyMedium: GoogleFonts.lato(
        fontSize: 14,
        color: baseTextColor.withValues(alpha:0.85),
      ),
      bodySmall: GoogleFonts.lato(
        fontSize: 12,
        color: baseTextColor.withValues(alpha:0.7),
      ),
      labelSmall: GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: goldenColor,
      ),
    );
  }

  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.grey[200],
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          secondary: goldenColor,
        ),
        textTheme: _customTextTheme(Brightness.light),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      );

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        cardColor: const Color(0xFF1A1A1A),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: goldenColor,
        ),
        textTheme: _customTextTheme(Brightness.dark),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      );
}

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

  // ===== WatchHub Color Palette =====
  static const Color goldenAccent = Color(0xFFC8AB65);
  static const Color midnightPrimary = Color(0xFF1E1E1E);
  static const Color darkNavy = Color(0xFF121212);
  static const Color lightSurface = Color(0xFFF8F9FA);
  static const Color darkCard = Color(0xFF1F1F1F);
  static const Color softGray = Color(0xFF6B7280);
  static const Color errorRed = Colors.redAccent;

  static const Color lightTextBase = Color(0xFF1A1A1A); // Modern black
  static const Color darkTextBase = Color(0xFFF1F1F1); // Soft white

  // ===== Text Theme =====
  TextTheme _customTextTheme(Brightness brightness) {
    final baseColor =
        brightness == Brightness.dark ? darkTextBase : lightTextBase;

    return GoogleFonts.playfairDisplayTextTheme().copyWith(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseColor.withOpacity(0.9),
      ),
      titleSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: baseColor.withOpacity(0.85),
      ),
      bodyLarge: GoogleFonts.lato(
        fontSize: 16,
        color: baseColor.withOpacity(0.95),
      ),
      bodyMedium: GoogleFonts.lato(
        fontSize: 14,
        color: baseColor.withOpacity(0.85),
      ),
      bodySmall: GoogleFonts.lato(
        fontSize: 12,
        color: baseColor.withOpacity(0.7),
      ),
      labelSmall: GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: goldenAccent,
      ),
    );
  }

  // ===== Light Theme =====
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightSurface,
    cardColor: Colors.white,
    primaryColor: midnightPrimary,
    colorScheme: const ColorScheme.light(
      primary: midnightPrimary,
      secondary: goldenAccent,
      error: errorRed,
      background: lightSurface,
      surface: Colors.white,
    ),
    textTheme: _customTextTheme(Brightness.light),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightSurface,
      foregroundColor: midnightPrimary,
      elevation: 0,
    ),
    iconTheme: const IconThemeData(color: midnightPrimary),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: midnightPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: TextStyle(color: softGray.withOpacity(0.7)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: midnightPrimary),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey[200]!,
      labelStyle: const TextStyle(color: midnightPrimary),
      selectedColor: midnightPrimary.withOpacity(0.15),
      secondarySelectedColor: midnightPrimary,
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: midnightPrimary,
      unselectedLabelColor: softGray,
      indicatorColor: midnightPrimary,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: midnightPrimary,
      unselectedItemColor: softGray,
      backgroundColor: Colors.white,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Colors.black87,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
  );

  // ===== Dark Theme =====
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkNavy,
    cardColor: darkCard,
    primaryColor: goldenAccent,
    colorScheme: const ColorScheme.dark(
      primary: goldenAccent,
      secondary: goldenAccent, // Corrected secondary for contrast
      error: errorRed,
      background: darkNavy,
      surface: darkCard,
    ),
    textTheme: _customTextTheme(Brightness.dark),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkNavy,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    iconTheme: const IconThemeData(color: goldenAccent),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: goldenAccent,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      hintStyle: TextStyle(color: Colors.grey[400]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: goldenAccent),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: darkCard,
      labelStyle: const TextStyle(color: goldenAccent),
      selectedColor: goldenAccent.withOpacity(0.1),
      secondarySelectedColor: goldenAccent,
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: goldenAccent,
      unselectedLabelColor: Colors.grey,
      indicatorColor: goldenAccent,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: goldenAccent,
      unselectedItemColor: Colors.grey,
      backgroundColor: darkCard,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Colors.white,
      contentTextStyle: TextStyle(color: Colors.black),
    ),
  );
}

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
  static const Color emeraldGreen = Color(0xFF006400);
  static const Color lightBackground = Color(0xFFF6F5F3);
  static const Color darkBackground = Color(0xFF0E0E0E);
  static const Color darkCard = Color(0xFF1A1A1A);

  TextTheme _customTextTheme(Brightness brightness) {
    final baseTextColor = brightness == Brightness.dark ? Colors.white : Colors.black;

    return GoogleFonts.audiowideTextTheme().copyWith(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: baseTextColor),
      titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: baseTextColor),
      titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: baseTextColor.withOpacity(0.9)),
      titleSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: baseTextColor.withOpacity(0.85)),
      bodyLarge: GoogleFonts.lato(fontSize: 16, color: baseTextColor.withOpacity(0.95)),
      bodyMedium: GoogleFonts.lato(fontSize: 14, color: baseTextColor.withOpacity(0.85)),
      bodySmall: GoogleFonts.lato(fontSize: 12, color: baseTextColor.withOpacity(0.7)),
      labelSmall: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold, color: goldenColor),
    );
  }

  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: lightBackground,
        cardColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: emeraldGreen,
          secondary: goldenColor,
        ),
        textTheme: _customTextTheme(Brightness.light),
        appBarTheme: const AppBarTheme(
          backgroundColor: lightBackground,
          foregroundColor: emeraldGreen,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: emeraldGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.grey[200]!,
          labelStyle: const TextStyle(color: emeraldGreen),
          selectedColor: emeraldGreen.withOpacity(0.15),
          secondarySelectedColor: emeraldGreen,
        ),
      );

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBackground,
        cardColor: darkCard,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: goldenColor,
        ),
        textTheme: _customTextTheme(Brightness.dark),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBackground,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: goldenColor,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: darkCard,
          labelStyle: const TextStyle(color: goldenColor),
          selectedColor: goldenColor.withOpacity(0.1),
          secondarySelectedColor: goldenColor,
        ),
      );
}

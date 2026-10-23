import 'package:flutter/material.dart';

class AppTheme {
  static const Color lime = Color(0xFFB8F34A);
  static const Color darkGreen = Color(0xFF54852A);
  static const Color favoriteRed = Color(0xFFFF1744);

  static const Color darkBackground = Color(0xFF101110);
  static const Color darkCard = Color(0xFF202420);

  static const Color lightBackground = Color(0xFFF4F7EF);
  static const Color lightCard = Color(0xFFFFFFFF);

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: lime,
      secondary: lime,
      surface: darkCard,
      onSurface: Colors.white,
      error: favoriteRed,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkCard,
      colorScheme: scheme,
      dividerColor: Colors.white24,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: darkBackground,
        indicatorColor: Color(0xFF30382A),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        hintStyle: const TextStyle(color: Color(0xFFA7ADA4)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: darkGreen,
      secondary: darkGreen,
      surface: lightCard,
      onSurface: Color(0xFF20251D),
      error: favoriteRed,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      cardColor: lightCard,
      colorScheme: scheme,
      dividerColor: Colors.black12,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: Color(0xFF20251D),
        elevation: 0,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: lightCard,
        indicatorColor: Color(0xFFE3EED5),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCard,
        hintStyle: const TextStyle(color: Color(0xFF687064)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide.none,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
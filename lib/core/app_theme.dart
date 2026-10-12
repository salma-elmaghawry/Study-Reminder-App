import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF5B5BD6);
  static const primaryDark = Color(0xFF3E3BA8);
  static const accent = Color(0xFFFFB547);
  static const background = Color(0xFFF5F6FB);
  static const textDark = Color(0xFF1E1E2D);
  static const textMuted = Color(0xFF7A7A8C);

  static const heroGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: AppColors.background,
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

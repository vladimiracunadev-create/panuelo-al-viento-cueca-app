import 'package:flutter/material.dart';

abstract final class AppColors {
  static const navy = Color(0xFF173B63);
  static const blue = Color(0xFF2B6F9F);
  static const red = Color(0xFFD84A4A);
  static const yellow = Color(0xFFF2B544);
  static const cream = Color(0xFFF7EFE3);
  static const ink = Color(0xFF202A35);
  static const success = Color(0xFF32856D);
}

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      brightness: Brightness.light,
      primary: AppColors.navy,
      secondary: AppColors.red,
      tertiary: AppColors.yellow,
      surface: const Color(0xFFFFFBF6),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: _textTheme(Brightness.light),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 76,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.yellow,
      brightness: Brightness.dark,
      primary: const Color(0xFFAED3F0),
      secondary: const Color(0xFFFFB3AE),
      tertiary: AppColors.yellow,
      surface: const Color(0xFF19222C),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF111820),
      textTheme: _textTheme(Brightness.dark),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final base = ThemeData(brightness: brightness).textTheme;
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        height: 1.05,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.45),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.4),
    );
  }
}

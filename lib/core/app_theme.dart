import 'package:flutter/material.dart';

abstract final class AppColors {
  static const navy = Color(0xFF173B63);
  static const blue = Color(0xFF2B6F9F);
  static const red = Color(0xFFD84A4A);

  /// Rojo de interacción. El rojo de marca sobre blanco solo alcanza 4,2:1 y
  /// el pulso acentuado del laboratorio dibuja texto encima, así que la
  /// versión interactiva se oscurece hasta cumplir 4,5:1.
  static const redDeep = Color(0xFFB63535);
  static const yellow = Color(0xFFF2B544);
  static const cream = Color(0xFFF7EFE3);
  static const ink = Color(0xFF202A35);
  static const success = Color(0xFF32856D);
}

/// Paleta de la aplicación.
///
/// Los roles `*Container` se declaran a mano en los dos modos. Generarlos solo
/// con `ColorScheme.fromSeed` produce contenedores que no tienen relación con
/// el color al que acompañan —un `tertiaryContainer` verde junto a un
/// `tertiary` amarillo, por ejemplo— porque sobrescribir `primary`,
/// `secondary` o `tertiary` no regenera sus contenedores. En modo oscuro esa
/// deriva se veía como tarjetas ocre apagado sobre un fondo azulado.
abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.navy,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD3E3FF),
      onPrimaryContainer: const Color(0xFF10294A),
      secondary: AppColors.redDeep,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFD8E3F8),
      onSecondaryContainer: const Color(0xFF16283F),
      tertiary: AppColors.yellow,
      onTertiary: const Color(0xFF3A2A00),
      tertiaryContainer: const Color(0xFFF6D9FF),
      onTertiaryContainer: const Color(0xFF3A2842),
      surface: const Color(0xFFFFFBF6),
      onSurface: const Color(0xFF191C20),
      surfaceContainerHighest: const Color(0xFFE1E2E9),
      onSurfaceVariant: const Color(0xFF43474E),
    );

    return _base(scheme, AppColors.cream, Brightness.light).copyWith(
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
    // Cada contenedor es la versión profunda del mismo tono que ocupa esa
    // ranura en modo claro, para que las dos paletas sean la misma idea con
    // distinta luz en vez de dos diseños distintos.
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFAED3F0),
      onPrimary: const Color(0xFF06243D),
      primaryContainer: const Color(0xFF1E3A5C),
      onPrimaryContainer: const Color(0xFFD3E3FF),
      secondary: const Color(0xFFFFB3AE),
      onSecondary: const Color(0xFF4A1310),
      secondaryContainer: const Color(0xFF2B3A4E),
      onSecondaryContainer: const Color(0xFFDCE6F6),
      tertiary: AppColors.yellow,
      onTertiary: const Color(0xFF3A2A00),
      tertiaryContainer: const Color(0xFF3E2E48),
      onTertiaryContainer: const Color(0xFFF2DBFB),
      surface: const Color(0xFF19222C),
      onSurface: const Color(0xFFE6EAF0),
      surfaceContainerHighest: const Color(0xFF263140),
      onSurfaceVariant: const Color(0xFFC2CCD9),
      outline: const Color(0xFF7C8A9C),
    );

    return _base(scheme, const Color(0xFF111820), Brightness.dark).copyWith(
      navigationBarTheme: const NavigationBarThemeData(
        height: 76,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }

  static ThemeData _base(
    ColorScheme scheme,
    Color scaffold,
    Brightness brightness,
  ) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: _textTheme(brightness),
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

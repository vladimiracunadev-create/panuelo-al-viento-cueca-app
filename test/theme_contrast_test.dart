import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panuelo_al_viento/core/app_theme.dart';

/// Relación de contraste WCAG 2.1 entre dos colores opacos.
double contrastRatio(Color foreground, Color background) {
  final a = _relativeLuminance(foreground);
  final b = _relativeLuminance(background);
  final lighter = math.max(a, b);
  final darker = math.min(a, b);
  return (lighter + 0.05) / (darker + 0.05);
}

double _relativeLuminance(Color color) {
  double channel(double value) {
    return value <= 0.03928
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

/// Las tarjetas de la aplicación pintan un color de contenedor y dejan que el
/// texto herede `onSurface`, que es lo que hace `Card` de Material 3 cuando se
/// le pasa un `color` propio. Por eso el par que hay que medir no es
/// `(primaryContainer, onPrimaryContainer)` sino el que realmente se dibuja.
void main() {
  const minimumBodyContrast = 4.5; // WCAG AA para texto normal.

  for (final entry
      in {'claro': AppTheme.light, 'oscuro': AppTheme.dark}.entries) {
    final label = entry.key;
    final scheme = entry.value.colorScheme;

    final surfaces = <String, Color>{
      'scaffold': entry.value.scaffoldBackgroundColor,
      'surface': scheme.surface,
      'primaryContainer': scheme.primaryContainer,
      'secondaryContainer': scheme.secondaryContainer,
      'tertiaryContainer': scheme.tertiaryContainer,
      'surfaceContainerHighest': scheme.surfaceContainerHighest,
    };

    surfaces.forEach((name, background) {
      test('modo $label: el texto se lee sobre $name', () {
        final ratio = contrastRatio(scheme.onSurface, background);
        expect(
          ratio,
          greaterThanOrEqualTo(minimumBodyContrast),
          reason:
              'onSurface sobre $name da $ratio:1 en modo $label y necesita '
              '$minimumBodyContrast:1. Las tarjetas heredan onSurface.',
        );
      });
    });

    test('modo $label: el pulso acentuado se lee dentro del círculo', () {
      final ratio = contrastRatio(scheme.onSecondary, scheme.secondary);
      expect(
        ratio,
        greaterThanOrEqualTo(minimumBodyContrast),
        reason: 'onSecondary sobre secondary da $ratio:1 en modo $label.',
      );
    });

    test('modo $label: los contenedores se distinguen del fondo', () {
      final background = entry.value.scaffoldBackgroundColor;
      for (final name in const [
        'primaryContainer',
        'tertiaryContainer',
        'surfaceContainerHighest',
      ]) {
        final ratio = contrastRatio(surfaces[name]!, background);
        expect(
          ratio,
          greaterThanOrEqualTo(1.12),
          reason:
              '$name se confunde con el fondo en modo $label ($ratio:1). '
              'Una tarjeta que no se ve deja de ser una tarjeta.',
        );
      }
    });
  }
}

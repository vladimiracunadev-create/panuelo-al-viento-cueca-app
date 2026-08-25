import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class MovementDiagram extends StatelessWidget {
  const MovementDiagram({required this.pattern, super.key});

  final String pattern;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _description(pattern),
      image: true,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CustomPaint(
          painter: _MovementPainter(
            pattern: pattern,
            darkMode: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      ),
    );
  }

  String _description(String value) {
    return switch (value) {
      'circle' => 'Diagrama de una vuelta circular alrededor de la pareja.',
      'eight' => 'Diagrama de un recorrido con forma de ocho.',
      'semicircle' => 'Diagrama de dos medialunas frente a frente.',
      'steps' => 'Diagrama de pasos breves alternados.',
      'pair' => 'Diagrama de dos personas dialogando con distancia.',
      'wave' => 'Diagrama del movimiento suave del pañuelo.',
      _ => 'Espacio personal para practicar un movimiento libre.',
    };
  }
}

class _MovementPainter extends CustomPainter {
  _MovementPainter({required this.pattern, required this.darkMode});

  final String pattern;
  final bool darkMode;

  @override
  void paint(Canvas canvas, Size size) {
    final background =
        Paint()
          ..color =
              darkMode ? const Color(0xFF22303C) : const Color(0xFFFFFBF6);
    final border =
        Paint()
          ..color = darkMode ? const Color(0xFF5B6B78) : const Color(0xFFD8CBB9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    final route =
        Paint()
          ..color = darkMode ? const Color(0xFFAED3F0) : AppColors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round;

    final stage = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(24),
    );
    canvas.drawRRect(stage, background);
    canvas.drawRRect(stage.deflate(1), border);

    final center = Offset(size.width / 2, size.height / 2);
    final left = Offset(size.width * .32, size.height * .52);
    final right = Offset(size.width * .68, size.height * .48);

    switch (pattern) {
      case 'circle':
        canvas.drawOval(
          Rect.fromCenter(
            center: center,
            width: size.width * .56,
            height: size.height * .62,
          ),
          route,
        );
        break;
      case 'eight':
        final eightPath = Path()..moveTo(center.dx, center.dy);
        for (double t = 0; t <= math.pi * 2; t += .03) {
          final x = center.dx + math.sin(t) * size.width * .25;
          final y = center.dy + math.sin(t * 2) * size.height * .25;
          eightPath.lineTo(x, y);
        }
        canvas.drawPath(eightPath, route);
        break;
      case 'semicircle':
        canvas.drawArc(
          Rect.fromCenter(
            center: left,
            width: size.width * .35,
            height: size.height * .62,
          ),
          -math.pi / 2,
          math.pi,
          false,
          route,
        );
        canvas.drawArc(
          Rect.fromCenter(
            center: right,
            width: size.width * .35,
            height: size.height * .62,
          ),
          math.pi / 2,
          math.pi,
          false,
          route,
        );
        break;
      case 'steps':
        for (var i = 0; i < 5; i++) {
          final x = size.width * (.2 + i * .15);
          final y = size.height * (i.isEven ? .4 : .6);
          canvas.drawCircle(Offset(x, y), 8, route..style = PaintingStyle.fill);
        }
        route.style = PaintingStyle.stroke;
        break;
      case 'wave':
        final wavePath = Path()..moveTo(size.width * .16, center.dy);
        wavePath.cubicTo(
          size.width * .32,
          size.height * .18,
          size.width * .48,
          size.height * .82,
          size.width * .64,
          center.dy,
        );
        wavePath.cubicTo(
          size.width * .76,
          size.height * .3,
          size.width * .84,
          size.height * .38,
          size.width * .88,
          size.height * .48,
        );
        canvas.drawPath(wavePath, route);
        break;
      default:
        canvas.drawLine(left, right, route..strokeWidth = 2);
        break;
    }

    _drawDancer(canvas, left, AppColors.red);
    _drawDancer(canvas, right, AppColors.blue);
  }

  void _drawDancer(Canvas canvas, Offset at, Color color) {
    final fill = Paint()..color = color;
    canvas.drawCircle(at, 12, fill);
    canvas.drawCircle(at.translate(0, -20), 7, fill);
  }

  @override
  bool shouldRepaint(covariant _MovementPainter oldDelegate) {
    return oldDelegate.pattern != pattern || oldDelegate.darkMode != darkMode;
  }
}

import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/curriculum.dart';

/// Lee el currículo del paquete de activos de la aplicación.
///
/// Usa `rootBundle` y no el sistema de archivos: el contenido viaja dentro de
/// la instalación y debe leerse igual en Android, en Windows y en las pruebas.
/// Esa elección también es lo que mantiene al producto sin acceso general a
/// archivos del dispositivo.
///
/// No captura errores. Si el activo falta o el JSON es inválido, la excepción
/// sube hasta `main`, que muestra una pantalla de recuperación en vez de dejar
/// la aplicación en blanco.
class CurriculumRepository {
  const CurriculumRepository();

  Future<Curriculum> load() async {
    final source = await rootBundle.loadString(
      'assets/content/curriculum.json',
    );
    final json = jsonDecode(source) as Map<String, dynamic>;
    return Curriculum.fromJson(json);
  }
}

import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/content/curriculum.json');
  final errors = <String>[];

  if (!file.existsSync()) {
    stderr.writeln('No existe ${file.path}. Ejecuta desde la raíz del repositorio.');
    exitCode = 1;
    return;
  }

  final root = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final levels = root['levels'] as List<dynamic>? ?? const [];
  final lessons = <Map<String, dynamic>>[];
  final levelIds = <String>{};

  if (levels.length != 8) {
    errors.add('Se esperaban 8 niveles y hay ${levels.length}.');
  }

  for (final rawLevel in levels) {
    final level = rawLevel as Map<String, dynamic>;
    final id = level['id'] as String? ?? '';
    if (id.isEmpty || !levelIds.add(id)) {
      errors.add('Identificador de nivel vacío o repetido: "$id".');
    }
    final levelLessons = level['lessons'] as List<dynamic>? ?? const [];
    if (levelLessons.length != 3) {
      errors.add('El nivel $id debe contener 3 clases.');
    }
    lessons.addAll(levelLessons.cast<Map<String, dynamic>>());
  }

  if (lessons.length != 24) {
    errors.add('Se esperaban 24 clases y hay ${lessons.length}.');
  }

  final ids = <String>{};
  final orders = <int>{};
  for (final lesson in lessons) {
    final id = lesson['id'] as String? ?? '';
    final order = lesson['order'] as int? ?? -1;
    final duration = lesson['durationMinutes'] as int? ?? 0;
    final activities = lesson['activities'] as List<dynamic>? ?? const [];

    if (id.isEmpty || !ids.add(id)) {
      errors.add('Identificador de clase vacío o repetido: "$id".');
    }
    if (!orders.add(order)) {
      errors.add('Orden de clase repetido: $order.');
    }
    if (activities.length != 3) {
      errors.add('$id debe contener exactamente 3 actividades.');
    }

    final activityMinutes = activities.fold<int>(0, (sum, rawActivity) {
      final activity = rawActivity as Map<String, dynamic>;
      return sum + (activity['minutes'] as int? ?? 0);
    });
    if (activityMinutes != duration) {
      errors.add('$id dura $duration min, pero sus actividades suman $activityMinutes.');
    }

    for (final field in [
      'title',
      'objective',
      'why',
      'diagram',
      'challenge',
      'safety',
      'accessibility',
      'teacherTip',
    ]) {
      final value = lesson[field];
      if (value is! String || value.trim().isEmpty) {
        errors.add('$id no tiene un valor válido para "$field".');
      }
    }
  }

  final expectedOrders = {for (var index = 1; index <= 24; index++) index};
  if (orders.length != expectedOrders.length || !orders.containsAll(expectedOrders)) {
    errors.add('Los órdenes deben cubrir 1–24 sin saltos.');
  }

  if (errors.isNotEmpty) {
    stderr.writeln('Currículo inválido:');
    for (final error in errors) {
      stderr.writeln('- $error');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'Currículo válido: ${levels.length} niveles, ${lessons.length} clases y '
    '${lessons.length * 3} actividades.',
  );
}

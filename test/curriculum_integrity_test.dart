import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:panuelo_al_viento/domain/curriculum.dart';

void main() {
  late Curriculum curriculum;

  setUpAll(() {
    final source = File('assets/content/curriculum.json').readAsStringSync();
    curriculum = Curriculum.fromJson(
      jsonDecode(source) as Map<String, dynamic>,
    );
  });

  test('contiene 8 niveles, 24 clases y órdenes continuos', () {
    expect(curriculum.levels, hasLength(8));
    expect(curriculum.lessons, hasLength(24));
    expect(
      curriculum.lessons.map((lesson) => lesson.order),
      orderedEquals(List.generate(24, (index) => index + 1)),
    );
  });

  test('cada clase tiene tres actividades que completan su duración', () {
    for (final lesson in curriculum.lessons) {
      expect(lesson.activities, hasLength(3), reason: lesson.id);
      final minutes = lesson.activities.fold<int>(
        0,
        (sum, activity) => sum + activity.minutes,
      );
      expect(minutes, lesson.durationMinutes, reason: lesson.id);
      expect(
        lesson.durationMinutes,
        inInclusiveRange(10, 15),
        reason: lesson.id,
      );
    }
  });

  test('todos los identificadores son únicos', () {
    final ids = curriculum.lessons.map((lesson) => lesson.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
  });
}

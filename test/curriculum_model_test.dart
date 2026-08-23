import 'package:flutter_test/flutter_test.dart';
import 'package:panuelo_al_viento/domain/curriculum.dart';

void main() {
  test('convierte una clase JSON en un modelo inmutable', () {
    final lesson = Lesson.fromJson({
      'id': 'lesson-test',
      'order': 1,
      'title': 'Clase de prueba',
      'durationMinutes': 12,
      'objective': 'Probar el modelo.',
      'why': 'Permite comprobar la carga.',
      'diagram': 'pair',
      'activities': [
        {
          'type': 'discover',
          'title': 'Uno',
          'instruction': 'Primera actividad.',
          'minutes': 3,
        },
        {
          'type': 'move',
          'title': 'Dos',
          'instruction': 'Segunda actividad.',
          'minutes': 5,
        },
        {
          'type': 'reflect',
          'title': 'Tres',
          'instruction': 'Tercera actividad.',
          'minutes': 4,
        },
      ],
      'challenge': 'Un reto.',
      'safety': 'Una regla.',
      'accessibility': 'Una alternativa.',
      'teacherTip': 'Una orientación.',
    });

    expect(lesson.id, 'lesson-test');
    expect(lesson.activities, hasLength(3));
    expect(lesson.activities[1].type, ActivityType.move);
    expect(
      lesson.activities.fold<int>(0, (sum, activity) => sum + activity.minutes),
      lesson.durationMinutes,
    );
  });
}

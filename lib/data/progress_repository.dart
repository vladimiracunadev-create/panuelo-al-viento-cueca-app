import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ProgressStore {
  Set<String> readCompletedLessonIds();

  Future<void> writeCompletedLessonIds(Set<String> lessonIds);

  Future<void> clear();
}

class ProgressRepository implements ProgressStore {
  ProgressRepository(this._preferences);

  static const _completedKey = 'completed_lessons_v1';
  final SharedPreferences _preferences;

  Set<String> readCompletedLessonIds() {
    return (_preferences.getStringList(_completedKey) ?? const <String>[])
        .toSet();
  }

  Future<void> writeCompletedLessonIds(Set<String> lessonIds) async {
    final ordered = lessonIds.toList(growable: false)..sort();
    final saved = await _preferences.setStringList(_completedKey, ordered);
    if (!saved) {
      throw StateError('No fue posible guardar el avance en este dispositivo.');
    }
  }

  Future<void> clear() async {
    final removed = await _preferences.remove(_completedKey);
    if (!removed) {
      throw StateError('No fue posible borrar el avance de este dispositivo.');
    }
  }
}

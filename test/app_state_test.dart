import 'package:flutter_test/flutter_test.dart';
import 'package:panuelo_al_viento/data/curriculum_repository.dart';
import 'package:panuelo_al_viento/data/progress_repository.dart';
import 'package:panuelo_al_viento/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('rechaza una clase inexistente sin alterar el avance', () async {
    final store = _MemoryProgressStore();
    final state = AppState(
      curriculumRepository: const CurriculumRepository(),
      progressRepository: store,
    );
    await state.load();

    await expectLater(
      state.completeLesson('lesson-inexistente'),
      throwsArgumentError,
    );
    expect(state.completedLessonIds, isEmpty);
    expect(store.values, isEmpty);
  });

  test('solo publica el avance después de guardarlo correctamente', () async {
    final store = _MemoryProgressStore(failWrites: true);
    final state = AppState(
      curriculumRepository: const CurriculumRepository(),
      progressRepository: store,
    );
    await state.load();

    await expectLater(state.completeLesson('lesson-01'), throwsStateError);
    expect(state.completedLessonIds, isEmpty);
  });

  test(
    'solo borra el avance en memoria después de borrar el guardado',
    () async {
      final store = _MemoryProgressStore(values: {'lesson-01'});
      final state = AppState(
        curriculumRepository: const CurriculumRepository(),
        progressRepository: store,
      );
      await state.load();
      store.failClears = true;

      await expectLater(state.resetProgress(), throwsStateError);
      expect(state.completedLessonIds, {'lesson-01'});
    },
  );
}

class _MemoryProgressStore implements ProgressStore {
  _MemoryProgressStore({Set<String>? values, this.failWrites = false})
    : values = {...?values};

  Set<String> values;
  bool failWrites;
  bool failClears = false;

  @override
  Future<void> clear() async {
    if (failClears) {
      throw StateError('fallo simulado');
    }
    values = <String>{};
  }

  @override
  Set<String> readCompletedLessonIds() => {...values};

  @override
  Future<void> writeCompletedLessonIds(Set<String> lessonIds) async {
    if (failWrites) {
      throw StateError('fallo simulado');
    }
    values = {...lessonIds};
  }
}

import 'package:flutter/foundation.dart';

import '../data/curriculum_repository.dart';
import '../data/progress_repository.dart';
import '../domain/curriculum.dart';

/// Estado único de la aplicación: currículo cargado y avance del usuario.
///
/// Es un `ChangeNotifier` deliberadamente pequeño, sin contenedor de
/// inyección: la aplicación tiene una sola fuente de estado y se pasa a mano
/// desde `main`. Añadir un gestor de estado global no resolvería ningún
/// problema que este proyecto tenga hoy.
///
/// La regla que sostiene todo lo demás: **el estado en memoria solo cambia
/// después de que la persistencia confirme**. Ver [completeLesson] y
/// [resetProgress]. Invertir ese orden produciría el fallo más caro posible
/// aquí: una clase que se ve completada y desaparece al reabrir la aplicación.
class AppState extends ChangeNotifier {
  AppState({
    required CurriculumRepository curriculumRepository,
    required ProgressStore progressRepository,
  }) : _curriculumRepository = curriculumRepository,
       _progressRepository = progressRepository;

  final CurriculumRepository _curriculumRepository;
  final ProgressStore _progressRepository;

  Curriculum? _curriculum;
  Set<String> _completedLessonIds = <String>{};

  /// El currículo cargado.
  ///
  /// Lanza si se consulta antes de [load]. Es intencionado: un `null` silencioso
  /// aquí se propagaría a toda la interfaz. `main` llama a [load] antes de
  /// construir la aplicación, así que ninguna pantalla puede llegar a este
  /// estado por el camino normal.
  Curriculum get curriculum {
    final value = _curriculum;
    if (value == null) {
      throw StateError('El currículo todavía no está cargado.');
    }
    return value;
  }

  Set<String> get completedLessonIds => Set.unmodifiable(_completedLessonIds);
  int get completedCount => _completedLessonIds.length;
  int get totalCount => curriculum.lessons.length;
  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;

  /// Primera clase no completada en orden global, o `null` si no queda ninguna.
  ///
  /// Es un avance por hueco, no por posición: si alguien completa la clase 5
  /// antes que la 3, la próxima sigue siendo la 3. La ruta no bloquea clases,
  /// así que este valor es una sugerencia, no una puerta.
  Lesson? get nextLesson {
    for (final lesson in curriculum.lessons) {
      if (!_completedLessonIds.contains(lesson.id)) {
        return lesson;
      }
    }
    return null;
  }

  /// Carga el currículo y recupera el avance guardado.
  ///
  /// El avance leído se cruza con los identificadores que el currículo actual
  /// declara válidos. Así, una clase retirada o renombrada en una versión
  /// posterior no queda contada como completada para siempre ni inflando el
  /// porcentaje. El descarte es silencioso y **no reescribe** el almacén: los
  /// identificadores desconocidos siguen en disco hasta la próxima escritura.
  Future<void> load() async {
    _curriculum = await _curriculumRepository.load();
    final validIds = curriculum.lessons.map((lesson) => lesson.id).toSet();
    _completedLessonIds = _progressRepository
        .readCompletedLessonIds()
        .intersection(validIds);
    notifyListeners();
  }

  bool isCompleted(String lessonId) => _completedLessonIds.contains(lessonId);

  double levelProgress(LearningLevel level) {
    if (level.lessons.isEmpty) {
      return 0;
    }
    final count =
        level.lessons.where((lesson) => isCompleted(lesson.id)).length;
    return count / level.lessons.length;
  }

  /// Marca una clase como completada.
  ///
  /// Rechaza con `ArgumentError` un identificador que el currículo no declara,
  /// para que un error de contenido no contamine el almacén persistente. Si la
  /// clase ya estaba completada no vuelve a escribir: repetir una clase es
  /// parte del diseño pedagógico y no debe generar tráfico ni notificaciones.
  ///
  /// Riesgo al modificar: si se publica `_completedLessonIds` antes del `await`
  /// de la escritura, un fallo de disco deja la interfaz mintiendo. Las pruebas
  /// de `test/app_state_test.dart` existen exactamente para impedir ese cambio.
  Future<void> completeLesson(String lessonId) async {
    final validIds = curriculum.lessons.map((lesson) => lesson.id).toSet();
    if (!validIds.contains(lessonId)) {
      throw ArgumentError.value(lessonId, 'lessonId', 'La clase no existe.');
    }
    if (_completedLessonIds.contains(lessonId)) {
      return;
    }

    final updated = {..._completedLessonIds, lessonId};
    await _progressRepository.writeCompletedLessonIds(updated);
    _completedLessonIds = updated;
    notifyListeners();
  }

  /// Borra todo el avance local, con el mismo orden que [completeLesson].
  ///
  /// Si el borrado falla, el avance visible se mantiene: es preferible a
  /// mostrar cero clases y que reaparezcan al reiniciar. La confirmación de la
  /// persona usuaria ocurre antes, en la pantalla Mi avance.
  Future<void> resetProgress() async {
    await _progressRepository.clear();
    _completedLessonIds = <String>{};
    notifyListeners();
  }
}

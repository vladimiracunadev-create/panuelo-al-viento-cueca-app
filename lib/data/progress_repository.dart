import 'package:shared_preferences/shared_preferences.dart';

/// Contrato de almacenamiento del avance.
///
/// Existe para que `AppState` pueda probarse contra una implementación en
/// memoria que simule fallos de escritura y de borrado. Ese es el motivo de
/// que la interfaz esté separada de [ProgressRepository]: la regla que hay que
/// proteger —no publicar en la interfaz un avance que el disco no confirmó—
/// solo se puede verificar si el fallo se puede provocar.
///
/// Regla del contrato: [writeCompletedLessonIds] y [clear] **lanzan** cuando la
/// operación no se confirma. Devolver sin más sería indistinguible del éxito.
abstract interface class ProgressStore {
  Set<String> readCompletedLessonIds();

  Future<void> writeCompletedLessonIds(Set<String> lessonIds);

  Future<void> clear();
}

/// Persistencia del avance sobre las preferencias del sistema.
///
/// Guarda únicamente identificadores de clases completadas. No conserva
/// nombre, edad, tiempos de práctica, puntuaciones ni ningún dato que
/// identifique a una persona; ese límite es parte del producto y está
/// documentado en `docs/PRIVACY.md`.
///
/// En Windows los datos viven en el perfil del usuario, fuera de la carpeta de
/// instalación: por eso la versión portable también recuerda el avance.
class ProgressRepository implements ProgressStore {
  ProgressRepository(this._preferences);

  /// Clave versionada del almacén.
  ///
  /// El sufijo `_v1` reserva la posibilidad de migrar el formato sin leer un
  /// valor antiguo con la forma equivocada. Cambiarla deja huérfano el avance
  /// ya guardado en los dispositivos instalados.
  static const _completedKey = 'completed_lessons_v1';
  final SharedPreferences _preferences;

  @override
  Set<String> readCompletedLessonIds() {
    return (_preferences.getStringList(_completedKey) ?? const <String>[])
        .toSet();
  }

  @override
  /// Guarda el conjunto completo, ordenado, y lanza si no se confirmó.
  ///
  /// Se ordena antes de escribir para que dos ejecuciones con el mismo avance
  /// produzcan el mismo valor almacenado; eso hace comparables las lecturas en
  /// las pruebas.
  Future<void> writeCompletedLessonIds(Set<String> lessonIds) async {
    final ordered = lessonIds.toList(growable: false)..sort();
    final saved = await _preferences.setStringList(_completedKey, ordered);
    if (!saved) {
      throw StateError('No fue posible guardar el avance en este dispositivo.');
    }
  }

  @override
  Future<void> clear() async {
    final removed = await _preferences.remove(_completedKey);
    if (!removed) {
      throw StateError('No fue posible borrar el avance de este dispositivo.');
    }
  }
}

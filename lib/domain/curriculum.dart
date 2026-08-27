/// Modelos inmutables del currículo.
///
/// Son el contrato entre `assets/content/curriculum.json` y el resto de la
/// aplicación. No dependen de Flutter a propósito: así las pruebas de
/// integridad pueden construirlos leyendo el JSON directamente, sin levantar
/// un entorno de widgets.
///
/// Ninguna fábrica `fromJson` tolera campos ausentes: un currículo incompleto
/// debe romper al cargar y no producir una clase a medias que llegue a la
/// interfaz. Quien edita el JSON tiene dos validadores que avisan antes
/// (`tool/validate_curriculum.mjs` y `tool/validate_curriculum.dart`).
library;

/// Naturaleza pedagógica de una actividad dentro de una clase.
///
/// Hoy solo alimenta la redacción del contenido: la interfaz no ramifica por
/// este valor. Se conserva porque es la dimensión con la que el currículo
/// equilibra la secuencia mostrar o descubrir -> practicar -> interpretar.
enum ActivityType { discover, observe, move, listen, create, reflect }

/// Traduce el campo `type` del JSON a [ActivityType].
///
/// Degrada a [ActivityType.discover] ante un valor desconocido en vez de
/// lanzar. La decisión es deliberada: un `type` mal escrito no debe impedir
/// que una clase se abra, porque el valor no cambia lo que se muestra. El
/// control estricto de este campo vive en los validadores, no en tiempo de
/// ejecución.
ActivityType activityTypeFromJson(String value) {
  return ActivityType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => ActivityType.discover,
  );
}

/// Una de las tres actividades cronometradas de una clase.
///
/// Los validadores exigen que los [minutes] de las tres actividades sumen
/// exactamente el `durationMinutes` de la clase que las contiene.
class LearningActivity {
  const LearningActivity({
    required this.type,
    required this.title,
    required this.instruction,
    required this.minutes,
  });

  final ActivityType type;
  final String title;
  final String instruction;
  final int minutes;

  factory LearningActivity.fromJson(Map<String, dynamic> json) {
    return LearningActivity(
      type: activityTypeFromJson(json['type'] as String),
      title: json['title'] as String,
      instruction: json['instruction'] as String,
      minutes: json['minutes'] as int,
    );
  }
}

/// Una clase de la ruta de aprendizaje.
///
/// [order] es la posición global dentro de las 24 clases, no dentro del nivel:
/// es el número que se dibuja en la tarjeta y el que decide cuál es la próxima
/// clase pendiente. [diagram] es una clave de patrón que interpreta
/// `MovementDiagram`; un valor sin dibujo propio degrada a un esquema genérico
/// en vez de fallar.
///
/// Los campos [safety], [accessibility] y [teacherTip] son obligatorios por
/// decisión pedagógica, no técnica: una actividad corporal sin advertencia de
/// seguridad ni equivalencia accesible no debe poder publicarse.
class Lesson {
  const Lesson({
    required this.id,
    required this.order,
    required this.title,
    required this.durationMinutes,
    required this.objective,
    required this.why,
    required this.diagram,
    required this.activities,
    required this.challenge,
    required this.safety,
    required this.accessibility,
    required this.teacherTip,
  });

  final String id;
  final int order;
  final String title;
  final int durationMinutes;
  final String objective;
  final String why;
  final String diagram;
  final List<LearningActivity> activities;
  final String challenge;
  final String safety;
  final String accessibility;
  final String teacherTip;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      order: json['order'] as int,
      title: json['title'] as String,
      durationMinutes: json['durationMinutes'] as int,
      objective: json['objective'] as String,
      why: json['why'] as String,
      diagram: json['diagram'] as String,
      activities: (json['activities'] as List<dynamic>)
          .map(
            (item) => LearningActivity.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      challenge: json['challenge'] as String,
      safety: json['safety'] as String,
      accessibility: json['accessibility'] as String,
      teacherTip: json['teacherTip'] as String,
    );
  }
}

/// Un nivel: tres clases agrupadas bajo un mismo foco temático.
class LearningLevel {
  const LearningLevel({
    required this.id,
    required this.order,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.lessons,
  });

  final String id;
  final int order;
  final String title;
  final String subtitle;
  final String emoji;
  final List<Lesson> lessons;

  factory LearningLevel.fromJson(Map<String, dynamic> json) {
    return LearningLevel(
      id: json['id'] as String,
      order: json['order'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      emoji: json['emoji'] as String,
      lessons: (json['lessons'] as List<dynamic>)
          .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

/// Raíz del contenido: la ruta completa de niveles y clases.
///
/// [version] es la versión del currículo y es independiente de la versión de
/// la aplicación que declara `pubspec.yaml`. Confundirlas al leer el JSON es
/// un error fácil de cometer.
class Curriculum {
  const Curriculum({
    required this.version,
    required this.title,
    required this.audience,
    required this.levels,
  });

  final String version;
  final String title;
  final String audience;
  final List<LearningLevel> levels;

  /// Todas las clases de todos los niveles, ordenadas por [Lesson.order].
  ///
  /// Construye y ordena una lista nueva en cada llamada. Con 24 clases el
  /// coste es irrelevante, pero conviene saberlo antes de invocarlo dentro de
  /// un bucle de dibujo.
  List<Lesson> get lessons =>
      levels.expand((level) => level.lessons).toList(growable: false)
        ..sort((a, b) => a.order.compareTo(b.order));

  factory Curriculum.fromJson(Map<String, dynamic> json) {
    return Curriculum(
      version: json['version'] as String,
      title: json['title'] as String,
      audience: json['audience'] as String,
      levels: (json['levels'] as List<dynamic>)
          .map((item) => LearningLevel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

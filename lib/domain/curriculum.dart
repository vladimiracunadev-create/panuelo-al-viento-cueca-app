enum ActivityType { discover, observe, move, listen, create, reflect }

ActivityType activityTypeFromJson(String value) {
  return ActivityType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => ActivityType.discover,
  );
}

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
            (item) => LearningActivity.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false),
      challenge: json['challenge'] as String,
      safety: json['safety'] as String,
      accessibility: json['accessibility'] as String,
      teacherTip: json['teacherTip'] as String,
    );
  }
}

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

  List<Lesson> get lessons => levels
      .expand((level) => level.lessons)
      .toList(growable: false)
    ..sort((a, b) => a.order.compareTo(b.order));

  factory Curriculum.fromJson(Map<String, dynamic> json) {
    return Curriculum(
      version: json['version'] as String,
      title: json['title'] as String,
      audience: json['audience'] as String,
      levels: (json['levels'] as List<dynamic>)
          .map(
            (item) => LearningLevel.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }
}

import 'package:flutter/foundation.dart';

import '../data/curriculum_repository.dart';
import '../data/progress_repository.dart';
import '../domain/curriculum.dart';

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

  Lesson? get nextLesson {
    for (final lesson in curriculum.lessons) {
      if (!_completedLessonIds.contains(lesson.id)) {
        return lesson;
      }
    }
    return null;
  }

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

  Future<void> resetProgress() async {
    await _progressRepository.clear();
    _completedLessonIds = <String>{};
    notifyListeners();
  }
}

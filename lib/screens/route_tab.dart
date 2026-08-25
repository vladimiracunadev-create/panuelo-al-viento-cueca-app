import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../widgets/lesson_card.dart';
import 'lesson_screen.dart';

class RouteTab extends StatelessWidget {
  const RouteTab({required this.state, super.key});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          automaticallyImplyLeading: false,
          title: const Text('Ruta de aprendizaje'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          sliver: SliverList.separated(
            itemCount: state.curriculum.levels.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final level = state.curriculum.levels[index];
              final progress = state.levelProgress(level);
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: ExpansionTile(
                      initiallyExpanded:
                          index == 0 || (progress > 0 && progress < 1),
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                      leading: Text(
                        level.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                      title: Text(
                        'Nivel ${level.order} · ${level.title}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(level.subtitle),
                      ),
                      trailing: _LevelProgress(value: progress),
                      children: [
                        for (final lesson in level.lessons) ...[
                          LessonCard(
                            lesson: lesson,
                            completed: state.isCompleted(lesson.id),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder:
                                      (_) => LessonScreen(
                                        state: state,
                                        lesson: lesson,
                                      ),
                                ),
                              );
                            },
                          ),
                          if (lesson != level.lessons.last)
                            const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LevelProgress extends StatelessWidget {
  const _LevelProgress({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();
    return Semantics(
      label: '$percent por ciento del nivel completado',
      child: SizedBox.square(
        dimension: 46,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(value: value, strokeWidth: 5),
            Text(
              '$percent',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../domain/curriculum.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({
    required this.lesson,
    required this.completed,
    required this.onTap,
    super.key,
  });

  final Lesson lesson;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: completed
                      ? colors.primaryContainer
                      : colors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: completed
                    ? Icon(Icons.check_rounded, color: colors.primary)
                    : Text(
                        '${lesson.order}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${lesson.durationMinutes} min · ${lesson.objective}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

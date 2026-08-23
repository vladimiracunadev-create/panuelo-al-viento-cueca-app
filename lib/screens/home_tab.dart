import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../domain/curriculum.dart';
import '../state/app_state.dart';
import '../widgets/lesson_card.dart';
import 'lesson_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({
    required this.state,
    required this.onOpenRoute,
    required this.onOpenRhythm,
    super.key,
  });

  final AppState state;
  final VoidCallback onOpenRoute;
  final VoidCallback onOpenRhythm;

  @override
  Widget build(BuildContext context) {
    final nextLesson = state.nextLesson;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 20,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 43,
                      backgroundColor: AppColors.yellow,
                      child: Icon(Icons.air_rounded, size: 48, color: AppColors.navy),
                    ),
                    SizedBox(
                      width: 610,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Que baile el pañuelo!',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Aprende cueca paso a paso, escucha el ritmo y crea tu propia manera de expresarte.',
                            style: TextStyle(color: Colors.white, fontSize: 17, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _ProgressCard(state: state),
              const SizedBox(height: 28),
              Text('Tu próxima clase', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              if (nextLesson != null)
                LessonCard(
                  lesson: nextLesson,
                  completed: false,
                  onTap: () => _openLesson(context, nextLesson),
                )
              else
                const _FinishedCard(),
              const SizedBox(height: 28),
              Text('Practica a tu manera', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 620;
                  final cards = [
                    _ActionCard(
                      icon: Icons.route_rounded,
                      title: 'Explorar las 24 clases',
                      subtitle: 'Puedes repetir cualquier clase cuando quieras.',
                      color: Theme.of(context).colorScheme.primaryContainer,
                      onTap: onOpenRoute,
                    ),
                    _ActionCard(
                      icon: Icons.graphic_eq_rounded,
                      title: 'Entrenar el pulso',
                      subtitle: 'Usa luz, sonido suave o vibración.',
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      onTap: onOpenRhythm,
                    ),
                  ];
                  if (stacked) {
                    return Column(
                      children: [cards.first, const SizedBox(height: 12), cards.last],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cards.first),
                      const SizedBox(width: 12),
                      Expanded(child: cards.last),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.health_and_safety_outlined),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Antes de bailar: despeja el espacio, usa calzado firme, toma agua y detente si algo duele. Bailar bien también es cuidarse.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openLesson(BuildContext context, Lesson lesson) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LessonScreen(state: state, lesson: lesson),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final percent = (state.progress * 100).round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Tu recorrido', style: Theme.of(context).textTheme.titleLarge),
                ),
                Text('$percent%', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            Semantics(
              label: '$percent por ciento completado',
              child: LinearProgressIndicator(
                value: state.progress,
                minHeight: 13,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 10),
            Text('${state.completedCount} de ${state.totalCount} clases completadas'),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 34),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinishedCard extends StatelessWidget {
  const _FinishedCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(Icons.celebration_rounded, size: 42),
            SizedBox(width: 16),
            Expanded(child: Text('¡Completaste la ruta! Ahora puedes crear, enseñar y seguir practicando.')),
          ],
        ),
      ),
    );
  }
}

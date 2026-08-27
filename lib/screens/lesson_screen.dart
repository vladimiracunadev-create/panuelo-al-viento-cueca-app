import 'package:flutter/material.dart';

import '../domain/curriculum.dart';
import '../state/app_state.dart';
import '../widgets/movement_diagram.dart';

/// Detalle de una clase: contexto, diagrama, actividades y cierre.
///
/// El botón de completar permanece desactivado hasta que las tres actividades
/// están marcadas. Es una decisión pedagógica, no una validación: la marca
/// registra participación, no dominio, y obliga a pasar por los tres momentos
/// de la clase antes de darla por vista.
///
/// Las casillas son estado local de la pantalla y **no se persisten**. Salir de
/// la clase sin completarla las descarta; solo el identificador de una clase
/// completada llega al almacenamiento. Es coherente con el inventario de datos
/// de `docs/PRIVACY.md`: no se guarda el detalle de la práctica.
class LessonScreen extends StatefulWidget {
  const LessonScreen({required this.state, required this.lesson, super.key});

  final AppState state;
  final Lesson lesson;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final List<bool> _activityChecks = List<bool>.filled(
    widget.lesson.activities.length,
    false,
  );

  bool get _allActivitiesChecked => _activityChecks.every((checked) => checked);

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final completed = widget.state.isCompleted(lesson.id);

    return Scaffold(
      appBar: AppBar(
        title: Text('Clase ${lesson.order}'),
        actions: [
          if (completed)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Chip(
                avatar: Icon(Icons.check_circle_rounded),
                label: Text('Completada'),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      lesson.title,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${lesson.durationMinutes} minutos · ${lesson.objective}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),
                    Card(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline_rounded),
                            const SizedBox(width: 12),
                            Expanded(child: Text(lesson.why)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    MovementDiagram(pattern: lesson.diagram),
                    const SizedBox(height: 28),
                    Text(
                      'Hazlo paso a paso',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    for (
                      var index = 0;
                      index < lesson.activities.length;
                      index++
                    )
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ActivityTile(
                          number: index + 1,
                          activity: lesson.activities[index],
                          checked: _activityChecks[index],
                          onChanged: (value) {
                            setState(
                              () => _activityChecks[index] = value ?? false,
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 18),
                    _InfoCard(
                      icon: Icons.flag_outlined,
                      title: 'Reto de la clase',
                      body: lesson.challenge,
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      icon: Icons.health_and_safety_outlined,
                      title: 'Baila con cuidado',
                      body: lesson.safety,
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      icon: Icons.accessibility_new_rounded,
                      title: 'Otra manera de hacerlo',
                      body: lesson.accessibility,
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      icon: Icons.school_outlined,
                      title: 'Para quien acompaña',
                      body: lesson.teacherTip,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed:
                          _allActivitiesChecked
                              ? completed
                                  ? _finishRepeat
                                  : _complete
                              : null,
                      icon: Icon(
                        completed
                            ? Icons.replay_rounded
                            : Icons.celebration_rounded,
                      ),
                      label: Text(
                        _allActivitiesChecked
                            ? completed
                                ? 'Terminar esta repetición'
                                : 'Completar esta clase'
                            : completed
                            ? 'Repite y marca los tres pasos'
                            : 'Marca los tres pasos para terminar',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Persiste la clase y celebra, en ese orden.
  ///
  /// El `await` a `completeLesson` va primero a propósito: si la escritura
  /// falla, la excepción sube y no se llega a mostrar una felicitación por algo
  /// que no quedó guardado. El `mounted` posterior cubre el caso de que la
  /// persona salga de la pantalla mientras se escribe.
  Future<void> _complete() async {
    await widget.state.completeLesson(widget.lesson.id);
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            icon: const Icon(Icons.celebration_rounded, size: 48),
            title: const Text('¡Clase completada!'),
            content: const Text(
              'Tu progreso quedó guardado en este dispositivo.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continuar'),
              ),
            ],
          ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  /// Cierra una repetición de una clase ya completada.
  ///
  /// No toca la persistencia: repetir no suma, pero tampoco puede restar. Solo
  /// limpia las casillas para poder volver a recorrer la clase y avisa de que
  /// el avance anterior sigue intacto, porque desmarcar las tres casillas
  /// parece un retroceso si nadie lo dice.
  void _finishRepeat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '¡Buena práctica! Tu avance anterior se mantiene guardado.',
        ),
      ),
    );
    setState(() {
      for (var index = 0; index < _activityChecks.length; index++) {
        _activityChecks[index] = false;
      }
    });
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.number,
    required this.activity,
    required this.checked,
    required this.onChanged,
  });

  final int number;
  final LearningActivity activity;
  final bool checked;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: CheckboxListTile(
        value: checked,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.trailing,
        contentPadding: const EdgeInsets.fromLTRB(18, 10, 14, 10),
        secondary: CircleAvatar(child: Text('$number')),
        title: Text(
          '${activity.title} · ${activity.minutes} min',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Text(activity.instruction),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 5),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

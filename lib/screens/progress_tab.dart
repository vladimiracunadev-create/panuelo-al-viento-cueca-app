import 'package:flutter/material.dart';

import '../state/app_state.dart';

/// Pantalla Mi avance: progreso, frontera de privacidad y reinicio.
///
/// La tarjeta de privacidad no es decorativa. Declara en la propia interfaz lo
/// que la documentación promete —que la aplicación no usa cámara ni micrófono—
/// para que una familia pueda comprobarlo sin leer un documento técnico. El
/// texto de esas dos líneas está afirmado en `test/app_smoke_test.dart`, así
/// que cambiarlo rompe la suite: es intencionado.
class ProgressTab extends StatelessWidget {
  const ProgressTab({required this.state, super.key});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          automaticallyImplyLeading: false,
          title: const Text('Mi avance'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeroProgress(state: state),
                    const SizedBox(height: 20),
                    Text(
                      'Progreso por nivel',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    for (final level in state.curriculum.levels) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Text(
                                level.emoji,
                                style: const TextStyle(fontSize: 30),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      level.title,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: state.levelProgress(level),
                                      minHeight: 9,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${(state.levelProgress(level) * 100).round()}%',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 18),
                    Card(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.shield_outlined),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Privacidad simple: no pedimos nombre, edad, correo ni ubicación. Este avance vive solamente en el dispositivo.',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14),
                            Divider(),
                            SizedBox(height: 8),
                            _CapabilityLine(
                              icon: Icons.mic_off_outlined,
                              title: 'Micrófono: no usado',
                              detail:
                                  'La aplicación no solicita permiso ni escucha audio.',
                            ),
                            SizedBox(height: 10),
                            _CapabilityLine(
                              icon: Icons.videocam_off_outlined,
                              title: 'Cámara: no usada',
                              detail:
                                  'La aplicación no solicita permiso, toma fotos ni graba video.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      onPressed: () => _confirmReset(context),
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Reiniciar el avance'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Pide confirmación antes de borrar el avance local.
  ///
  /// El borrado es irreversible y no hay copia en la nube ni exportación en
  /// esta versión, así que la confirmación es el único freno que existe.
  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('¿Reiniciar todo el avance?'),
            content: const Text(
              'Se desmarcarán las 24 clases en este dispositivo.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Reiniciar'),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      await state.resetProgress();
    }
  }
}

class _CapabilityLine extends StatelessWidget {
  const _CapabilityLine({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(detail),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroProgress extends StatelessWidget {
  const _HeroProgress({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final percent = (state.progress * 100).round();
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: state.progress,
                    strokeWidth: 12,
                  ),
                  Text(
                    '$percent%',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.progress == 1
                        ? '¡Ruta completada!'
                        : 'Cada paso cuenta',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${state.completedCount} clases listas. Repetir también es avanzar.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

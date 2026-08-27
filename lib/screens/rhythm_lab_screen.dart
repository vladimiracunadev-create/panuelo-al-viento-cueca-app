import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Las dos agrupaciones de seis pulsos que el laboratorio contrasta.
///
/// `sixEight` acentúa 1 y 4 (3+3) y `threeFour` acentúa 1, 3 y 5 (2+2+2). En la
/// cueca ambas sensaciones pueden convivir; el laboratorio las separa solo para
/// entrenar la escucha, y la tarjeta final del formulario lo advierte para no
/// presentar esta simplificación como la interpretación real.
enum _PulsePattern { sixEight, threeFour }

/// Laboratorio de ritmo: metrónomo visual de seis pulsos.
///
/// Las salidas de sonido y vibración son opcionales y están apagadas hasta que
/// se pulsa Comenzar. Ninguna de las dos lee el entorno: se piden al sistema
/// operativo y no abren ningún canal de captura.
///
/// El estado de esta pantalla sobrevive al cambio de pestaña, porque
/// `HomeShell` la mantiene en un `IndexedStack`. Un pulso iniciado sigue
/// sonando mientras se navega por Inicio, Ruta o Avance; solo Detener, o cerrar
/// la aplicación, lo cancela.
class RhythmLabScreen extends StatefulWidget {
  const RhythmLabScreen({super.key});

  @override
  State<RhythmLabScreen> createState() => _RhythmLabScreenState();
}

class _RhythmLabScreenState extends State<RhythmLabScreen> {
  Timer? _timer;
  final Stopwatch _clock = Stopwatch();
  int _scheduledTick = 0;
  double _bpm = 84;
  int _pulse = 0;
  bool _playing = false;
  bool _sound = true;
  bool _vibration = true;
  _PulsePattern _pattern = _PulsePattern.sixEight;

  List<int> get _accents => switch (_pattern) {
    _PulsePattern.sixEight => const [0, 3],
    _PulsePattern.threeFour => const [0, 2, 4],
  };

  @override
  void dispose() {
    _timer?.cancel();
    _clock.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          automaticallyImplyLeading: false,
          title: const Text('Laboratorio de ritmo'),
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
                    Text(
                      'Escucha dos maneras de agrupar seis pulsos. En la cueca pueden sentirse juntas: primero aprende a reconocerlas, después llévalas a los pies.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            SegmentedButton<_PulsePattern>(
                              segments: const [
                                ButtonSegment(
                                  value: _PulsePattern.sixEight,
                                  icon: Icon(Icons.looks_two_outlined),
                                  label: Text('3 + 3'),
                                ),
                                ButtonSegment(
                                  value: _PulsePattern.threeFour,
                                  icon: Icon(Icons.looks_3_outlined),
                                  label: Text('2 + 2 + 2'),
                                ),
                              ],
                              selected: {_pattern},
                              onSelectionChanged: (selection) {
                                setState(() {
                                  _pattern = selection.first;
                                  _pulse = 0;
                                });
                              },
                            ),
                            const SizedBox(height: 34),
                            Semantics(
                              liveRegion: true,
                              label: 'Pulso ${_pulse + 1} de 6',
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(6, (index) {
                                  final active = _playing && index == _pulse;
                                  final accent = _accents.contains(index);
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 100),
                                    width: active ? 54 : 42,
                                    height: active ? 54 : 42,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          active
                                              ? Theme.of(
                                                context,
                                              ).colorScheme.secondary
                                              : accent
                                              ? Theme.of(
                                                context,
                                              ).colorScheme.tertiaryContainer
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color:
                                            active
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.onSecondary
                                                : null,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 34),
                            Text(
                              '${_bpm.round()} pulsos por minuto',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Slider(
                              value: _bpm,
                              min: 60,
                              max: 120,
                              divisions: 12,
                              label: '${_bpm.round()}',
                              onChanged: (value) {
                                setState(() => _bpm = value);
                                if (_playing) {
                                  _startSchedule();
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              children: [
                                FilterChip(
                                  selected: _sound,
                                  onSelected:
                                      (value) => setState(() => _sound = value),
                                  avatar: const Icon(Icons.volume_up_outlined),
                                  label: const Text('Sonido'),
                                ),
                                FilterChip(
                                  selected: _vibration,
                                  onSelected:
                                      (value) =>
                                          setState(() => _vibration = value),
                                  avatar: const Icon(Icons.vibration_rounded),
                                  label: const Text('Vibración'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: _toggle,
                              icon: Icon(
                                _playing
                                    ? Icons.stop_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                              label: Text(_playing ? 'Detener' : 'Comenzar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Juego de tres rondas',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '1. Marca el pulso con las manos.\n2. Pásalo a pasos pequeños.\n3. Muévete sin mirar la pantalla y vuelve a comprobar.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.privacy_tip_outlined),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Al comenzar solo se activa el pulso visual. Sonido y vibración funcionan únicamente si sus botones están encendidos y el dispositivo los admite. No se activa ni se solicita cámara o micrófono.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Este laboratorio simplifica el pulso para entrenar la escucha. La interpretación real cambia entre canciones y estilos; practica también con una persona conocedora y música autorizada.',
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
          ),
        ),
      ],
    );
  }

  void _toggle() {
    if (_playing) {
      _timer?.cancel();
      _clock
        ..stop()
        ..reset();
      setState(() {
        _playing = false;
        _pulse = 0;
      });
      return;
    }
    setState(() => _playing = true);
    _emitPulse();
    _startSchedule();
  }

  /// Reinicia la línea temporal del pulso desde el instante actual.
  ///
  /// Se llama también al mover el deslizador de velocidad mientras suena: la
  /// referencia se pone a cero para que el cambio de tempo se note de inmediato
  /// en vez de esperar a que venza el intervalo ya programado.
  void _startSchedule() {
    _timer?.cancel();
    _scheduledTick = 0;
    _clock
      ..reset()
      ..start();
    _scheduleNextPulse();
  }

  /// Programa el pulso siguiente contra un instante absoluto.
  ///
  /// Este método es el motivo de que no se use `Timer.periodic`. Un temporizador
  /// periódico vuelve a contar desde el momento en que **se ejecutó** la llamada
  /// anterior, de modo que cada retraso del hilo visual se suma al siguiente y
  /// el metrónomo se va quedando atrás sin recuperarse nunca.
  ///
  /// Aquí el objetivo de cada pulso se calcula sobre un [Stopwatch] monotónico
  /// como `microsPerPulse * (tick + 1)`, y el temporizador solo espera lo que
  /// falte para llegar a ese instante. Si una llamada llega tarde, el intervalo
  /// siguiente se acorta —o se dispara de inmediato con espera cero— y la serie
  /// vuelve a la línea temporal en vez de acumular el error.
  ///
  /// Riesgo al modificar: sustituirlo por un intervalo fijo reintroduce una
  /// deriva que solo se nota tras varios minutos de práctica, que es
  /// exactamente cuando importa.
  void _scheduleNextPulse() {
    if (!_playing) {
      return;
    }
    final microsPerPulse = 60000000 / _bpm;
    final targetMicros = (microsPerPulse * (_scheduledTick + 1)).round();
    final remainingMicros = targetMicros - _clock.elapsedMicroseconds;
    _timer = Timer(
      Duration(microseconds: remainingMicros > 0 ? remainingMicros : 0),
      () {
        if (!mounted || !_playing) {
          return;
        }
        _scheduledTick += 1;
        setState(() => _pulse = (_pulse + 1) % 6);
        _emitPulse();
        _scheduleNextPulse();
      },
    );
  }

  /// Emite las señales del pulso actual, después de haberlo dibujado.
  ///
  /// El clic se pide en cada pulso; la respuesta háptica solo en los acentos,
  /// para que la vibración marque la agrupación y no se convierta en un zumbido
  /// continuo. Ambas pueden ser ignoradas por el equipo —la háptica no suele
  /// existir en escritorio— y esa ausencia no se trata como error.
  void _emitPulse() {
    final accent = _accents.contains(_pulse);
    if (_sound) {
      SystemSound.play(SystemSoundType.click);
    }
    if (_vibration && accent) {
      HapticFeedback.mediumImpact();
    }
  }
}

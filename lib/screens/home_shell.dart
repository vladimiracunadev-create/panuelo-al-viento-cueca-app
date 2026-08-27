import 'package:flutter/material.dart';

import '../state/app_state.dart';
import 'home_tab.dart';
import 'progress_tab.dart';
import 'rhythm_lab_screen.dart';
import 'route_tab.dart';

/// Contenedor de las cuatro secciones y de su navegación.
///
/// Cambia de forma según el ancho disponible: por debajo de 840 px lógicos usa
/// una barra inferior, y a partir de ahí una barra lateral. El umbral se
/// comprueba con `LayoutBuilder` y no con la plataforma, de modo que una
/// ventana de escritorio estrecha se comporta como un teléfono.
///
/// Las cuatro secciones viven en un `IndexedStack`, no en un `PageView` ni en
/// rutas: cambiar de pestaña conserva la posición de desplazamiento y el estado
/// de cada una. Tiene una consecuencia que conviene tener presente antes de
/// tocar nada aquí: el estado de las pestañas no visibles **sigue vivo**. En
/// concreto, `RhythmLabScreen` no se descarta al salir de Ritmo y su
/// temporizador continúa emitiendo pulsos hasta que se pulsa Detener.
class HomeShell extends StatefulWidget {
  const HomeShell({required this.state, super.key});

  final AppState state;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        final screens = [
          HomeTab(
            state: widget.state,
            onOpenRoute: () => setState(() => _selectedIndex = 1),
            onOpenRhythm: () => setState(() => _selectedIndex = 2),
          ),
          RouteTab(state: widget.state),
          const RhythmLabScreen(),
          ProgressTab(state: widget.state),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 840;
            final content = IndexedStack(
              index: _selectedIndex,
              children: screens,
            );

            if (wide) {
              return Scaffold(
                body: SafeArea(
                  child: Row(
                    children: [
                      NavigationRail(
                        selectedIndex: _selectedIndex,
                        labelType: NavigationRailLabelType.all,
                        onDestinationSelected: (index) {
                          setState(() => _selectedIndex = index);
                        },
                        leading: const Padding(
                          padding: EdgeInsets.only(top: 12, bottom: 18),
                          child: CircleAvatar(
                            radius: 28,
                            child: Icon(Icons.air_rounded, size: 30),
                          ),
                        ),
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.home_outlined),
                            selectedIcon: Icon(Icons.home_rounded),
                            label: Text('Inicio'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.route_outlined),
                            selectedIcon: Icon(Icons.route_rounded),
                            label: Text('Ruta'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.music_note_outlined),
                            selectedIcon: Icon(Icons.music_note_rounded),
                            label: Text('Ritmo'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.emoji_events_outlined),
                            selectedIcon: Icon(Icons.emoji_events_rounded),
                            label: Text('Avance'),
                          ),
                        ],
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: content),
                    ],
                  ),
                ),
              );
            }

            return Scaffold(
              body: SafeArea(child: content),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => _selectedIndex = index);
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Inicio',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.route_outlined),
                    selectedIcon: Icon(Icons.route_rounded),
                    label: 'Ruta',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.music_note_outlined),
                    selectedIcon: Icon(Icons.music_note_rounded),
                    label: 'Ritmo',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.emoji_events_outlined),
                    selectedIcon: Icon(Icons.emoji_events_rounded),
                    label: 'Avance',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

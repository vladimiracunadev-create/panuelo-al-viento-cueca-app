import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/curriculum_repository.dart';
import 'data/progress_repository.dart';
import 'state/app_state.dart';

/// Punto de entrada de la aplicación.
///
/// Resuelve dependencias en el orden que impone la carga: preferencias,
/// repositorios, estado y, solo entonces, la primera imagen.
///
/// La envoltura `try` no es defensiva por costumbre. Las dos operaciones que
/// preceden a la primera imagen —abrir las preferencias del sistema y leer el
/// activo del currículo— pueden fallar en un dispositivo real, y un fallo ahí
/// dejaría a una niña o un niño frente a una pantalla en blanco sin
/// explicación. [_StartupErrorApp] convierte ese caso en un mensaje legible.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final preferences = await SharedPreferences.getInstance();
    final state = AppState(
      curriculumRepository: const CurriculumRepository(),
      progressRepository: ProgressRepository(preferences),
    );
    await state.load();

    runApp(PanueloAlVientoApp(state: state));
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'inicio de Pañuelo al Viento',
      ),
    );
    runApp(const _StartupErrorApp());
  }
}

/// Pantalla de último recurso cuando el arranque no pudo completarse.
///
/// No ofrece reintento porque las causas plausibles —activo corrompido o
/// almacenamiento inaccesible— no se resuelven repitiendo la misma operación
/// en el mismo proceso. El texto evita jerga y evita culpar a quien lee.
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 56),
                    SizedBox(height: 16),
                    Text(
                      'No pudimos abrir la ruta de aprendizaje',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Cierra y vuelve a abrir la aplicación. Si el problema continúa, instala nuevamente la versión oficial.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/curriculum_repository.dart';
import 'data/progress_repository.dart';
import 'state/app_state.dart';

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
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
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

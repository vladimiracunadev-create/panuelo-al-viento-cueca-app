import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'screens/home_shell.dart';
import 'state/app_state.dart';

/// Raíz de la aplicación.
///
/// El estado llega ya cargado desde `main` en vez de resolverse aquí: eso
/// permite que las pruebas de widget construyan la aplicación con un currículo
/// y un avance conocidos, sin esperar futuros.
///
/// `themeMode` sigue al sistema y no se ofrece un selector propio. Es una
/// decisión de producto infantil: menos controles que entender, y la
/// preferencia de contraste ya está declarada en el dispositivo.
class PanueloAlVientoApp extends StatelessWidget {
  const PanueloAlVientoApp({required this.state, super.key});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pañuelo al Viento',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: HomeShell(state: state),
    );
  }
}

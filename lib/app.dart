import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'screens/home_shell.dart';
import 'state/app_state.dart';

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

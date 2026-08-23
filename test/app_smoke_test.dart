import 'package:flutter_test/flutter_test.dart';
import 'package:panuelo_al_viento/app.dart';
import 'package:panuelo_al_viento/data/curriculum_repository.dart';
import 'package:panuelo_al_viento/data/progress_repository.dart';
import 'package:panuelo_al_viento/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('abre la ruta, el ritmo y el detalle de privacidad', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final state = AppState(
      curriculumRepository: const CurriculumRepository(),
      progressRepository: ProgressRepository(preferences),
    );
    await state.load();

    await tester.pumpWidget(PanueloAlVientoApp(state: state));
    expect(find.text('¡Que baile el pañuelo!'), findsOneWidget);

    await tester.tap(find.text('Ruta'));
    await tester.pumpAndSettle();
    expect(find.text('Ruta de aprendizaje'), findsOneWidget);

    await tester.tap(find.text('Ritmo'));
    await tester.pumpAndSettle();
    expect(find.text('Laboratorio de ritmo'), findsOneWidget);
    expect(find.textContaining('No se activa ni se solicita cámara'), findsOneWidget);

    await tester.tap(find.text('Avance'));
    await tester.pumpAndSettle();
    expect(find.text('Micrófono: no usado'), findsOneWidget);
    expect(find.text('Cámara: no usada'), findsOneWidget);
  });
}

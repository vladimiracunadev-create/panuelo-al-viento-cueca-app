import 'package:flutter_test/flutter_test.dart';
import 'package:panuelo_al_viento/data/progress_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('guarda, recupera y borra identificadores locales', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = ProgressRepository(preferences);

    await repository.writeCompletedLessonIds({'lesson-02', 'lesson-01'});
    expect(repository.readCompletedLessonIds(), {'lesson-01', 'lesson-02'});

    await repository.clear();
    expect(repository.readCompletedLessonIds(), isEmpty);
  });
}

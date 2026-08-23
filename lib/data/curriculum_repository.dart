import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/curriculum.dart';

class CurriculumRepository {
  const CurriculumRepository();

  Future<Curriculum> load() async {
    final source = await rootBundle.loadString(
      'assets/content/curriculum.json',
    );
    final json = jsonDecode(source) as Map<String, dynamic>;
    return Curriculum.fromJson(json);
  }
}

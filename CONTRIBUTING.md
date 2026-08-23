# Contribuir

Gracias por ayudar a que niñas y niños aprendan cueca con respeto y alegría.

## Requisitos de una contribución

1. Mantener lenguaje comprensible para aproximadamente 10 años.
2. Distinguir claramente hechos, convenciones pedagógicas y variantes territoriales.
3. No presentar una secuencia local como la única forma correcta de bailar cueca.
4. Incluir adaptación cuando un movimiento pueda excluir a una persona.
5. No añadir medios sin procedencia, autorización y licencia documentadas.
6. No introducir publicidad, rastreo, chat ni cuentas infantiles.
7. Añadir o actualizar pruebas cuando cambie la estructura del currículo.

## Flujo técnico

```bash
flutter pub get
node tool/validate_repository.mjs
node tool/validate_curriculum.mjs
dart format lib test tool
flutter analyze
flutter test
dart run tool/validate_curriculum.dart
```

Los cambios pedagógicos deben indicar quién los revisó y qué variante o territorio representan.

Los cambios que añadan permisos, red, sensores, medios o persistencia deben actualizar `docs/PERMISSIONS.md`, `docs/PRIVACY.md`, `docs/CONTENT_LICENSES.md` y la checklist de release. Cámara y micrófono están fuera de 0.1.0; no se incorporan de manera incidental a través de una dependencia.

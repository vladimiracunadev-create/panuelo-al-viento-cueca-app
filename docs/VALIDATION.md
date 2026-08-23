# Cómo validar el proyecto

El resultado fechado de la versión se publica en [VALIDATION_RESULT.md](VALIDATION_RESULT.md). Este documento explica cómo reproducir la parte automatizada.

## Sin Flutter

```bash
node tool/validate_repository.mjs
node tool/validate_curriculum.mjs
```

El primer comando comprueba archivos esenciales, versión y límites de permisos. El segundo valida niveles, clases, actividades, identificadores, orden, duración y campos requeridos.

## Con Flutter

```bash
flutter pub get
dart format --output=none lib test tool
flutter analyze
flutter test --reporter expanded
```

La suite cubre modelos, currículo completo, persistencia, fallos transaccionales, identificadores inválidos y navegación principal.

## Plataformas

```bash
flutter create --project-name panuelo_al_viento --org cl.panueloalviento --platforms=android --no-pub .
node tool/configure_platforms.mjs
```

En Windows puede generarse `--platforms=android,windows`. El configurador aplica Android 7+, el nombre público y rechaza cámara/micrófono.

La prueba definitiva de empaquetado se ejecuta en `.github/workflows/release.yml`: APK firmado, arranque Windows, EXE, MSI, portable y hashes.

## Límite

Una suite verde prueba consistencia técnica, no que el currículo sea cultural o corporalmente correcto. La evidencia humana se registra con [TEACHER_REVIEW.md](TEACHER_REVIEW.md).

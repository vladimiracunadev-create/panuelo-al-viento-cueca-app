# Cómo validar el proyecto

El resultado fechado de la versión se publica en [VALIDATION_RESULT.md](VALIDATION_RESULT.md). Este documento explica cómo reproducir la parte automatizada.

## Sin Flutter

```bash
node tool/validate_repository.mjs
node tool/validate_curriculum.mjs
```

El primer comando comprueba los archivos esenciales, los límites de permisos y la **coherencia de versión**: que `pubspec.yaml`, `CHANGELOG.md`, las notas de `docs/releases/` y los nombres de artefacto del README hablen todos de la misma versión, que las capturas que el README enseña existan de verdad y que las notas de release no usen enlaces relativos, porque en la página de GitHub Releases no resuelven. El segundo valida niveles, clases, actividades, identificadores, orden, duración y campos requeridos.

## Con Flutter

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --reporter expanded
```

`--set-exit-if-changed` es lo que convierte el formato en una compuerta: sin esa opción `dart format --output=none` imprime los archivos que cambiarían y aun así devuelve éxito, de modo que el paso pasa siempre y no comprueba nada.

La suite cubre modelos, currículo completo, persistencia, fallos transaccionales, identificadores inválidos y navegación principal.

## Plataformas

```bash
flutter create --project-name panuelo_al_viento --org cl.panueloalviento --platforms=android --no-pub .
node tool/configure_platforms.mjs
```

En Windows puede generarse `--platforms=android,windows`. El configurador aplica Android 7+, el nombre público y rechaza cámara/micrófono.

## Sobre un artefacto compilado

Un build verde no prueba que el binario sea correcto. `tool/verify_apk.mjs` abre el APK con `aapt2` y comprueba paquete, `versionName`, `versionCode`, `minSdkVersion`, permisos del manifiesto fusionado, arquitecturas nativas y que el currículo empaquetado exista, tenga 8 niveles y 24 clases, y sea byte por byte el mismo que `assets/content/curriculum.json`:

```bash
node tool/verify_apk.mjs build/app/outputs/flutter-apk/app-release.apk
```

Sin segundo argumento toma la versión esperada de `pubspec.yaml`. Necesita las build-tools de Android en `ANDROID_SDK_ROOT`, o la ruta a `aapt2` en la variable `AAPT2`.

## Capturas

```bash
node tool/capture_screenshots.mjs
```

Compila la aplicación para web, la sirve en localhost y conduce un Chrome sin ventana para rehacer `docs/screenshots/`. Es la forma de garantizar que las imágenes del README sean la aplicación real y no una maqueta envejecida.

## Landing

```bash
node tool/build_site.mjs --serve
```

Ensambla `site/` en `build/site/` sustituyendo `__APP_VERSION__` por la versión de `pubspec.yaml`, copia la marca y las capturas, y falla si alguna imagen referenciada no existe. Así los enlaces de descarga no pueden quedarse apuntando a una versión anterior, que es la manera silenciosa de que una landing empiece a ofrecer archivos con 404.

## Empaquetado

La prueba definitiva de empaquetado se ejecuta en `.github/workflows/release.yml`: coincidencia entre el tag y la versión del manifiesto, APK firmado y verificado, versión del ejecutable Windows, arranque de escritorio, EXE, MSI, portable y hashes.

## Límite

Una suite verde prueba consistencia técnica, no que el currículo sea cultural o corporalmente correcto. La evidencia humana se registra con [TEACHER_REVIEW.md](TEACHER_REVIEW.md).

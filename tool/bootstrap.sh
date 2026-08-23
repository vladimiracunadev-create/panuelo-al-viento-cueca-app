#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo 'Flutter no está disponible. Instala Flutter estable y vuelve a ejecutar este archivo.' >&2
  exit 1
fi

flutter create --project-name panuelo_al_viento --org cl.panueloalviento --platforms=android,windows --no-pub .
node tool/configure_platforms.mjs
flutter pub get
dart run flutter_launcher_icons
node tool/validate_repository.mjs
node tool/validate_curriculum.mjs
flutter analyze
flutter test

echo 'Proyecto preparado para Android.'

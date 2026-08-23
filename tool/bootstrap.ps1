$ErrorActionPreference = 'Stop'

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw 'Flutter no está disponible. Instala Flutter estable y vuelve a ejecutar este archivo.'
}

flutter config --enable-windows-desktop
flutter create --project-name panuelo_al_viento --org cl.panueloalviento --platforms=android,windows --no-pub .
node tool/configure_platforms.mjs

flutter pub get
dart run flutter_launcher_icons
node tool/validate_repository.mjs
node tool/validate_curriculum.mjs
flutter analyze
flutter test

Write-Host 'Proyecto preparado. Usa flutter run -d windows o flutter run -d <dispositivo-android>.'

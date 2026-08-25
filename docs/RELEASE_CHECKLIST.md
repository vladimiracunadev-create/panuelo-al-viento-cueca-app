# Checklist de release

## Versión y repositorio

- [ ] `pubspec.yaml` lleva la versión nueva y el número de compilación aumentó.
- [ ] `CHANGELOG.md` encabeza esa versión con su fecha.
- [ ] Existen las notas `docs/releases/vX.Y.Z.md` sin enlaces relativos.
- [ ] El README nombra los cuatro artefactos con la versión nueva.
- [ ] `node tool/validate_repository.mjs` confirma toda esa coherencia de una sola vez.
- [ ] Árbol de trabajo revisado y sin secretos, claves o datos de menores.
- [ ] Licencia, About, topics y enlaces corresponden al repositorio público.
- [ ] Tag con formato `vX.Y.Z` apunta al commit aprobado.

## Calidad automatizada

- [ ] `node tool/validate_repository.mjs`.
- [ ] `node tool/validate_curriculum.mjs`.
- [ ] `dart format --output=none --set-exit-if-changed lib test tool`.
- [ ] `flutter analyze`.
- [ ] `flutter test`.
- [ ] CI verde en `main`.

## Privacidad infantil

- [ ] Android no declara `CAMERA`, `RECORD_AUDIO` ni `INTERNET` en el APK compilado.
- [ ] No existen nuevas llamadas de red, analítica, publicidad o cuentas.
- [ ] La pantalla Mi avance coincide con el comportamiento real.
- [ ] Sonido y vibración solo empiezan tras una acción explícita.
- [ ] Capturas y logs no contienen datos de niñas o niños.

## Android

- [ ] APK release firmado y verificado por `apksigner`.
- [ ] `node tool/verify_apk.mjs <apk>` en verde: versión, `versionCode`, `minSdkVersion`, permisos y currículo empaquetado.
- [ ] Clave permanente configurada o limitación efímera destacada.
- [ ] Instalación real en Android 7+.
- [ ] Inicio sin conexión y persistencia después de cerrar.
- [ ] Sin diálogos de cámara o micrófono.

## Windows

- [ ] El ejecutable inicia en el runner o equipo de prueba.
- [ ] Setup EXE instala, abre y desinstala.
- [ ] MSI instala, abre y desinstala.
- [ ] ZIP portable funciona después de extraer la carpeta completa.
- [ ] Persistencia y escalado de ventana verificados.

## Contenido y pedagogía

- [ ] 8 niveles, 24 clases y 72 actividades siguen íntegros.
- [ ] Todo cambio cultural indica fuente y revisión.
- [ ] Cada movimiento conserva seguridad y alternativa accesible.
- [ ] Ninguna afirmación automatizada se presenta como validación docente.

## Publicación

- [ ] Release contiene APK, EXE, MSI, ZIP y `SHA256SUMS.txt`.
- [ ] Los cuatro nombres de archivo llevan la versión publicada.
- [ ] Las capturas del README corresponden a esta versión.
- [ ] Nombres y tamaños son razonables.
- [ ] Notas explican funciones, instalación, permisos y límites conocidos.
- [ ] Descarga desde la página pública comprobada.
- [ ] About y README apuntan a la release correcta.

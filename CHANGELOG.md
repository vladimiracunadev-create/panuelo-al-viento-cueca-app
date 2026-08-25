# Historial de cambios

## No publicado

Cambios de documentación, verificación y publicación. No modifican el comportamiento de la aplicación, así que `0.1.0` sigue siendo la versión instalable vigente.

### Versión operativa de los artefactos

- La versión de la release sale de `pubspec.yaml` y de ningún otro sitio; antes estaba escrita a mano en `release.yml`, de modo que un tag `v0.2.0` habría publicado archivos llamados `0.1.0`.
- El workflow rechaza la publicación si el tag no es `v` + la versión del manifiesto, o si faltan las notas de esa versión.
- Las notas de publicación se eligen por tag en vez de apuntar siempre a `docs/releases/v0.1.0.md`.
- Nuevo `tool/verify_apk.mjs`: abre el APK compilado y comprueba paquete, `versionName`, `versionCode`, `minSdkVersion`, permisos del manifiesto fusionado, arquitecturas y que el currículo empaquetado coincida con el del repositorio.
- La release comprueba también la `ProductVersion` del ejecutable Windows y que ninguno de los cuatro artefactos lleve una versión distinta.
- Nuevo `tool/app_version.mjs` como única fuente de verdad de la versión, reutilizada por los validadores y por CI.

### Verificación

- `dart format` corre con `--set-exit-if-changed`: sin esa opción el paso pasaba siempre y no comprobaba nada. Los archivos Dart se reformatearon con el formateador vigente.
- CI y release fijan Flutter 3.44.6 para que formato y compilación sean reproducibles.
- `tool/validate_repository.mjs` deja de tener la versión escrita dentro y ahora comprueba coherencia entre `pubspec.yaml`, `CHANGELOG.md`, las notas de release y los nombres de artefacto del README, que las capturas existan y que las notas no lleven enlaces relativos.
- `pubspec.lock` se versiona para que las dependencias resueltas sean las mismas en cada compilación.

### Interfaz

- Modo oscuro corregido. Los roles `*Container` se generaban desde una semilla amarilla mientras `primary`, `secondary` y `tertiary` estaban sobrescritos a mano, y sobrescribir un color no regenera su contenedor: el resultado era un `primaryContainer` marrón junto a un `primary` azul y un `tertiaryContainer` verde junto a un `tertiary` amarillo. Ahora los contenedores se declaran explícitamente en los dos modos, y cada uno en modo oscuro es la versión profunda del tono que ocupa esa misma ranura en modo claro.
- El rojo del pulso acentuado se oscurece a `#B63535`: el rojo de marca sobre blanco solo alcanzaba 4,2:1.
- Nuevas pruebas de contraste que miden con WCAG cada par de color que la interfaz dibuja de verdad —incluido el caso real de una tarjeta con color propio y texto heredado de `onSurface`— y fallan por debajo de 4,5:1. La suite pasa de 9 a 25 pruebas.

### Landing

- Nueva página pública en `site/`, publicada en GitHub Pages, con la misma estructura que las de violín y guitarra: capturas reales, los ocho niveles, descargas y privacidad.
- `tool/build_site.mjs` la ensambla sustituyendo la versión desde `pubspec.yaml` y falla si alguna imagen referenciada no existe. Los enlaces de descarga no pueden quedarse apuntando a una versión anterior.
- El validador rechaza cualquier número de versión escrito a mano dentro de `site/`.

### Documentación

- Nueve capturas reales de la aplicación en `docs/screenshots/`, reproducibles con `tool/capture_screenshots.mjs`.
- README con vistazo visual, evidencia medida del APK publicado, estructura del proyecto y estado real, a la par de los proyectos de violín y guitarra.
- Se documenta que el APK no declara `android.permission.INTERNET`, confirmado sobre el binario publicado.
- Las notas de `0.1.0` usan enlaces absolutos: los relativos no resuelven en la página de GitHub Releases.

## 0.1.0 — 2026-08-23

Primera versión pública para Android y Windows.

### Curso

- 8 niveles, 24 clases y 72 actividades para una ruta sugerida de ocho semanas.
- Progresión desde contexto, pulso y espacio hasta diálogo, zapateo de bajo impacto, creación, diversidad territorial y presentación.
- Cada clase incorpora objetivo, motivo, tres actividades cronometradas, reto, advertencia de seguridad, alternativa accesible y consejo de mediación.
- Diagramas semánticos originales para vuelta, ocho, medialuna, pasos, pareja y movimiento del pañuelo.

### Ritmo y experiencia

- Laboratorio de seis pulsos con agrupaciones 3+3 y 2+2+2.
- Velocidad entre 60 y 120 pulsos por minuto.
- Pulso visual, clic del sistema opcional y respuesta háptica opcional en acentos.
- Planificación con `Stopwatch` y temporizadores de un disparo para corregir deriva acumulada.
- Navegación adaptable: barra inferior en móvil y lateral en escritorio.
- Modo claro u oscuro según el sistema y texto escalable.

### Progreso y robustez

- Próxima clase, porcentaje total y avance por cada nivel.
- Repetición sin penalización y reinicio con confirmación.
- Persistencia transaccional: el estado visible cambia solo después de guardar o borrar correctamente.
- Rechazo de identificadores curriculares inexistentes.
- Pantalla comprensible de recuperación si falla la carga inicial.

### Privacidad y seguridad infantil

- Sin cuenta, servidor, publicidad, analítica, ubicación ni llamadas de red del producto.
- Cámara y micrófono ausentes del código y de los permisos Android.
- Estado de ambas capacidades explicado en la pantalla Mi avance.
- Auditoría automática que bloquea una release si aparecen `CAMERA` o `RECORD_AUDIO`.
- Sonido y vibración solo después de una acción explícita; no capturan ni almacenan datos.

### Distribución

- APK universal para Android 7 o superior.
- Windows mediante instalador Setup `.exe`, paquete `.msi` y `.zip` portable.
- Release automática por tag `v*`, prueba breve de arranque Windows y `SHA256SUMS.txt`.
- Soporte para firma Android permanente mediante GitHub Secrets; clave efímera con advertencia si todavía no se configuró.

### Verificación y documentación

- Validadores independientes de repositorio y currículo con Node.
- Pruebas de modelos, integridad curricular, preferencias, transacciones y navegación.
- CI con formato, análisis estático y pruebas Flutter.
- Documentación equivalente a los proyectos de violín y guitarra: familia, accesibilidad, permisos, builds, licencias, revisión docente, validación y release.

### Límites conocidos

- No incluye grabaciones musicales, video ni evaluación por sensores.
- Falta validación presencial completa con docentes, personas cultoras y niños con autorización adulta.
- La vibración puede no estar disponible en Windows y el clic depende del sonido del sistema.
- Sin clave Android permanente, una futura actualización exigirá desinstalar y perderá el progreso local.
- Los instaladores Windows no tienen firma comercial Authenticode.

# Resultado de validación 0.1.0

Fecha técnica: 2026-08-23 · Revisión del artefacto publicado: 2026-08-24

## Resultado automatizado

| Comprobación | Resultado |
|---|---|
| Currículo JSON legible | Aprobado por validador Node. |
| Estructura | 8 niveles, 24 clases y 72 actividades. |
| Orden | Clases 1–24 sin saltos ni repetición. |
| Identificadores | Niveles y clases únicos. |
| Duración | Tres actividades por clase; suma igual a la duración declarada. |
| Campos pedagógicos | Objetivo, motivo, diagrama, reto, seguridad, accesibilidad y consejo presentes. |
| Persistencia | Prueba de escritura, lectura, borrado y ordenamiento local. |
| Transacciones | Pruebas de que un fallo de escritura o borrado no publica un estado falso. |
| Navegación | Smoke test de Inicio, Ruta, Ritmo, Avance y mensajes de permisos. |
| Repositorio | Archivos esenciales, coherencia de versión entre `pubspec.yaml`, `CHANGELOG.md`, notas de release y README, y existencia real de las capturas, comprobados por Node. |
| Cámara/micrófono | Ausentes del producto; manifiesto fuente auditado durante la release y manifiesto fusionado del APK verificado con `aapt2`. |
| Compilación | Ejecutada en CI para APK y Windows al crear la release. |
| Artefactos | El workflow exige APK, Setup EXE, MSI, ZIP y SHA-256 antes de publicar, y rechaza cualquier archivo cuyo nombre no lleve la versión del manifiesto. |
| Versión operativa | El tag debe ser `v` + la versión de `pubspec.yaml`; el APK compilado y el ejecutable Windows deben declarar esa misma versión. |

## Artefacto publicado, medido

`PanueloAlViento-0.1.0-Android.apk` descargado desde la release oficial y abierto con `node tool/verify_apk.mjs`:

| Propiedad | Valor medido | Esperado |
|---|---|---|
| SHA-256 | `b32c2f96…5ac5a45` | Coincide con `SHA256SUMS.txt` de la release. |
| Paquete | `cl.panueloalviento.panuelo_al_viento` | Correcto. |
| `versionName` | `0.1.0` | Igual a `pubspec.yaml` y al nombre del archivo. |
| `versionCode` | `1` | Igual al número de compilación de `pubspec.yaml`. |
| `minSdkVersion` | `24` | Android 7.0, tal como anuncia la documentación. |
| `targetSdkVersion` | `36` | Nivel de API vigente. |
| Permisos del sistema | Ninguno | Sin cámara, micrófono, internet ni ubicación. |
| Código nativo | `arm64-v8a`, `armeabi-v7a`, `x86_64` | APK universal. |
| Currículo empaquetado | 43 165 bytes, 8 niveles y 24 clases | Hash idéntico a `assets/content/curriculum.json`. |
| Firma | Esquema v2, RSA 2048, `CN=Panuelo al Viento` | **Clave efímera**: confirma que los secrets de firma permanente todavía no están configurados. |

El ejecutable de la versión portable de Windows declara `ProductVersion 0.1.0+1` y `CompanyName Vladimir Acuña`.

La comprobación del currículo importa por sí misma: un artefacto puede compilar, firmarse y cuadrar en checksum y aun así instalarse sin contenido. Aquí se abrió el paquete y se contaron las clases que trae dentro.

## Mejoras aplicadas antes de publicar

- Guardado transaccional: la interfaz cambia solo después de confirmar persistencia.
- Rechazo de identificadores de clase inexistentes.
- Pantalla de recuperación si falla la carga inicial.
- Planificación rítmica sobre `Stopwatch` para corregir la deriva acumulada de temporizadores periódicos.
- Explicación visible y documental de activación de sonido/vibración y ausencia de cámara/micrófono.
- Auditoría de permisos como condición de release.
- Empaquetado reproducible Android y Windows en tres modalidades.

## Validación humana pendiente

No se ha acreditado todavía:

- revisión completa por docente de Educación Física;
- revisión por personas cultoras de variantes distintas;
- prueba observada con 5–8 niños y autorización adulta;
- auditoría con TalkBack, Narrador y navegación por teclado;
- ensayo en distintos pisos, tamaños de pantalla y dispositivos hápticos;
- firma comercial de Windows;
- clave Android permanente confirmada.

Estas tareas no pueden sustituirse con análisis estático. Sigue `docs/TEACHER_REVIEW.md`.

## Reproducir

```bash
node tool/validate_repository.mjs
node tool/validate_curriculum.mjs
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
```

Y sobre un APK compilado o descargado, con las build-tools de Android instaladas:

```bash
node tool/verify_apk.mjs PanueloAlViento-0.1.0-Android.apk 0.1.0
```

La evidencia definitiva de compilación queda en la ejecución del workflow asociada al tag `v0.1.0`.

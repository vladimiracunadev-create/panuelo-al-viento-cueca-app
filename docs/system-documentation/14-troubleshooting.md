# 14 · Troubleshooting

Cada entrada: síntoma → causa → diagnóstico → solución → archivos → **riesgo de
aplicar la solución**.

---

## Entorno y arranque

### T-01 · «No supported devices connected» o no aparece Windows ni Android

**Causa.** Las carpetas `android/` y `windows/` no existen. `.gitignore` las
excluye porque se generan al preparar el proyecto.

**Diagnóstico.**
```bash
ls -d android windows 2>&1     # No such file or directory
grep -n "^/android/" .gitignore
```

**Solución.** Ejecutar el bootstrap correspondiente:
```powershell
.\tool\bootstrap.ps1     # Windows
```
```bash
./tool/bootstrap.sh      # Linux y macOS
```

**Archivos.** `tool/bootstrap.ps1`, `tool/bootstrap.sh`, `tool/configure_platforms.mjs`, `.gitignore`

**Riesgo.** Ninguno. Es el flujo previsto y los scripts abortan al primer fallo.
Se ejecutan `flutter analyze` y `flutter test` al final, así que tarda varios
minutos.

---

### T-02 · `No se encontró ninguna plataforma generada`

**Causa.** Se ejecutó `node tool/configure_platforms.mjs` sin haber ejecutado
antes `flutter create`. El script lanza a propósito en vez de terminar en
silencio.

**Diagnóstico.** El mensaje es explícito y viene del final de
`configure_platforms.mjs`.

**Solución.** Ejecutar el bootstrap completo, no el configurador suelto.

**Archivos.** `tool/configure_platforms.mjs:68`

**Riesgo.** Ninguno.

---

### T-03 · «No pudimos abrir la ruta de aprendizaje» al abrir la app

**Causa.** El arranque lanzó una excepción. Tres posibilidades: el activo del
currículo no está en el paquete, el JSON es inválido, o las preferencias del
sistema no se pudieron abrir.

**Diagnóstico.** En una ejecución de desarrollo, el error real se imprime porque
`main` lo pasa por `FlutterError.reportError`. Sobre un artefacto instalado, la
comprobación es externa:
```bash
node tool/verify_apk.mjs <apk>          # ¿llegó el currículo al paquete?
node tool/validate_curriculum.mjs       # ¿es válido el JSON del repositorio?
```

**Solución.** Si el JSON es inválido, corregirlo y volver a compilar. Si el
activo falta, revisar la sección `assets:` de `pubspec.yaml`. Si es el
almacenamiento, reinstalar.

**Archivos.** `lib/main.dart:9-31`, `lib/data/curriculum_repository.dart`, `pubspec.yaml`

**Riesgo.** Bajo. Si se decidiera capturar la excepción más abajo para «que no
falle», se destruiría la pantalla de recuperación y volvería la pantalla en
blanco. No hacerlo.

---

## Currículo y contenido

### T-04 · `Currículo inválido: <lista de errores>`

**Causa.** El JSON incumple una de las reglas estructurales.

**Diagnóstico.** La salida enumera cada incumplimiento con el identificador de
la clase afectada. Los mensajes más frecuentes:

| Mensaje | Qué corregir |
|---|---|
| `Se esperaban 8 niveles y hay N` | Cardinalidad de `levels` |
| `<id> debe tener 3 clases` | Cardinalidad de `lessons` en ese nivel |
| `<id>: actividades=N, clase=M` | Los `minutes` no suman `durationMinutes` |
| `Orden repetido: N` | Dos clases con el mismo `order` |
| `Falta el orden N` | Hueco en la numeración 1–24 |
| `<id> no tiene <campo>` | Campo de texto vacío o ausente |

**Solución.** Corregir `assets/content/curriculum.json` y volver a validar.

**Archivos.** `assets/content/curriculum.json`, `tool/validate_curriculum.mjs`

**Riesgo.** Medio si se «arregla» relajando el validador en vez del dato: se
perdería la garantía y las tres pruebas de integridad fallarían igualmente.

---

### T-05 · Una clase muestra un esquema de piso que no corresponde

**Causa.** Su campo `diagram` tiene un valor sin rama propia en el pintor. En
0.1.0 ocurre con `pair` (4 clases) y `free` (3 clases), que caen ambos en la
rama por defecto.

**Diagnóstico.**
```bash
node -e "const c=require('./assets/content/curriculum.json');
  const m={}; for(const l of c.levels) for(const s of l.lessons)
  m[s.diagram]=(m[s.diagram]||0)+1; console.log(m)"
grep -n "case '" lib/widgets/movement_diagram.dart
```

**Solución.** Es un hallazgo abierto, **no corregido en esta documentación**.
Hay dos caminos y requieren una decisión: añadir ramas de dibujo para `pair` y
`free`, o cambiar el valor de esas clases a uno que sí tenga dibujo. Ver
[15 · Riesgos](15-risks-and-technical-debt.md), R-02.

**Archivos.** `lib/widgets/movement_diagram.dart`, `assets/content/curriculum.json`

**Riesgo.** Bajo en el código; **medio en lo pedagógico**: el dibujo comunica una
intención de movimiento y cambiarlo altera lo que se enseña. Debería revisarlo
quien redactó el currículo.

---

## Persistencia

### T-06 · «No fue posible guardar el avance en este dispositivo»

**Causa.** `SharedPreferences.setStringList` devolvió `false`.
`ProgressRepository` lo convierte en `StateError` en lugar de simular éxito.

**Diagnóstico.** Comprobar espacio en disco y permisos del perfil de usuario. En
Windows, que el perfil no sea de solo lectura.

**Solución.** Liberar espacio o reinstalar. El mensaje es correcto: la clase
**no** quedó guardada, y la interfaz no la muestra como completada.

**Archivos.** `lib/data/progress_repository.dart:24-30`, `lib/state/app_state.dart`

**Riesgo.** Alto si se «resuelve» eliminando el `throw`. Sin él, `AppState` no
tiene forma de saber que la escritura falló y la interfaz mostraría avance que el
disco no respalda. Es exactamente lo que impiden las tres pruebas de
`test/app_state_test.dart`.

---

### T-07 · El avance desapareció tras actualizar en Android

**Causa.** La versión nueva se firmó con una clave distinta. Android exige
desinstalar, y al desinstalar se borran las preferencias.

**Diagnóstico.**
```bash
apksigner verify --print-certs <apk-nuevo>
apksigner verify --print-certs <apk-anterior>
```
Si los certificados difieren, esa es la causa.

**Solución.** Preventiva, no correctiva: configurar los cuatro secrets de firma
descritos en [`../BUILD_MOBILE.md`](../BUILD_MOBILE.md) **antes** de publicar la
siguiente versión. Una vez perdido, el avance no se recupera: no hay copia en la
nube ni exportación en 0.1.0.

**Archivos.** `.github/workflows/release.yml:99-130`, `tool/configure_android_signing.mjs`

**Riesgo.** Ninguno al configurar la firma. El riesgo está en **no** hacerlo:
cada release sin secrets genera una clave irrepetible y repite el problema.

---

### T-08 · El porcentaje no llega al 100 % aunque se completaron todas

**Causa.** `AppState.load()` cruza el avance guardado con los identificadores
válidos. Si el currículo cambió de identificadores, los antiguos se descartan.

**Diagnóstico.** Comparar los `id` guardados con los del currículo actual. En
desarrollo:
```dart
debugPrint(state.completedLessonIds.toString());
```

**Solución.** Comportamiento correcto y deliberado: evita que un porcentaje
quede atascado por clases retiradas. Si el cambio de identificadores no era
intencionado, revertirlo en el JSON.

**Archivos.** `lib/state/app_state.dart`, `assets/content/curriculum.json`

**Riesgo.** Ninguno. Nótese que el descarte es solo en memoria: los
identificadores huérfanos siguen en disco hasta la próxima escritura.

---

## Ritmo

### T-09 · El clic sigue sonando después de salir de la pestaña Ritmo

**Causa.** `HomeShell` mantiene las cuatro pestañas en un `IndexedStack`, que no
destruye las no visibles. `_RhythmLabScreenState.dispose()` no se ejecuta al
cambiar de pestaña y el temporizador sigue programando pulsos.

**Diagnóstico.** Verificado en pruebas durante este análisis: iniciar el pulso,
cambiar a Inicio y contar las señales emitidas. Se emiten. Al volver a Ritmo, el
botón sigue diciendo «Detener».

**Solución.** Para quien usa la aplicación: pulsar **Detener** antes de cambiar
de pestaña. Como cambio de código es un hallazgo abierto y **no corregido**; ver
[15 · Riesgos](15-risks-and-technical-debt.md), R-01.

**Archivos.** `lib/screens/home_shell.dart:40-43`, `lib/screens/rhythm_lab_screen.dart`, `docs/PERMISSIONS.md`

**Riesgo de corregirlo.** Medio, y depende del camino. Sustituir el
`IndexedStack` perdería la posición de desplazamiento de las cuatro pestañas.
Detener el pulso al cambiar de pestaña requiere que `HomeShell` conozca el estado
del laboratorio, lo que introduce acoplamiento donde hoy no lo hay. La opción
menos invasiva es un `TickerMode` o una notificación de visibilidad. Sea cual
sea, hay que actualizar `docs/PERMISSIONS.md` o el código, porque hoy se
contradicen.

---

### T-10 · No vibra

**Causa.** Tres posibles, en este orden de probabilidad: el equipo no tiene motor
háptico (habitual en escritorio), el interruptor **Vibración** está apagado, o el
pulso actual no es un acento —la háptica solo se emite en los acentos—.

**Diagnóstico.** Comprobar que el interruptor esté encendido y observar si la
vibración coincide con los círculos destacados (1 y 4 en 3+3; 1, 3 y 5 en
2+2+2).

**Solución.** Ninguna en escritorio: es una limitación de hardware declarada en
[`../ACCESSIBILITY.md`](../ACCESSIBILITY.md). La aplicación funciona igual sin
ella.

**Archivos.** `lib/screens/rhythm_lab_screen.dart`

**Riesgo.** Ninguno.

---

## Compuertas y CI

### T-11 · `dart format` falla en CI pero en local no

**Causa.** El formateador de Dart cambia entre versiones. CI fija Flutter 3.44.6
(Dart 3.12.2).

**Diagnóstico.**
```bash
flutter --version
grep -n "FLUTTER_VERSION" .github/workflows/ci.yml
```

**Solución.** Formatear con la misma versión que CI, tal como pide
[`../../CONTRIBUTING.md`](../../CONTRIBUTING.md):
```bash
dart format lib test tool
dart format --output=none --set-exit-if-changed lib test tool
```

**Archivos.** `.github/workflows/ci.yml:14`, `.github/workflows/release.yml:23`

**Riesgo.** Ninguno. Aviso: la versión de Flutter está escrita en **dos**
archivos; cambiar uno sin el otro deja CI y release en desacuerdo.

---

### T-12 · `Repositorio inválido: …`

**Causa.** `validate_repository.mjs` detectó una incoherencia. Es la compuerta
que más falla, porque comprueba la parte que se desincroniza sola.

| Mensaje | Qué corregir |
|---|---|
| `Falta docs/releases/vX.Y.Z.md` | Escribir las notas de esa versión |
| `CHANGELOG.md encabeza la versión A y pubspec.yaml declara B` | Encabezar el CHANGELOG con la versión del manifiesto |
| `README.md no nombra el artefacto …` | Actualizar los cuatro nombres del README |
| `README.md muestra docs/… pero el archivo no existe` | Regenerar las capturas o corregir la ruta |
| `Las notas de la versión usan enlaces relativos…` | Convertirlos en absolutos: en GitHub Releases los relativos no resuelven |
| `site/index.html debe usar __APP_VERSION__…` | Restituir el marcador |
| `site/index.html nombra artefactos con una versión fija` | Sustituir el número por `__APP_VERSION__` |
| `Esta versión no debe usar <cadena>` | Se introdujo una dependencia o API prohibida |

**Archivos.** `tool/validate_repository.mjs`, y el archivo que nombre el mensaje

**Riesgo.** Alto si se resuelve relajando el validador. Cada comprobación existe
porque el fallo correspondiente es fácil de cometer y difícil de notar. El
mensaje del código lo justifica en cada caso.

---

### T-13 · `Ningún archivo de site/ usa __APP_VERSION__`

**Causa.** Alguien escribió el número de versión a mano en la landing.

**Diagnóstico.**
```bash
grep -c "__APP_VERSION__" site/index.html          # debe dar 5
grep -n "PanueloAlViento-[0-9]" site/index.html    # no debe dar nada
```

**Solución.** Restituir el marcador en los cinco lugares.

**Archivos.** `site/index.html`, `tool/build_site.mjs:47-52`

**Riesgo.** Ninguno al corregirlo. El riesgo es el que la comprobación evita:
una landing que ofrece descargas con 404 tras publicar una versión nueva, y
nadie se entera hasta que alguien la intenta.

---

### T-14 · `No se encontró aapt2`

**Causa.** `verify_apk.mjs` no localizó las build-tools de Android.

**Diagnóstico.**
```bash
echo $ANDROID_SDK_ROOT
ls "$ANDROID_SDK_ROOT/build-tools"
```

**Solución.** Instalar las build-tools, o apuntar directamente al binario:
```bash
AAPT2=/ruta/a/aapt2 node tool/verify_apk.mjs <apk>
```

**Archivos.** `tool/verify_apk.mjs:33-59`

**Riesgo.** Ninguno. Sin `aapt2` no se puede verificar un APK, pero el resto de
las compuertas funciona.

---

### T-15 · Artefactos inesperados en la release de Windows

**Causa.** El job `windows` exige exactamente tres archivos en
`release-artifacts` y rechaza cualquier otro. El caso conocido es el `.wixpdb`
que genera WiX.

**Diagnóstico.** El mensaje enumera los archivos sobrantes.

**Solución.** Dirigir los archivos auxiliares fuera de `release-artifacts`, como
ya hace `light.exe` con `-pdbout build/wix/…`.

**Archivos.** `.github/workflows/release.yml:222-237`

**Riesgo.** Alto si se resuelve relajando la comprobación: es lo que impide
publicar símbolos de compilación junto a los binarios.

---

## Documentación y PDF

### T-16 · Los diagramas salen como código fuente en el PDF

**Causa.** `mmdc` no está instalado o no se pudo lanzar. El generador **avisa**;
no degrada en silencio.

**Diagnóstico.** El resumen final dice `N degradados a texto` y añade un aviso
explícito.

**Solución.**
```bash
npm install -g @mermaid-js/mermaid-cli
python tool/build_docs_pdf.py
```

**Archivos.** `tool/build_docs_pdf.py`

**Riesgo.** Ninguno. En Windows, `mmdc` es un `.cmd` y Node ≥ 20.12 se niega a
lanzarlo sin shell; el script ya lo invoca a través de `cmd /c`.

---

### T-17 · Una tabla del PDF sale ilegible o desbordada

**Causa.** Casi siempre, una tabla Markdown con la fila de cabecera vacía
(`| | |` seguido de `|---|---|`). Los motores de PDF colapsan los anchos de
columna y el texto sale a una palabra por línea.

**Diagnóstico.** Buscar tablas sin encabezado real en el Markdown de origen.

**Solución.** Dar un encabezado real en el Markdown (`| Aspecto | Detalle |`).
No pelearse con el CSS: el problema está en el dato, no en el estilo.

**Archivos.** El `.md` correspondiente, `tool/build_docs_pdf.py`

**Riesgo.** Ninguno. Nótese que el README principal del repositorio sí usa una
tabla sin encabezado para la galería de capturas; es correcto en GitHub y sería
un problema solo si ese archivo se convirtiera a PDF con este generador, cosa
que no ocurre.

---

### T-18 · Signos como → ≥ ● ★ no aparecen en el PDF

**Causa.** No se resolvió ninguna fuente TrueType con cobertura amplia y se
usaron las fuentes base de PDF.

**Diagnóstico.** El script imprime la tipografía usada al empezar y avisa al
final si cayó en el respaldo.

**Solución.** Instalar DejaVu, o ejecutar donde haya Arial y Consolas. El script
también busca las fuentes que empaqueta `matplotlib`, que es el respaldo más
fiable.

**Archivos.** `tool/build_docs_pdf.py`

**Riesgo.** Ninguno.

---

## Índice rápido

| Síntoma | Entrada |
|---|---|
| No hay dispositivos ni plataformas | T-01 |
| `No se encontró ninguna plataforma generada` | T-02 |
| Pantalla de error al abrir la app | T-03 |
| `Currículo inválido` | T-04 |
| Esquema de piso equivocado | T-05 |
| No se guarda el avance | T-06 |
| El avance desapareció al actualizar | T-07 |
| El porcentaje no llega al 100 % | T-08 |
| El clic sigue sonando fuera de Ritmo | T-09 |
| No vibra | T-10 |
| `dart format` falla solo en CI | T-11 |
| `Repositorio inválido` | T-12 |
| Versión escrita a mano en la landing | T-13 |
| `No se encontró aapt2` | T-14 |
| Artefactos inesperados en Windows | T-15 |
| Diagramas como texto en el PDF | T-16 |
| Tabla ilegible en el PDF | T-17 |
| Signos ausentes en el PDF | T-18 |

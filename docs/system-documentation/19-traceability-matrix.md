# 19 · Matriz de trazabilidad

Cada fila permite seguir una funcionalidad desde la interfaz hasta la
persistencia y sus pruebas **sin salir de la fila**.

Cuando una celda dice `ninguna`, es un hueco de cobertura real, no una omisión de
este documento.

**Convención de nombres abreviados.** Para que cada fila quepa sin partirse, la
columna de módulo da solo el nombre del archivo, sin `lib/…/` ni `.dart`, y la de
prueba omite `test/` y `_test.dart`. Así, `lesson_screen` es
`lib/screens/lesson_screen.dart` y `app_state` en la última columna es
`test/app_state_test.dart`. El directorio de cada archivo está en
[04 · Mapa del código](04-code-map.md).

---

## Funcionalidades del producto

| Funcionalidad | Dónde se ve | Módulo | Símbolo | Dato | Prueba |
|---|---|---|---|---|---|
| Ver el porcentaje de avance | Inicio · «Tu recorrido» | `home_tab` | `_ProgressCard` → `progress` | avance (lectura) | indirecta en `app_state` |
| Ver la próxima clase | Inicio | `app_state` | `nextLesson` | currículo + avance | **ninguna** |
| Ver el cierre de la ruta | Inicio | `home_tab` | `_FinishedCard` | avance | **ninguna** |
| Ir a la Ruta desde Inicio | Inicio · tarjeta | `home_shell` | `onOpenRoute` | ninguno | `app_smoke` (parcial) |
| Ir al Ritmo desde Inicio | Inicio · tarjeta | `home_shell` | `onOpenRhythm` | ninguno | `app_smoke` (parcial) |
| Recorrer los ocho niveles | Ruta | `route_tab` | `RouteTab.build` | currículo | `app_smoke` · `curriculum_integrity` |
| Ver el avance de un nivel | Ruta · anillo | `app_state` | `levelProgress` | currículo + avance | **ninguna** |
| Abrir el nivel a medias | Ruta · desplegable | `route_tab` | `initiallyExpanded` | avance | **ninguna** |
| Abrir una clase | Inicio y Ruta | `route_tab` | `Navigator.push` | currículo | `app_smoke` (parcial) |
| Leer el contexto | Clase · tarjeta | `lesson_screen` | `lesson.why` | currículo | `curriculum_integrity` |
| Ver el esquema de piso | Clase | `movement_diagram` | `_MovementPainter` | `lesson.diagram` | **ninguna** |
| Oír su descripción | Clase · lector | `movement_diagram` | `_description` | `lesson.diagram` | **ninguna** |
| Marcar las actividades | Clase · casillas | `lesson_screen` | `_activityChecks` | **nada persistido** | **ninguna** |
| Habilitar el botón | Clase · botón | `lesson_screen` | `_allActivitiesChecked` | estado local | **ninguna** |
| **Completar una clase** | Clase · botón | `app_state` → `progress_repository` | `completeLesson` → `writeCompletedLessonIds` | avance (escritura) | **`app_state` ×2** · `progress_repository` |
| Rechazar clase inexistente | defensa interna | `app_state` | `completeLesson` → `ArgumentError` | protege el almacén | **`app_state`** |
| No publicar sin confirmar | defensa interna | `app_state` · `progress_repository` | orden `await` → asignación | avance | **`app_state`** |
| Repetir una clase | Clase · botón | `lesson_screen` | `_finishRepeat` | **nada**: no escribe | **ninguna** |
| Ver el avance por nivel | Avance | `progress_tab` | `_HeroProgress` · `levelProgress` | currículo + avance | `app_smoke` (navegación) |
| Ver cámara y micrófono | Avance · tarjeta | `progress_tab` | `_CapabilityLine` | ninguno; texto fijo | **`app_smoke`** (afirma ambos) |
| **Reiniciar el avance** | Avance · botón | `app_state` → `progress_repository` | `resetProgress` → `clear` | avance (borrado) | **`app_state`** · `progress_repository` |
| Confirmar antes de borrar | Avance · diálogo | `progress_tab` | `_confirmReset` | — | **ninguna** |
| Elegir la agrupación | Ritmo · segmentos | `rhythm_lab_screen` | `_pattern` → `_accents` | **nada persistido** | **ninguna** |
| Regular la velocidad | Ritmo · deslizador | `rhythm_lab_screen` | `_bpm` → `_startSchedule` | **nada persistido** | **ninguna** |
| Iniciar y detener el pulso | Ritmo · botón | `rhythm_lab_screen` | `_toggle` | ninguno | **ninguna** |
| Corregir la deriva | Ritmo · invisible | `rhythm_lab_screen` | `_scheduleNextPulse` | ninguno | **ninguna** |
| Emitir el clic | Ritmo · «Sonido» | `rhythm_lab_screen` | `_emitPulse` | ninguno | **ninguna** |
| Emitir la háptica | Ritmo · «Vibración» | `rhythm_lab_screen` | `_emitPulse`, solo acentos | ninguno | **ninguna** |
| Adaptar al ancho | Todas | `home_shell` | `LayoutBuilder`, umbral 840 | ninguno | **ninguna** |
| Seguir el modo del sistema | Todas | `app` · `app_theme` | `ThemeMode.system` | ninguno | **`theme_contrast` ×16** |
| Recuperarse de un fallo | Pantalla de error | `main` | `try` → `_StartupErrorApp` | — | **ninguna** |
| Descartar avance huérfano | invisible | `app_state` | `load` → `intersection` | avance (lectura) | **ninguna** |

### Lectura de la matriz

Diecinueve de las treinta y tres filas dicen `ninguna`. Concentradas en dos
zonas: **la interfaz** —un solo smoke test para cinco pantallas— y **el
laboratorio de ritmo**, que no tiene ninguna prueba pese a ser el componente con
más lógica del proyecto.

Las filas mejor cubiertas son exactamente las que más importan: las tres reglas
transaccionales del avance, con dos o tres pruebas cada una.

---

## Compuertas del repositorio

| Regla que se protege | Herramienta | Dónde se ejecuta | Qué comprueba | Fallo que evita |
|---|---|---|---|---|
| El currículo tiene 8 niveles y 24 clases | `tool/validate_curriculum.mjs` | CI, release, bootstrap | Cardinalidades, unicidad, órdenes, minutos, campos | Contenido incompleto en el binario |
| Ídem, en Dart | `tool/validate_curriculum.dart` | **Manual** | Lo mismo | — (duplicado, R-08) |
| Ídem, por el modelo real | `test/curriculum_integrity_test.dart` | `flutter test` | Lo mismo más el rango 10–15 min | Que el modelo y el validador diverjan |
| La versión es una sola | `tool/app_version.mjs` | Consumido por 4 herramientas | Formato `X.Y.Z+N` en `pubspec.yaml` | Publicar con dos versiones distintas |
| La documentación no miente | `tool/validate_repository.mjs` | CI, release, bootstrap | 32 archivos, coherencia de versión, capturas, enlaces de notas, marcador de la landing | README que promete descargas inexistentes |
| La landing se puede ensamblar | `tool/build_site.mjs` | CI, release, `pages.yml` | Marcador presente, capturas presentes, imágenes referenciadas existentes | Landing con huecos rotos o descargas 404 |
| No hay sensores en el código | `tool/validate_repository.mjs` | CI, release | Cadenas prohibidas en 7 archivos | Dependencia que arrastre un permiso |
| No hay sensores en el manifiesto fuente | `tool/configure_platforms.mjs` · `release.yml` | Bootstrap y release | `CAMERA` y `RECORD_AUDIO` en `android/app/src` | Permiso añadido a mano |
| No hay sensores en el manifiesto fusionado | `tool/verify_apk.mjs` | `release.yml` | Siete permisos prohibidos, incluido `INTERNET` | Permiso que aporta una dependencia |
| El APK lleva el contenido dentro | `tool/verify_apk.mjs` | `release.yml` | Currículo extraído, contado y comparado por SHA-256 | Artefacto que se instala vacío |
| El APK declara la versión correcta | `tool/verify_apk.mjs` | `release.yml` | `versionName`, `versionCode`, `minSdkVersion`, ABIs | Publicar el binario equivocado |
| El APK está firmado | `apksigner` | `release.yml` | Validez de la firma | Artefacto no instalable |
| El ejecutable Windows arranca | `release.yml` | Release | Lo lanza 8 s y comprueba el código de salida | Binario que compila y no abre |
| El ejecutable Windows declara la versión | `release.yml` | Release | `ProductVersion` | Ídem que el APK |
| Los cuatro artefactos tienen el nombre exacto | `release.yml` | Release | Presencia y ausencia de sobrantes | Publicar símbolos o versiones mezcladas |
| El tag coincide con el manifiesto | `release.yml`, job `version` | Release | `$TAG_NAME == v$APP_VERSION` | Un tag `v0.2.0` publicando archivos `0.1.0` |
| Existen las notas de la versión | `release.yml` · `validate_repository.mjs` | Release y CI | `docs/releases/v<versión>.md` | Publicar sin explicación |
| El formato es reproducible | `dart format --set-exit-if-changed` | CI, release | 22 archivos de `lib`, `test` y `tool` | Un paso que pasa siempre sin comprobar nada |
| El análisis estático está limpio | `flutter analyze` | CI, release | `flutter_lints` + 3 reglas propias | Uso de contexto tras `await`, entre otros |
| El texto se lee en ambos modos | `test/theme_contrast_test.dart` | `flutter test` | 16 pares WCAG, umbral 4,5:1 | Una tarjeta ilegible en modo oscuro |

---

## Requisitos declarados y su evidencia

Trazabilidad inversa: cada promesa pública del proyecto y dónde se sostiene.

| Promesa | Declarada en | Sostenida por | Estado |
|---|---|---|---|
| «24 clases, 8 niveles, 72 actividades» | README, landing, CHANGELOG | Dato + 2 validadores + 3 pruebas | **Verificado** |
| «Funciona sin conexión» | README, landing | Currículo empaquetado; sin APIs de red | **Verificado** |
| «No usa cámara ni micrófono» | README, landing, `PRIVACY.md`, interfaz | 3 controles independientes | **Verificado** en el código; en el APK, según `VALIDATION_RESULT.md` |
| «El APK no declara ningún permiso» | README, `PERMISSIONS.md` | `verify_apk.mjs` | `REQUIERE VALIDACIÓN` aquí: no se reprodujo la medición por falta de `aapt2` |
| «Solo guarda identificadores de clases» | `PRIVACY.md`, interfaz | `ProgressRepository`, clave única | **Verificado** |
| «Guardado transaccional» | README, `ARCHITECTURE.md` | 3 pruebas dedicadas | **Verificado** |
| «25 pruebas y 2 validadores» | README | `flutter test` → `+25`; dos `.mjs` en CI | **Verificado** |
| «Contraste WCAG AA en ambos modos» | README | 16 pruebas | **Verificado** para los pares del `ColorScheme`; no cubre el lienzo (R-15) |
| «Seis patrones de diagrama» | README, CHANGELOG, notas | 5 ramas de dibujo, 7 valores en el dato | **Contradicho** — ver R-02 |
| «Clases de 10 a 15 minutos» | README, plan de 8 semanas, notas | Las 24 duran 12 | **Impreciso** — ver R-07 |
| «Cambiar de pantalla cancela el temporizador» | `PERMISSIONS.md`, paso 6 | El `IndexedStack` no lo destruye | **Contradicho** — ver R-01 |
| «Landing pendiente para 0.2» | `ROADMAP.md` | Ya publicada en el commit analizado | **Contradicho** — ver R-03 |
| «Nivel 8: Diversidad y presentación» | README, `CURRICULUM.md` | El dato dice «Cuecas de Chile y presentación» | **Contradicho** — ver R-04 |
| «Validación pedagógica pendiente» | README, `VALIDATION_RESULT.md`, `TEACHER_REVIEW.md` | Declarado, no automatizable | **Correcto y honesto** |

## Continuar por

- [15 · Riesgos](15-risks-and-technical-debt.md) para los cinco contradichos.
- [12 · Pruebas y calidad](12-testing-and-quality.md) para los huecos de
  cobertura.

# 04 · Mapa del código

Inventario jerárquico de todo lo versionado. Cada elemento lleva ubicación,
responsabilidad, dependencias, quién lo usa y **estado aparente**.

Estados usados: **activo** (participa en el producto o en sus compuertas),
**duplicado** (existe otro que hace lo mismo), **auxiliar** (herramienta que no
entra en el binario), **no determinado**.

## Árbol versionado

```text
panuelo-al-viento-cueca-app/
├── .github/workflows/     3 workflows
├── assets/
│   ├── branding/          logo.svg · app-icon.png
│   └── content/           curriculum.json  (43 165 bytes)
├── docs/                  18 documentos + releases/ + screenshots/ + system-documentation/
├── lib/                   15 archivos Dart · 2 417 líneas
├── packaging/windows/     installer.iss · product.wxs
├── site/                  index.html  (317 líneas)
├── test/                  6 archivos · 25 pruebas
├── tool/                  11 herramientas
├── pubspec.yaml · pubspec.lock · analysis_options.yaml
├── .gitignore · .gitattributes · .editorconfig
└── README · CHANGELOG · ROADMAP · SECURITY · CONTRIBUTING · CODE_OF_CONDUCT · LICENSE
```

`MASTER_PROMPT.md` existe en el directorio de trabajo pero **no está versionado**:
`.gitignore` lo excluye con el comentario «Documento de trabajo local; no forma
parte del producto publicado». No se le hace referencia desde ningún archivo que
sí lo esté, salvo `CONTRIBUTING.md`, que no lo menciona. `NO DOCUMENTADO EN EL
REPOSITORIO`: su existencia no se explica en ninguna parte pública.

## `lib/` — el producto

### `lib/main.dart` · 89 líneas · **activo**

| Aspecto | Detalle |
|---|---|
| Responsabilidad | Punto de entrada. Resuelve dependencias en orden y decide si arranca la aplicación o la pantalla de recuperación. |
| Depende de | `shared_preferences`, `app.dart`, ambos repositorios, `AppState`. |
| Lo usa | El motor de Flutter. |
| Símbolos | `main()`, `_StartupErrorApp` (privado). |
| No obvio | El `try` envuelve **todo** el arranque asíncrono. Un activo corrompido o un almacenamiento inaccesible producen una pantalla explicativa en vez de una en blanco. `_StartupErrorApp` no ofrece reintento a propósito. |

### `lib/app.dart` · 32 líneas · **activo**

| Aspecto | Detalle |
|---|---|
| Responsabilidad | `MaterialApp` raíz: título, temas y pantalla inicial. |
| Depende de | `AppTheme`, `HomeShell`, `AppState`. |
| Lo usa | `main()` y `test/app_smoke_test.dart`. |
| No obvio | `themeMode: ThemeMode.system` sin selector propio. La preferencia de contraste ya está en el dispositivo; añadir un control sería una decisión más que explicar a una niña o un niño. |

### `lib/core/app_theme.dart` · 138 líneas · **activo**

| Aspecto | Detalle |
|---|---|
| Responsabilidad | `AppColors` (8 constantes) y `AppTheme` (`light`, `dark`, `_base`, `_textTheme`). |
| Depende de | Solo Material. |
| Lo usa | `app.dart`, `home_tab.dart` y `movement_diagram.dart` (estos dos por `AppColors`). |
| No obvio | Los roles `*Container` se declaran a mano en los dos modos. El propio archivo explica por qué: `ColorScheme.fromSeed` no regenera los contenedores cuando se sobrescribe `primary`, `secondary` o `tertiary`, y el resultado eran tarjetas ocre sobre fondo azulado en modo oscuro. `AppColors.redDeep` existe porque el rojo de marca sobre blanco solo alcanza 4,2:1. |

Este archivo ya tenía comentarios de calidad antes de este trabajo y **no se
tocó**: añadir explicación a un código bien explicado lo empeora.

### `lib/domain/curriculum.dart` · 193 líneas · **activo**

| Aspecto | Detalle |
|---|---|
| Responsabilidad | Los cuatro modelos inmutables y la conversión desde JSON. |
| Depende de | **Nada.** Ni del proyecto ni de Flutter. |
| Lo usa | `data`, `state`, cuatro pantallas, dos widgets y tres archivos de prueba. |
| Símbolos | `ActivityType` (enum, 6 valores), `activityTypeFromJson`, `LearningActivity`, `Lesson`, `LearningLevel`, `Curriculum`. |
| No obvio | `activityTypeFromJson` degrada a `discover` ante un valor desconocido en vez de lanzar; el resto de las fábricas no toleran campos ausentes. La asimetría es deliberada: `type` no cambia lo que se muestra. |

### `lib/data/curriculum_repository.dart` · 27 líneas · **activo**

Lee `assets/content/curriculum.json` con `rootBundle` y devuelve un
`Curriculum`. Constructor `const`, sin estado. No captura errores: la excepción
sube hasta `main`. Lo usan `AppState` y tres archivos de prueba.

### `lib/data/progress_repository.dart` · 68 líneas · **activo**

| Aspecto | Detalle |
|---|---|
| Responsabilidad | `ProgressStore` (interfaz) y `ProgressRepository` (implementación sobre `SharedPreferences`). |
| Depende de | `shared_preferences`. |
| Lo usa | `main.dart`, `AppState`, `test/progress_repository_test.dart`, `test/app_smoke_test.dart`. |
| No obvio | La interfaz existe **solo** para poder inyectar un almacén que falle en las pruebas. Ambos métodos de escritura lanzan `StateError` si la operación no se confirma: devolver sin más sería indistinguible del éxito. Escribe siempre ordenado, para que dos ejecuciones con el mismo avance produzcan el mismo valor. |

### `lib/state/app_state.dart` · 126 líneas · **activo**

| Aspecto | Detalle |
|---|---|
| Responsabilidad | Única fuente de verdad en memoria y todas las reglas de negocio. |
| Depende de | Ambos repositorios y el dominio. |
| Lo usa | `main.dart`, `app.dart`, `home_shell.dart` y las cuatro pantallas principales, más `lesson_screen.dart`. |
| Símbolos | `curriculum`, `completedLessonIds`, `completedCount`, `totalCount`, `progress`, `nextLesson`, `load`, `isCompleted`, `levelProgress`, `completeLesson`, `resetProgress`. |
| No obvio | `completedLessonIds` devuelve `Set.unmodifiable`: nadie fuera puede alterar el avance sin pasar por los métodos que persisten. `load()` cruza lo guardado con los identificadores válidos y descarta el resto **sin reescribir el almacén**. |

### `lib/screens/` — cinco pantallas

| Archivo | Líneas | Estado | Responsabilidad | Símbolos privados |
|---|---:|---|---|---|
| `home_shell.dart` | 143 | activo | Contenedor, navegación adaptable y `IndexedStack`. | `_HomeShellState` |
| `home_tab.dart` | 299 | activo | Bienvenida, progreso, próxima clase y dos accesos. | `_ProgressCard`, `_ActionCard`, `_FinishedCard` |
| `route_tab.dart` | 121 | activo | Los ocho niveles desplegables con sus clases. | `_LevelProgress` |
| `lesson_screen.dart` | 299 | activo | Detalle de una clase y su cierre. | `_LessonScreenState`, `_ActivityTile`, `_InfoCard` |
| `rhythm_lab_screen.dart` | 356 | activo | Metrónomo de seis pulsos. | `_PulsePattern`, `_RhythmLabScreenState` |
| `progress_tab.dart` | 256 | activo | Avance, privacidad visible y reinicio. | `_CapabilityLine`, `_HeroProgress` |

`rhythm_lab_screen.dart` es la única pantalla que **no recibe `AppState`**: su
constructor es `const` y no comparte nada. Es también la única con temporizador.

### `lib/widgets/` — dos componentes

| Archivo | Líneas | Estado | Nota |
|---|---:|---|---|
| `lesson_card.dart` | 78 | activo | Fila de clase, reutilizada por Inicio y Ruta. Comunica el estado completado con icono **y** color, nunca solo con color. |
| `movement_diagram.dart` | 192 | activo | Esquema de piso dibujado con `CustomPaint`. `MovementDiagram` público, `_MovementPainter` privado. |

`_MovementPainter` tiene ramas para `circle`, `eight`, `semicircle`, `steps` y
`wave`, más una rama `default`. El currículo usa **siete** valores de `diagram`:
esos cinco más `pair` y `free`, que caen ambos en `default`. La descripción
semántica de `MovementDiagram._description` sí distingue `pair`, pero no `free`.
Registrado en [15 · Riesgos](15-risks-and-technical-debt.md).

## `assets/`

| Ruta | Contenido | Estado |
|---|---|---|
| `assets/content/curriculum.json` | 8 niveles, 24 clases, 72 actividades. Campo `version: "1.0.0"`, independiente de la versión del producto. | activo |
| `assets/branding/logo.svg` | 776 bytes. Se copia a la landing como `logo.svg`. | activo |
| `assets/branding/app-icon.png` | 41 700 bytes. Fuente de `flutter_launcher_icons` para Android y Windows. | activo |

`pubspec.yaml` declara `assets/branding/` como directorio completo, así que
cualquier archivo que se añada ahí entra en el binario aunque nadie lo use.

## `test/` — 25 pruebas en 6 archivos

| Archivo | Pruebas | Qué protege |
|---|---:|---|
| `app_smoke_test.dart` | 1 | Que las cuatro secciones abran y que los textos de privacidad estén presentes. |
| `app_state_test.dart` | 3 | Las tres reglas transaccionales. Es la prueba más valiosa del repositorio. |
| `curriculum_integrity_test.dart` | 3 | 8 niveles, 24 clases, órdenes continuos, tres actividades que suman la duración, identificadores únicos. |
| `curriculum_model_test.dart` | 1 | Que `Lesson.fromJson` construya un modelo correcto. |
| `progress_repository_test.dart` | 1 | Escritura, lectura y borrado sobre `SharedPreferences` simulado. |
| `theme_contrast_test.dart` | 16 | Contraste WCAG de cada par de color realmente dibujado, en los dos modos. |

`curriculum_integrity_test.dart` importa `dart:io` para leer el archivo del
repositorio en vez del activo empaquetado. Es legítimo en una prueba y
`tool/validate_repository.mjs` no lo alcanza porque solo inspecciona archivos de
`lib/`.

## `tool/` — 11 herramientas

| Archivo | Líneas | Estado | Qué hace | Lo invoca |
|---|---:|---|---|---|
| `app_version.mjs` | 32 | activo | Única fuente de verdad de la versión. Exporta `readAppVersion()` y funciona también como CLI. | `validate_repository`, `verify_apk`, `build_site`, `release.yml` |
| `validate_repository.mjs` | 167 | activo | 32 archivos esenciales, coherencia de versión, capturas, enlaces de las notas, versión en la landing y cadenas prohibidas en el código. | CI, release, bootstrap |
| `validate_curriculum.mjs` | 62 | activo | Estructura del currículo. | CI, release, bootstrap |
| `validate_curriculum.dart` | 106 | **duplicado** | Lo mismo que el anterior, en Dart. No lo ejecuta ningún workflow ni bootstrap; solo lo mencionan `CONTRIBUTING.md` y el `MASTER_PROMPT.md` no versionado. | Manual |
| `verify_apk.mjs` | 195 | activo | Abre un APK con `aapt2`, comprueba identidad, versión, API, permisos, ABIs y compara el currículo empaquetado byte a byte. | `release.yml`, manual |
| `build_site.mjs` | 103 | activo | Ensambla la landing sustituyendo `__APP_VERSION__`. Puede servirla con `--serve`. | CI, release, `pages.yml` |
| `capture_screenshots.mjs` | 312 | auxiliar | Compila para web, sirve en localhost y conduce Chrome sin ventana por el protocolo DevTools para rehacer las 9 capturas. | Manual |
| `configure_platforms.mjs` | 71 | activo | Nombre público, `minSdk = 24`, metadatos de Windows y rechazo de permisos de cámara y micrófono. | Bootstrap y ambos jobs de compilación |
| `configure_android_signing.mjs` | 42 | activo | Inserta `signingConfigs` en el Gradle generado leyendo `key.properties`. | `release.yml` |
| `bootstrap.ps1` | 18 | activo | Preparación completa en Windows. Aborta al primer fallo. | Manual |
| `bootstrap.sh` | 18 | activo | Igual, para Linux y macOS. | Manual |
| `build_docs_pdf.py` | — | auxiliar | Genera los PDF de esta carpeta. Añadido por este trabajo. | Manual |

## `.github/workflows/`

| Workflow | Disparo | Jobs | Estado |
|---|---|---|---|
| `ci.yml` | Push y PR a `main`, manual | 1 (`quality`) | activo |
| `pages.yml` | Push a `main` que toque `site/`, capturas, marca, `pubspec.yaml` o los dos scripts implicados; manual | 1 (`deploy`) | activo |
| `release.yml` | Tag `v*`, manual con `tag` | 5 (`version` → `quality` → `android`+`windows` → `publish`) | activo |

## `packaging/windows/`

| Archivo | Herramienta | Estado |
|---|---|---|
| `installer.iss` | Inno Setup 6. `AppId` fijo, español, `x64compatible`, requiere administrador. | activo |
| `product.wxs` | WiX 3. Mismo GUID como `UpgradeCode`, idioma 1034, `perMachine`, acceso directo en el menú de inicio. | activo |

Ambos comparten el identificador `7C81FC5C-67A6-4F3A-A519-78019866B239`, lo que
`INFERENCIA` sugiere que EXE y MSI se consideran el mismo producto para efectos
de actualización. Ningún documento lo declara.

## `site/`

`index.html`, 317 líneas, autocontenido salvo por `logo.svg` y las capturas, que
`build_site.mjs` copia al ensamblar. Usa `__APP_VERSION__` en 5 lugares. La
galería referencia 8 de las 9 capturas: `09-escritorio.png` se copia pero nunca
se muestra.

## Continuar por

- [05 · Referencia técnica](05-technical-reference.md) para las firmas.
- [06 · Explicación profunda](06-deep-code-explanation.md) para el flujo interno.

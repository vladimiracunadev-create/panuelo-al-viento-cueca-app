# 15 · Riesgos y deuda técnica

> **Este documento es informativo. Ningún hallazgo se ha corregido.** El encargo
> de esta documentación fue documentar y registrar, no arreglar. La única
> excepción son los comentarios de documentación añadidos al código, que no
> cambian comportamiento.

Cada hallazgo lleva severidad, impacto, probabilidad, evidencia, ubicación,
recomendación y prioridad. La evidencia es reproducible.

## Resumen

| Id | Hallazgo | Severidad | Prioridad |
|---|---|---|---|
| R-01 | El pulso del laboratorio sobrevive al cambio de pestaña, contra lo que afirma la documentación | Alta | 1 |
| R-02 | Dos valores de `diagram` no tienen dibujo propio; la documentación anuncia seis diagramas | Media | 2 |
| R-03 | El `ROADMAP` sigue listando como pendiente la landing que ya está publicada | Media | 3 |
| R-04 | El nombre del nivel 8 difiere entre el currículo y dos documentos | Media | 4 |
| R-05 | Credenciales literales en el workflow de release | Media | 5 |
| R-06 | Cifras del currículo escritas a mano en la interfaz | Media | 6 |
| R-07 | «Clases de 10 a 15 minutos» cuando las 24 duran 12 | Baja | 7 |
| R-08 | Validador de currículo duplicado en dos lenguajes | Baja | 8 |
| R-09 | El control de cadenas prohibidas cubre 7 de 15 archivos de `lib/` | Baja | 9 |
| R-10 | La versión de Flutter está escrita en dos archivos | Baja | 10 |
| R-11 | El laboratorio de ritmo no tiene ninguna prueba | Media | 11 |
| R-12 | `docs/CONTENT_PRODUCTION.md` no está protegido por el validador | Baja | 12 |
| R-13 | La velocidad inicial no cae en una división del deslizador | Baja | 13 |
| R-14 | Una captura versionada no se usa en ninguna superficie | Baja | 14 |
| R-15 | Los colores del esquema de piso no se miden en las pruebas de contraste | Baja | 15 |
| R-16 | Sin esquema JSON formal ni migración del currículo | Media | 16 |
| R-17 | Sin escaneo de dependencias ni de secretos en CI | Baja | 17 |

---

## R-01 · El pulso sobrevive al cambio de pestaña · **Alta**

**Impacto.** Una niña o un niño inicia el metrónomo, cambia a Ruta y la
aplicación sigue emitiendo un clic del sistema en cada pulso, indefinidamente,
sin ningún control visible en pantalla. Más grave que la molestia: **contradice
una afirmación explícita de la documentación de permisos**, que es precisamente
el documento sobre el que descansa la confianza de una familia.

`docs/PERMISSIONS.md`, «Secuencia de activación del laboratorio», paso 6:

> **Detener**, cambiar de pantalla o cerrar la app cancela el temporizador.

**Probabilidad.** Alta. Cualquier persona que use el laboratorio y luego navegue
sin pulsar Detener.

**Causa.** `HomeShell` mantiene las cuatro secciones en un `IndexedStack`, que
construye y conserva a los cuatro hijos y solo pinta el seleccionado. El `State`
de las pestañas invisibles sigue vivo, `dispose()` no se ejecuta y
`_scheduleNextPulse` sigue encadenando temporizadores.

**Evidencia.** Verificado con una prueba de widget temporal durante este
análisis: se inició el pulso, se cambió a Inicio y se contaron las llamadas a
`SystemSound.play` capturadas en el canal de plataforma simulado.

```text
SONDA A · clics inmediatamente tras Comenzar: 3
SONDA B · clics tras 3 s en la pestaña Ritmo: 5
SONDA C · pestaña Inicio visible: true
SONDA D · clics emitidos MIENTRAS SE ESTÁ EN INICIO: 2
SONDA F · el botón dice: Detener (seguía sonando)
```

La prueba **no se dejó en el repositorio**: documentar no es corregir, y añadir
una prueba que falla habría cambiado el estado de las compuertas.

**Ubicación.** `lib/screens/home_shell.dart:40-43` · `lib/screens/rhythm_lab_screen.dart:325-360` · `docs/PERMISSIONS.md`

**Recomendación.** Primero decidir cuál de las dos afirmaciones es la correcta.
Si el comportamiento debe cambiar, la opción menos invasiva es envolver la
sección no visible en un `TickerMode` o notificar la visibilidad al laboratorio;
sustituir el `IndexedStack` perdería la posición de desplazamiento de las cuatro
pestañas, que es justamente lo que se buscaba con él. Si el comportamiento es
deseado —permitir practicar con el pulso mientras se lee una clase—, hay que
corregir el paso 6 de `PERMISSIONS.md` y explicarlo en la interfaz.

**Esfuerzo.** 1–2 horas el código; 15 minutos la corrección documental.

---

## R-02 · Dos valores de `diagram` sin dibujo propio · **Media**

**Impacto.** Siete clases —cuatro con `pair`, tres con `free`— muestran el mismo
esquema genérico. Quien usa un lector de pantalla recibe **dos descripciones
distintas del mismo dibujo**, porque el camino semántico sí distingue `pair`.
Varios documentos anuncian seis diagramas distintos.

**Probabilidad.** Certeza: ocurre en 7 de las 24 clases.

**Evidencia.**

```bash
$ node -e "const c=require('./assets/content/curriculum.json');
  const m={}; for(const l of c.levels) for(const s of l.lessons)
  m[s.diagram]=(m[s.diagram]||0)+1; console.log(m)"
{ pair: 4, steps: 4, circle: 4, free: 3, wave: 2, semicircle: 3, eight: 4 }
```

`_MovementPainter.paint` tiene ramas para `circle`, `eight`, `semicircle`,
`steps` y `wave`, más `default`. `MovementDiagram._description` tiene ramas para
esos cinco más `pair`, más un comodín.

Afirmaciones afectadas:

| Documento | Dice |
|---|---|
| `README.md` | «seis patrones dibujados en Flutter»; «vuelta, ocho, medialuna, pasos, diálogo y pañuelo» |
| `CHANGELOG.md`, 0.1.0 | «Diagramas semánticos originales para vuelta, ocho, medialuna, pasos, pareja y movimiento del pañuelo» |
| `docs/releases/v0.1.0.md` | «Diagramas semánticos de vuelta, ocho, medialuna, pasos, diálogo y pañuelo» |

Ninguno menciona `free`, que existe en tres clases.

**Ubicación.** `lib/widgets/movement_diagram.dart` · `assets/content/curriculum.json`

**Recomendación.** Añadir ramas de dibujo para `pair` y `free`, y una prueba que
recorra las 24 clases y afirme que cada valor de `diagram` tiene rama propia. Esa
prueba habría detectado el hallazgo. Alternativamente, decidir que ambos
comparten esquema a propósito y decirlo en la documentación.

**Esfuerzo.** 2–3 horas, más revisión pedagógica de qué debe dibujar cada uno.

---

## R-03 · El `ROADMAP` da por pendiente la landing ya publicada · **Media**

**Impacto.** El plan de la versión 0.2 promete algo que ya está hecho. Quien lea
el roadmap para decidir prioridades trabajará con información falsa.

**Evidencia.**

```bash
$ grep -n "Landing pública en GitHub Pages" ROADMAP.md
39:- Landing pública en GitHub Pages, la única superficie que violín y guitarra
   tienen y esta aplicación todavía no.
```

La línea está bajo «### 0.2 — Piloto y portabilidad de datos». Pero `site/`
existe, `.github/workflows/pages.yml` la publica, el README enlaza a la página, y
el commit `6efae74` —el analizado— se titula «Publica la landing en GitHub
Pages».

**Ubicación.** `ROADMAP.md:39`

**Recomendación.** Mover esa línea a la sección «Publicado» o eliminarla. Es el
ejemplo de libro de la diferencia entre estado actual y referencia histórica: un
CHANGELOG que menciona la landing como novedad es correcto; un roadmap que la
lista como pendiente es un error.

**Esfuerzo.** 5 minutos.

---

## R-04 · El nivel 8 tiene dos nombres · **Media**

**Impacto.** Quien lea `docs/CURRICULUM.md` y luego abra la aplicación verá un
título distinto en el mismo nivel.

**Evidencia.**

| Fuente | Nombre |
|---|---|
| `assets/content/curriculum.json`, `levels[7].title` | `Cuecas de Chile y presentación` |
| `README.md:126`, diagrama de la ruta | `8 · Diversidad y presentación` |
| `docs/CURRICULUM.md:20`, tabla de ocho semanas | `Diversidad y presentación` |

El dato es la fuente de verdad: es lo que se dibuja en pantalla.

**Ubicación.** `assets/content/curriculum.json` · `README.md:126` · `docs/CURRICULUM.md:20`

**Recomendación.** Elegir uno y unificar. Ningún validador comprueba que los
títulos de los niveles coincidan entre el dato y la documentación; podría
añadirse a `validate_repository.mjs` con el mismo criterio con el que ya
comprueba los nombres de artefacto del README.

**Esfuerzo.** 10 minutos la corrección; 30 minutos añadir la comprobación.

---

## R-05 · Credenciales literales en el workflow de release · **Media**

**Impacto.** `.github/workflows/release.yml` contiene, en la rama que se ejecuta
cuando los secrets de firma no están configurados, un alias y dos contraseñas
escritas literalmente. Sirven para crear un almacén de claves con `keytool` que
vive solo en el runner y se descarta al terminar.

**No es la filtración de un secreto real**: la clave no existía antes y no
persiste después. Sí es material con forma de credencial en un repositorio
público, que puede disparar escáneres de secretos, y sobre todo **señala el
estado que hay que resolver**: mientras esa rama se ejecute, cada release
produce un APK firmado con una clave distinta e irrepetible.

**Probabilidad.** Certeza mientras los secrets no estén configurados.
[`../VALIDATION_RESULT.md`](../VALIDATION_RESULT.md) confirma midiendo el APK
publicado que se usó la rama efímera.

**Evidencia.** Barrido sobre el árbol versionado, con los valores enmascarados:

```text
.github/workflows/release.yml:111:  KEY_PASSWORD=   <VALOR OMITIDO>   ← desde secret
.github/workflows/release.yml:112:  STORE_PASSWORD= <VALOR OMITIDO>   ← desde secret
.github/workflows/release.yml:116:  KEY_PASSWORD=   <VALOR OMITIDO>   ← literal
.github/workflows/release.yml:117:  STORE_PASSWORD= <VALOR OMITIDO>   ← literal
```

Ningún otro archivo del repositorio contiene material con forma de credencial.
Un barrido de patrones de token (`sk-`, `ghp_`, `AKIA`, claves privadas PEM) no
devolvió coincidencias.

**Ubicación.** `.github/workflows/release.yml:114-123`

**Recomendación.** Configurar los cuatro secrets, que es lo que el
[`../../ROADMAP.md`](../../ROADMAP.md) ya marca como prioridad inmediata. Al
hacerlo, la rama de respaldo deja de ejecutarse y los literales dejan de tener
función; podrían sustituirse por un valor generado al vuelo.

**Esfuerzo.** 1 hora, más la custodia segura del almacén de claves.

---

## R-06 · Cifras del currículo escritas a mano en la interfaz · **Media**

**Impacto.** Si el currículo cambia de tamaño, dos textos de la interfaz mienten
sin que ninguna compuerta lo detecte. Uno de ellos aparece en un diálogo de
confirmación de borrado, que es el peor sitio para una cifra incorrecta.

**Evidencia.**

```dart
// lib/screens/home_tab.dart
title: 'Explorar las 24 clases',

// lib/screens/progress_tab.dart
content: const Text('Se desmarcarán las 24 clases en este dispositivo.'),
```

`AppState.totalCount` existe y devuelve el valor real. En `home_tab.dart` el
`AppState` ya está disponible como campo; en `progress_tab.dart` también.

**Ubicación.** `lib/screens/home_tab.dart:105` · `lib/screens/progress_tab.dart:150`

**Recomendación.** Interpolar `state.totalCount`. La cifra dejaría de poder
desincronizarse.

**Esfuerzo.** 15 minutos. `Nota:` deja de ser texto constante, así que hay que
retirar el `const` de esos widgets.

---

## R-07 · «Clases de 10 a 15 minutos» cuando todas duran 12 · **Baja**

**Impacto.** Varios documentos describen una variedad de duración que los datos
no tienen. No engaña a nadie de forma grave, pero es el tipo de afirmación que
envejece mal.

**Evidencia.**

```bash
$ node -e "const c=require('./assets/content/curriculum.json');
  const d=new Set(c.levels.flatMap(l=>l.lessons).map(s=>s.durationMinutes));
  console.log([...d])"
[ 12 ]
```

Las 24 clases duran exactamente 12 minutos; 288 minutos en total.

| Documento | Dice |
|---|---|
| `README.md:88` | «cada clase dura de 10 a 15 minutos» |
| `docs/PRACTICE_PLAN_8_WEEKS.md:5` | «Tres clases de 10 a 15 minutos por semana» |
| `docs/releases/v0.1.0.md` | «Clases de 10–15 minutos» |
| `docs/CURRICULUM.md` | «24 clases de 12 minutos» — **correcto** |

`test/curriculum_integrity_test.dart` valida el rango 10–15, que es el contrato
real; el rango no es incorrecto, solo está infrautilizado.

**Ubicación.** `README.md:88` · `docs/PRACTICE_PLAN_8_WEEKS.md:5` · `docs/releases/v0.1.0.md`

**Recomendación.** Decir «12 minutos» donde se describe el producto actual y
reservar el rango 10–15 para el contrato que el validador impone.
`docs/CURRICULUM.md` ya lo hace bien. Las notas de una versión publicada son
referencia histórica y no deberían editarse.

**Esfuerzo.** 10 minutos.

---

## R-08 · Validador de currículo duplicado · **Baja**

**Impacto.** Dos implementaciones de las mismas reglas, en Node y en Dart, que
pueden divergir. La de Dart **no la ejecuta ningún workflow ni bootstrap**: solo
la mencionan `CONTRIBUTING.md` y el `MASTER_PROMPT.md` no versionado. Un cambio
de regla aplicado solo a la de Node pasaría inadvertido.

**Evidencia.** `tool/validate_curriculum.dart` (106 líneas) y
`tool/validate_curriculum.mjs` (62 líneas) comprueban lo mismo y producen la
misma línea de salida. `grep -rn "validate_curriculum.dart"` solo encuentra
`CONTRIBUTING.md`.

**Ubicación.** `tool/validate_curriculum.dart` · `tool/validate_curriculum.mjs`

**Recomendación.** Decidir. Si se conserva la de Dart —tiene sentido para quien
ya tiene el toolchain y no quiere Node—, añadirla a `ci.yml`, que ya tiene
Flutter instalado y le costaría segundos. Si no, retirarla y actualizar
`CONTRIBUTING.md`.

**Esfuerzo.** 20 minutos.

---

## R-09 · El control de cadenas prohibidas no cubre todo `lib/` · **Baja**

**Impacto.** `validate_repository.mjs` busca las cadenas prohibidas en una lista
fija de siete archivos. `lib/` tiene quince. Un archivo nuevo queda fuera del
primer control.

El impacto real es bajo: los controles del manifiesto fuente y del manifiesto
fusionado sí son exhaustivos y son los que bloquean la release. Pero el primer
control da una sensación de cobertura que no tiene.

**Ubicación.** `tool/validate_repository.mjs:143-158`

**Recomendación.** Recorrer `lib/` completo con un `readdir` recursivo.

**Esfuerzo.** 20 minutos. Atención: la lista actual incluye `dart:io` entre las
cadenas prohibidas y `test/curriculum_integrity_test.dart` lo importa
legítimamente, así que la ampliación debe seguir limitándose a `lib/`.

---

## R-10 · La versión de Flutter está en dos archivos · **Baja**

**Impacto.** `FLUTTER_VERSION: "3.44.6"` aparece en `ci.yml:14` y en
`release.yml:23`. Actualizar uno sin el otro deja la verificación continua y la
publicación compilando con versiones distintas, y el formateador de Dart cambia
entre versiones.

**Ubicación.** `.github/workflows/ci.yml:14` · `.github/workflows/release.yml:23`

**Recomendación.** El repositorio ya resolvió este patrón para la versión del
producto con `tool/app_version.mjs`. Aquí no hay un mecanismo equivalente
sencillo en GitHub Actions sin variables de organización; la alternativa barata
es una comprobación en `validate_repository.mjs` que exija que ambos valores
coincidan.

**Esfuerzo.** 30 minutos.

---

## R-11 · El laboratorio de ritmo no tiene ninguna prueba · **Media**

**Impacto.** Es el componente con más lógica temporal del proyecto —la corrección
de deriva sobre `Stopwatch`, la agrupación de acentos, la emisión condicional de
sonido y háptica— y la única forma de comprobar que funciona es abrir la
aplicación y escuchar. Una regresión en la planificación no se detectaría en CI.

Es también la razón directa de que R-01 pasara inadvertido.

**Evidencia.** `grep -rn "RhythmLab\|_scheduleNextPulse\|SystemSound" test/`
solo encuentra la comprobación del texto de privacidad en el smoke test.

**Ubicación.** `test/` · `lib/screens/rhythm_lab_screen.dart`

**Recomendación.** Una prueba de widget con reloj simulado que verifique que el
pulso *n* cae en `n × 60/bpm` incluso tras introducir un retraso artificial, y
otra que compruebe que la háptica solo se emite en los acentos. Es el hueco con
mejor relación entre esfuerzo y valor de todo el repositorio.

**Esfuerzo.** 3–4 horas.

---

## R-12 · `docs/CONTENT_PRODUCTION.md` sin protección · **Baja**

**Impacto.** Es el único de los 18 documentos de `docs/` que no figura en la
lista de archivos esenciales de `validate_repository.mjs`. Borrarlo no rompería
ninguna compuerta, aunque el README lo enlaza —y ese enlace quedaría roto sin
que nadie lo detecte, porque el validador solo comprueba las **imágenes** que el
README referencia, no sus enlaces—.

**Ubicación.** `tool/validate_repository.mjs:21-37`

**Recomendación.** Añadirlo a `requiredFiles`. Considerar además comprobar los
enlaces relativos del README con el mismo criterio con el que ya se comprueban
sus imágenes.

**Esfuerzo.** 5 minutos añadirlo; 45 minutos la comprobación de enlaces.

---

## R-13 · La velocidad inicial no cae en una división del deslizador · **Baja**

**Impacto.** El `Slider` va de 60 a 120 con 12 divisiones, es decir pasos de 5:
60, 65, 70… El valor inicial es 84, que no es ninguno de ellos. Al primer
arrastre, la velocidad salta a 85 sin que la persona haya pedido ese cambio.

**Evidencia.** `lib/screens/rhythm_lab_screen.dart`: `double _bpm = 84;` con
`min: 60, max: 120, divisions: 12`.

**Ubicación.** `lib/screens/rhythm_lab_screen.dart:35, 154-159`

**Recomendación.** Usar 85, o cambiar `divisions` a 60 para pasos de 1 punto.
`NO DOCUMENTADO EN EL REPOSITORIO`: por qué se eligió 84 como velocidad inicial;
`INFERENCIA`: parece un tempo escogido por criterio musical, en cuyo caso la
solución correcta es ajustar las divisiones y no el valor.

**Esfuerzo.** 5 minutos, más una decisión musical.

---

## R-14 · Una captura versionada sin uso · **Baja**

**Impacto.** `docs/screenshots/09-escritorio.png` (68 KB) se muestra en el README
y `tool/build_site.mjs` la copia a la landing, pero `site/index.html` no la
referencia: la galería muestra las ocho primeras. Es peso muerto en el artefacto
publicado.

**Evidencia.**

```bash
$ grep -c "09-escritorio" site/index.html
0
```

**Ubicación.** `site/index.html` · `tool/build_site.mjs:57-65`

**Recomendación.** Añadirla a la galería —es la única que muestra la barra
lateral de escritorio, que es una característica del producto— o excluirla de la
copia.

**Esfuerzo.** 10 minutos.

---

## R-15 · Los colores del esquema de piso no se miden · **Baja**

**Impacto.** `test/theme_contrast_test.dart` mide 16 pares de color, todos del
`ColorScheme`. `_MovementPainter` pinta su propio fondo y sus propias figuras
con `AppColors.red` y `AppColors.blue` **fijos en ambos modos**. Ese par no lo
mide nadie.

No es un fallo demostrado —el fondo del lienzo también cambia con el modo—, sino
un hueco de cobertura en la única suite que protege la legibilidad.

**Ubicación.** `lib/widgets/movement_diagram.dart:154-155` · `test/theme_contrast_test.dart`

**Recomendación.** Extender la suite a los colores del lienzo, reutilizando la
función `contrastRatio` que ya existe en el archivo de pruebas.

**Esfuerzo.** 1 hora.

---

## R-16 · Sin esquema JSON formal ni migración del currículo · **Media**

**Impacto.** La clave del almacén de progreso lleva sufijo `_v1`, lo que reserva
la posibilidad de migrar, pero **el mecanismo de migración no existe**. El
currículo tampoco tiene esquema formal: la disciplina la ponen dos validadores y
tres pruebas, todos con reglas escritas a mano.

Consecuencia concreta: cambiar el formato del avance sin escribir la migración
dejaría huérfano el progreso de todos los dispositivos instalados.

**Ubicación.** `lib/data/progress_repository.dart:20` · `assets/content/curriculum.json`

**Recomendación.** Es un hueco que el propio repositorio ya reconoce:
`docs/ARCHITECTURE.md` dice que «una versión futura debería añadir un esquema
JSON formal y migraciones entre versiones», y el
[`../../ROADMAP.md`](../../ROADMAP.md) lo pone en la versión 0.2 junto con la
exportación de progreso. Se registra aquí para que no se pierda.

**Esfuerzo.** 1–2 días.

---

## R-17 · Sin escaneo de dependencias ni de secretos en CI · **Baja**

**Impacto.** 52 paquetes resueltos y ninguna comprobación automática de
vulnerabilidades conocidas. Ninguna comprobación impide confirmar un secreto
nuevo. La superficie es pequeña y `pubspec.lock` está versionado —lo que hace las
versiones auditables, a diferencia de un repositorio sin lock—, pero nadie las
audita.

**Ubicación.** `.github/workflows/ci.yml`

**Recomendación.** Un job de auditoría de dependencias y un escáner de secretos
son baratos y encajan en `ci.yml`. Ver [11 · Seguridad](11-security.md), H-3 y
H-4, para las observaciones relacionadas sobre acciones fijadas por etiqueta
móvil.

**Esfuerzo.** 2 horas.

---

## Lo que está bien y hay que proteger

Un informe que solo enumera problemas da una imagen falsa. Estas propiedades son
buenas, alguien podría romperlas sin darse cuenta, y merecen defensa explícita.

| Propiedad | Dónde | Por qué importa |
|---|---|---|
| **Persistencia transaccional** | `AppState` + `ProgressRepository` + 3 pruebas | Impide el fallo más caro del producto: avance que se ve y desaparece. Las pruebas existen para que nadie invierta el orden |
| **La interfaz `ProgressStore`** | `lib/data/progress_repository.dart` | Sin ella, las tres pruebas anteriores serían imposibles de escribir |
| **Dominio sin dependencias** | `lib/domain/curriculum.dart` | Permite validar el currículo sin Flutter. Un `import` de Flutter aquí rompería tres pruebas y un validador |
| **Corrección de deriva del pulso** | `_scheduleNextPulse` | Volver a `Timer.periodic` reintroduce un error que solo se nota tras varios minutos, que es cuando importa |
| **Versión con una sola fuente** | `tool/app_version.mjs` | El CHANGELOG documenta el fallo que evita: un tag `v0.2.0` publicando archivos `0.1.0` |
| **Verificar el binario, no solo el repositorio** | `tool/verify_apk.mjs` | Detecta un artefacto que compila, se firma, cuadra en checksum y se instala vacío |
| **Coherencia documental automatizada** | `tool/validate_repository.mjs` | Impide que el README prometa lo que el manifiesto no declara. Mejor relación líneas/errores evitados del repositorio |
| **Contraste medido sobre el par real** | `test/theme_contrast_test.dart` | Mide lo que se dibuja, no lo que la teoría sugiere. Es la razón de que exista `AppColors.redDeep` |
| **Defensa en profundidad sobre permisos** | Tres controles en tres momentos | Solo el tercero ve el manifiesto fusionado. Retirar cualquiera deja un hueco distinto |
| **Una sola dependencia de ejecución** | `pubspec.yaml` | Cada plugin nuevo es una vía por la que un permiso entra sin aparecer en el código |
| **`.gitattributes` con LF forzado** | `.gitattributes` | Los hashes de `verify_apk.mjs` dependen de ello |
| **Honestidad documental** | README, `VALIDATION_RESULT.md`, `TEACHER_REVIEW.md` | Declaran la clave efímera, la falta de firma Authenticode y la validación humana pendiente en vez de esconderlas |

## Continuar por

- [17 · Resumen ejecutivo](17-executive-summary.md) para el orden de atención.
- [14 · Troubleshooting](14-troubleshooting.md) para los síntomas asociados.

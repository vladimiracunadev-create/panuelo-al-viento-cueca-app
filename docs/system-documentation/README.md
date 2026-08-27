# Documentación de sistema · Pañuelo al Viento

Portada e índice de la documentación técnica completa del repositorio
`panuelo-al-viento-cueca-app`.

## Qué es este sistema

**Pañuelo al Viento** es una aplicación educativa Flutter, local-first, que
propone a niñas y niños de aproximadamente 10 años una ruta introductoria de 24
clases para acercarse a la cueca. Se distribuye como APK de Android y como
ejecutable, MSI y ZIP portable de Windows. No tiene servidor, cuentas,
publicidad ni analítica, y el APK publicado no declara ningún permiso del
sistema.

## Propósito de esta documentación

El repositorio ya tenía 18 documentos temáticos de producto, pedagogía,
privacidad y operación. Esta carpeta **no los sustituye ni los repite**: añade
la capa que faltaba —mapa del código, referencia símbolo a símbolo, explicación
del flujo interno, trazabilidad y registro de hallazgos— y enlaza a los
existentes cuando ya cubren un tema mejor de lo que lo haría una copia.

Cuando un tema ya está resuelto en `docs/`, aquí encontrarás el enlace y el
contexto técnico que lo conecta con el código, no una segunda versión del texto.

## Público

| Perfil | Por dónde empezar |
|---|---|
| Persona desarrolladora que llega hoy | [18 · Guía de incorporación](18-new-developer-guide.md) |
| Quien necesita decidir sin detalle técnico | [17 · Resumen ejecutivo](17-executive-summary.md) |
| Quien va a modificar el código | [04 · Mapa del código](04-code-map.md) y [06 · Explicación profunda](06-deep-code-explanation.md) |
| Quien audita privacidad o seguridad | [11 · Seguridad](11-security.md) y [15 · Riesgos](15-risks-and-technical-debt.md) |
| Quien opera la publicación | [13 · Despliegue y operación](13-deployment-and-operations.md) |
| Quien no es técnico | [01 · Visión general](01-system-overview.md), sección final |

## Índice

| # | Documento | Contenido | Estado |
|---|---|---|---|
| — | [README](README.md) | Portada, índice, convenciones y pendientes. | Completo |
| 01 | [Visión general](01-system-overview.md) | Qué hace el sistema, para quién y qué no hace. Incluye explicación para persona no técnica. | Completo |
| 02 | [Instalación y ejecución](02-installation-and-execution.md) | Requisitos, arranque desde cero y las carpetas que no existen hasta que alguien las genera. | Completo |
| 03 | [Arquitectura](03-architecture.md) | Capas, decisiones y diagramas. | Completo |
| 04 | [Mapa del código](04-code-map.md) | Inventario jerárquico con responsabilidad, dependencias y estado aparente. | Completo |
| 05 | [Referencia técnica](05-technical-reference.md) | Catálogo de consulta: firma, efectos, llamantes y riesgo al modificar. | Completo |
| 06 | [Explicación profunda](06-deep-code-explanation.md) | Flujo interno, módulo a módulo. | Completo |
| 07 | [Persistencia](07-database.md) | No hay base de datos: mecanismo real de persistencia, diccionario y ciclo de vida. | Completo |
| 08 | [Flujo de datos](08-data-flow.md) | Recorrido del dato desde el JSON hasta la pantalla y de vuelta al disco. | Completo |
| 09 | [APIs e integraciones](09-apis-and-integrations.md) | Demostración de que no hay red y contratos que sí existen. | Completo |
| 10 | [Configuración](10-configuration.md) | Manifiestos, variables de entorno, secrets y valores fijados. | Completo |
| 11 | [Seguridad](11-security.md) | Controles presentes y ausentes, superficie y hallazgos. | Completo |
| 12 | [Pruebas y calidad](12-testing-and-quality.md) | Las 25 pruebas, los validadores y lo que ninguno cubre. | Completo |
| 13 | [Despliegue y operación](13-deployment-and-operations.md) | CI, release, landing y generación de estos PDF. | Completo |
| 14 | [Troubleshooting](14-troubleshooting.md) | Síntoma, causa, diagnóstico, solución y riesgo de aplicarla. | Completo |
| 15 | [Riesgos y deuda técnica](15-risks-and-technical-debt.md) | Hallazgos registrados, **ninguno corregido**. | Completo |
| 16 | [Glosario](16-glossary.md) | Términos técnicos, culturales y los que significan algo propio aquí. | Completo |
| 17 | [Resumen ejecutivo](17-executive-summary.md) | Para decisión, con esfuerzo cuantificado. | Completo |
| 18 | [Guía de incorporación](18-new-developer-guide.md) | Itinerario de los primeros días. | Completo |
| 19 | [Matriz de trazabilidad](19-traceability-matrix.md) | Funcionalidad → módulo → función → dato → prueba, en una fila. | Completo |

Versiones PDF de todos ellos, más un consolidado, en [`pdf/`](pdf/).

## Documentación previa del repositorio

Estos documentos ya existían y **siguen siendo la fuente autorizada** de su
tema. Esta carpeta los referencia; no los duplica.

| Documento existente | Tema del que es fuente autorizada |
|---|---|
| [`../../README.md`](../../README.md) | Presentación pública, estado verificable y descargas. |
| [`../ARCHITECTURE.md`](../ARCHITECTURE.md) | Decisión arquitectónica y evolución futura sin romper privacidad. |
| [`../CURRICULUM.md`](../CURRICULUM.md) | Programa pedagógico, mapa de ocho semanas y evaluación formativa. |
| [`../PEDAGOGY_AND_SAFETY.md`](../PEDAGOGY_AND_SAFETY.md) | Enfoque, consentimiento corporal y reglas de seguridad. |
| [`../ACCESSIBILITY.md`](../ACCESSIBILITY.md) | Soporte de accesibilidad, equivalencias y límites conocidos. |
| [`../PRIVACY.md`](../PRIVACY.md) | Inventario de datos infantiles y condiciones de ampliación. |
| [`../PERMISSIONS.md`](../PERMISSIONS.md) | Matriz exacta de permisos y activaciones del dispositivo. |
| [`../BUILD_MOBILE.md`](../BUILD_MOBILE.md) · [`../BUILD_WINDOWS.md`](../BUILD_WINDOWS.md) | Procedimiento de compilación por plataforma. |
| [`../VALIDATION.md`](../VALIDATION.md) · [`../VALIDATION_RESULT.md`](../VALIDATION_RESULT.md) | Cómo validar y qué se midió en 0.1.0. |
| [`../RELEASE_CHECKLIST.md`](../RELEASE_CHECKLIST.md) | Criterios de publicación. |
| [`../TEACHER_REVIEW.md`](../TEACHER_REVIEW.md) | Protocolo de revisión docente y cultural. |
| [`../SOURCES.md`](../SOURCES.md) · [`../CONTENT_LICENSES.md`](../CONTENT_LICENSES.md) · [`../CONTENT_PRODUCTION.md`](../CONTENT_PRODUCTION.md) | Procedencia cultural y licencias de contenido. |
| [`../PARENT_GUIDE.md`](../PARENT_GUIDE.md) · [`../TEACHER_GUIDE.md`](../TEACHER_GUIDE.md) · [`../PRACTICE_PLAN_8_WEEKS.md`](../PRACTICE_PLAN_8_WEEKS.md) | Uso en familia y en aula. |
| [`../../SECURITY.md`](../../SECURITY.md) · [`../../CONTRIBUTING.md`](../../CONTRIBUTING.md) · [`../../ROADMAP.md`](../../ROADMAP.md) · [`../../CHANGELOG.md`](../../CHANGELOG.md) | Reporte de seguridad, contribución, plan e historial. |

## Datos del análisis

| Aspecto | Valor |
|---|---|
| Repositorio | `panuelo-al-viento-cueca-app` |
| Rama analizada | `main` |
| Commit analizado | `6efae74` · «Publica la landing en GitHub Pages» · 2026-08-25 |
| Versión del producto | `0.1.0+1`, leída de `pubspec.yaml` |
| Versión del currículo | `1.0.0`, campo `version` de `assets/content/curriculum.json` |
| Fecha del análisis | 2026-08-27 |
| Toolchain usada para verificar | Flutter 3.44.6 · Dart 3.12.2 · Node v24.11.1 |
| Estado del árbol al empezar | Limpio |

La versión del producto y la del currículo son números distintos y no se mueven
juntos. Confundirlos al leer el JSON es un error fácil de cometer.

## Convenciones

Contenido y secciones en español. Los identificadores de código, claves de
configuración y nombres de archivo se citan **en su forma original**, sin
traducir, para que buscar el texto de un documento dentro del repositorio
funcione.

Cada afirmación sin marcador está anclada a un archivo, un símbolo o un comando
ejecutado. Lo demás lleva marcador:

| Marcador | Significado |
|---|---|
| *(sin marcador)* | Hecho verificado, con archivo y símbolo citados. |
| `INFERENCIA` | Conclusión razonada, no afirmación literal del repositorio. |
| `REQUIERE VALIDACIÓN` | Depende de ejecución real, de un servicio externo o de una decisión humana. |
| `NO DOCUMENTADO EN EL REPOSITORIO` | Existe en el código pero nadie lo explica. |
| `NO IDENTIFICADO` | Se buscó y no hay evidencia en ningún sentido. |

## Qué no se pudo verificar, y por qué

Una documentación que oculta sus límites es peor que una incompleta que los
declara. Esto es lo que quedó fuera de comprobación directa:

| Aspecto | Motivo |
|---|---|
| Compilación de Android y de Windows | Este análisis se hizo en Windows sin Android SDK ni Visual Studio con carga de C++. `flutter analyze` y `flutter test` sí se ejecutaron. |
| Contenido del APK publicado | `tool/verify_apk.mjs` necesita `aapt2` de las build-tools de Android, ausentes en la máquina de análisis. Los valores que cita [`../VALIDATION_RESULT.md`](../VALIDATION_RESULT.md) se reproducen como afirmación del repositorio, no como medición propia. |
| Comportamiento en dispositivo real | No se instaló en un teléfono ni se ejecutó el escritorio. Vibración, clic del sistema y persistencia entre reinicios quedan `REQUIERE VALIDACIÓN`. |
| Ejecución de los workflows | No se dispararon. Su contenido se leyó línea a línea; su resultado no se observó. |
| Validez pedagógica y cultural | Fuera del alcance de una documentación técnica y expresamente pendiente según [`../TEACHER_REVIEW.md`](../TEACHER_REVIEW.md). |
| Accesibilidad con tecnologías de apoyo | No se probó TalkBack ni el Narrador de Windows. Lo que existe son etiquetas semánticas en el código, que no equivalen a una auditoría. |

## Pendientes de validar

Recogidos aquí para que no haya que buscarlos por los veinte documentos. El
detalle está en [15 · Riesgos](15-risks-and-technical-debt.md).

1. Que el pulso del laboratorio siga sonando al cambiar de pestaña es
   comportamiento **verificado en pruebas**, pero falta decidir si es un fallo o
   una función; [`../PERMISSIONS.md`](../PERMISSIONS.md) afirma lo contrario.
2. Si los siete valores de `diagram` del currículo deben tener siete dibujos
   distintos, o si `pair` y `free` comparten esquema a propósito.
3. Si `tool/validate_curriculum.dart` debe seguir existiendo junto a su gemelo
   en Node.
4. Los datos del APK publicado, hasta que alguien con las build-tools ejecute
   `node tool/verify_apk.mjs`.
5. Todo el bloque de validación humana que ya declara
   [`../VALIDATION_RESULT.md`](../VALIDATION_RESULT.md).

## Regenerar los PDF

```bash
python tool/build_docs_pdf.py            # los veinte documentos y el consolidado
python tool/build_docs_pdf.py --only 03-architecture.md
```

El generador está descrito en [13 · Despliegue y operación](13-deployment-and-operations.md).

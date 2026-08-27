# 17 · Resumen ejecutivo

Para decisión. Sin detalle técnico innecesario y con el esfuerzo de cada
recomendación cuantificado.

---

## En tres frases

**Pañuelo al Viento** es una aplicación educativa que enseña cueca a niñas y
niños de unos diez años mediante 24 clases de 12 minutos, funciona sin conexión y
no recoge ningún dato personal. Técnicamente está **verificada**: las pruebas
pasan, la coherencia entre documentación y código se comprueba sola, y el
artefacto publicado se abrió y se midió en vez de darlo por bueno. Pedagógica y
culturalmente **no está validada**, y el propio proyecto lo declara sin
maquillarlo.

## Estado del producto

| Dimensión | Estado | Comentario |
|---|---|---|
| Funciona e instala | **Sí** | Android 7+ y Windows 10/11 en cuatro formatos |
| Calidad técnica verificada | **Sí** | 25 pruebas, análisis estático limpio, 3 validadores propios |
| Privacidad infantil | **Sí, y comprobada tres veces** | El APK publicado no declara ningún permiso del sistema |
| Distribución automatizada | **Sí** | Tag → cuatro artefactos con hashes, con compuertas en cada paso |
| Validación pedagógica | **No** | Falta revisión por docente de Educación Física |
| Validación cultural | **No** | Faltan al menos dos personas cultoras de contextos distintos |
| Prueba con niñas y niños | **No** | Pendiente, con autorización adulta |
| Auditoría de accesibilidad | **No** | Hay etiquetas semánticas; falta probar con TalkBack y Narrador |
| Actualizable sin perder datos | **No** | Clave de firma efímera. La primera actualización obligará a desinstalar |

## Lo que hace bien, y que no es habitual

Cuatro propiedades que distinguen este proyecto de una aplicación educativa
corriente y que conviene no perder:

1. **Verifica el artefacto, no solo el repositorio.** Antes de publicar, abre el
   APK compilado, cuenta las clases que trae dentro y compara su huella con la
   del repositorio. Un programa puede compilar, firmarse, cuadrar en checksum e
   instalarse **vacío**; un build en verde no lo detecta.

2. **La documentación no puede mentir sin que salte una alarma.** Un validador
   comprueba que la versión del manifiesto, el historial, las notas de la
   versión, los nombres de los archivos del README y la página web digan todos lo
   mismo, y que las capturas que el README muestra existan de verdad.

3. **La privacidad se comprueba en tres momentos independientes**: en el código,
   en el archivo de configuración generado y en el paquete ya compilado. Solo el
   tercero puede ver los permisos que una dependencia añadiría sin aparecer en el
   código, y por eso existe.

4. **Declara lo que no sabe.** Que la firma es temporal, que los instaladores de
   Windows no tienen certificado comercial, que ningún docente ha revisado el
   contenido. Eso es una propiedad de calidad, no una debilidad: quien instala
   sabe qué está aceptando.

## Lo que hay que decidir

Diecisiete hallazgos registrados en [15 · Riesgos](15-risks-and-technical-debt.md),
ninguno corregido. Estos son los que requieren una decisión, no solo trabajo:

### 1 · La firma permanente de Android · **prioridad máxima**

Mientras no se configure, **cada versión nueva obliga a desinstalar la anterior y
borra el avance de quien la usaba**. Y como no hay exportación ni copia en la
nube, ese avance se pierde para siempre; la guía para familias llega a
recomendar anotar las clases en papel.

El problema crece con el tiempo: cuantas más personas instalen 0.1.0, más
usuarios afectará la primera actualización.

- **Esfuerzo:** 1 hora de configuración, más la custodia segura del archivo de
  claves.
- **Decisión requerida:** quién custodia esa clave y dónde. Perderla impide
  actualizar para siempre.

### 2 · El pulso que sigue sonando al cambiar de pantalla

La documentación de permisos afirma que cambiar de pantalla detiene el
metrónomo. **No lo hace**: verificado en pruebas durante este análisis. El clic
sigue emitiéndose mientras se navega por el resto de la aplicación.

Es el hallazgo de mayor severidad porque toca el documento sobre el que descansa
la confianza de una familia.

- **Esfuerzo:** 1–2 horas si se cambia el código, 15 minutos si se corrige el
  documento.
- **Decisión requerida:** ¿es un fallo o una función? Permitir que el pulso siga
  sonando mientras se lee una clase podría ser útil. Lo que no puede seguir es
  que el código y el documento se contradigan.

### 3 · La validación humana pendiente

Es lo que separa «una aplicación bien construida» de «un método pedagógico».
Ninguna cantidad de pruebas automáticas la sustituye, y el proyecto ya tiene
escrito el protocolo en [`../TEACHER_REVIEW.md`](../TEACHER_REVIEW.md).

- **Esfuerzo:** semanas de calendario, no de programación. Requiere convocar a
  personas: una docente de Educación Física, dos personas cultoras de contextos
  distintos, y un grupo de 5–8 niñas y niños con autorización.
- **Decisión requerida:** presupuesto, o red de contactos, y quién coordina.

### 4 · Los siete esquemas de piso que son cinco

Siete clases de las 24 muestran un dibujo genérico porque su tipo de recorrido no
tiene ilustración propia. Además, quien usa un lector de pantalla recibe dos
descripciones distintas del mismo dibujo.

- **Esfuerzo:** 2–3 horas de programación.
- **Decisión requerida:** qué debe dibujar cada uno. Es una decisión pedagógica,
  no técnica.

## Trabajo sin decisión: se puede hacer ya

| Tarea | Esfuerzo | Valor |
|---|---|---|
| Corregir el roadmap, que da por pendiente la página web ya publicada | 5 min | Evita planificar sobre información falsa |
| Unificar el nombre del nivel 8, distinto en el dato y en dos documentos | 10 min | Coherencia |
| Sustituir «24 clases» escrito a mano por el valor real, en dos pantallas | 15 min | Evita que la interfaz mienta si el currículo cambia |
| Decir «12 minutos» donde hoy se dice «10 a 15» | 10 min | Precisión |
| Añadir el documento desprotegido a la lista de archivos esenciales | 5 min | Cierra un hueco del validador |
| Añadir la novena captura a la página web, o dejar de copiarla | 10 min | Peso muerto en el artefacto publicado |
| Pruebas del laboratorio de ritmo | 3–4 h | **El hueco de cobertura con mejor relación esfuerzo/valor** |
| Auditoría de dependencias en la verificación continua | 2 h | 52 paquetes hoy sin vigilancia |

Las seis primeras suman menos de una hora y eliminan seis de los diecisiete
hallazgos.

## Costes y dependencias

| Concepto | Situación |
|---|---|
| Infraestructura | **Cero.** No hay servidor, base de datos ni servicio de pago. Todo funciona en el dispositivo |
| Dependencias de terceros | **Una** de ejecución, 52 paquetes resueltos en total. Superficie muy pequeña |
| Servicios usados | GitHub Actions, Releases y Pages. Todos en el plan gratuito para repositorios públicos |
| Licencia | MIT. Sin música, video ni tipografías externas que licenciar |
| Mantenimiento recurrente | Actualizar la versión fijada de Flutter y regenerar las capturas cuando cambie la interfaz |

El coste de operación es efectivamente cero. El coste real del proyecto es el
**tiempo de las personas que deben revisar el contenido**.

## Riesgo de continuidad

| Riesgo | Nivel | Mitigación existente |
|---|---|---|
| Pérdida de la clave de firma | **Alto** | Ninguna: la clave todavía no existe. Al crearla hay que custodiarla |
| Dependencia de una sola persona mantenedora | Medio | El bootstrap regenera todo desde cero y la documentación es extensa |
| Obsolescencia del toolchain | Bajo | Las plataformas se regeneran con la versión instalada de Flutter, no con plantillas guardadas. Fue una decisión deliberada |
| Dependencias vulnerables | Bajo | Superficie mínima y versiones fijadas, pero sin vigilancia automática |
| Contenido cultural cuestionado | Medio | El proyecto ya declara que es una base introductoria y no una coreografía única |

## Recomendación

**Publicar 0.1.0 fue razonable.** El producto es instalable, seguro y honesto
sobre sus límites.

Antes de 0.2.0, por orden:

1. Configurar la firma permanente de Android. Sin eso, cada persona que instale
   hoy perderá su avance mañana.
2. Resolver la contradicción del metrónomo: código o documento, pero no ambos.
3. Aplicar las seis correcciones documentales de menos de una hora.
4. Añadir pruebas al laboratorio de ritmo.
5. Convocar la revisión humana. Es lo más lento y lo que más cambia el valor del
   producto.

Lo que **no** conviene hacer antes de esa revisión: producir video, música o
animaciones. El propio [`../../ROADMAP.md`](../../ROADMAP.md) lo dice, y
[`../PEDAGOGY_AND_SAFETY.md`](../PEDAGOGY_AND_SAFETY.md) es explícito: «ajuste
del currículo antes de producir videos costosos». Grabar contenido sobre una
secuencia que después hay que cambiar es la forma más cara de equivocarse en este
proyecto.

## Continuar por

- [15 · Riesgos](15-risks-and-technical-debt.md) para el detalle de los
  diecisiete hallazgos.
- [01 · Visión general](01-system-overview.md) para entender el producto.
- [`../../ROADMAP.md`](../../ROADMAP.md) para el plan del propio proyecto.

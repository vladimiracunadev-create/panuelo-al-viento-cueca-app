# 16 · Glosario

Definiciones pensadas para que alguien sin formación técnica pueda leer el resto
de la documentación. Los términos marcados con **★** significan algo **específico
en este sistema** y no lo que significarían en otro proyecto.

---

## Términos del producto

**Actividad** ★
Una de las tres tareas cronometradas que componen una clase. Duran 3, 4 o 5
minutos y sus tiempos suman exactamente la duración de la clase. En el código es
`LearningActivity`.

**Avance** ★
La lista de clases que alguien ha marcado como completadas. Es lo **único** que
la aplicación guarda. No incluye puntuaciones, tiempos ni nada que identifique a
una persona.

**Clase** ★
Una lección de 12 minutos. Contiene objetivo, motivo, esquema de piso, tres
actividades, reto, advertencia de seguridad, alternativa accesible y consejo para
la persona adulta. En el código es `Lesson`. Hay 24.

**Equivalencia funcional** ★
Otra forma de hacer un movimiento que conserva la intención pedagógica aunque no
reproduzca la forma. Marcar el pulso con la voz en lugar de con los pies, por
ejemplo. Cada clase incluye una. Ver [`../ACCESSIBILITY.md`](../ACCESSIBILITY.md).

**Esquema de piso** (o diagrama de movimiento) ★
El dibujo que muestra el recorrido que hacen los pies durante una clase. Se
dibuja con código, no es una imagen guardada. Lleva siempre una descripción en
texto para quien no puede verlo.

**Laboratorio de ritmo** ★
La pantalla con seis círculos que se encienden por turno, como un péndulo. Sirve
para aprender a sentir el compás. Puede acompañarse de un clic y de una
vibración, ambos opcionales.

**Nivel** ★
Un grupo de tres clases con un mismo foco temático. Hay 8, y cada uno tiene un
emoji y un título.

**Pulso**
Cada uno de los golpes regulares que marcan el tiempo de la música. El
laboratorio muestra seis y los agrupa de dos maneras distintas.

**Acento** ★
Un pulso que se marca más fuerte que los demás. En la agrupación 3+3 son el 1 y
el 4; en la 2+2+2 son el 1, el 3 y el 5. La vibración solo se emite en los
acentos, para que se note la agrupación y no sea un zumbido continuo.

**Ruta de aprendizaje** ★
El recorrido completo de las 24 clases. Ninguna está bloqueada: se puede abrir
cualquiera en cualquier orden. La aplicación sugiere la siguiente pendiente, pero
no obliga.

---

## Términos técnicos

**Activo** (*asset*)
Un archivo que viaja **dentro** del programa instalado, no descargado. Aquí las
24 clases son un activo: por eso la aplicación funciona sin conexión.

**APK**
El archivo de instalación de una aplicación de Android, equivalente a un `.exe`
de Windows.

**Artefacto**
Cada uno de los archivos que se publican en una versión: el APK, los dos
instaladores de Windows, el ZIP portable y el archivo de comprobación.

**Bootstrap** ★
El script que prepara el proyecto desde cero. Aquí hace falta de verdad, porque
las carpetas de Android y de Windows no están guardadas en el repositorio: se
regeneran cada vez.

**Build** (compilación)
Convertir el código escrito por personas en un programa que la máquina ejecuta.
«Un build en verde» significa que la compilación terminó sin errores, lo que
**no** garantiza que el resultado sea correcto.

**CI** (integración continua)
El sistema que revisa automáticamente cada cambio: formato, análisis y pruebas.
Aquí es GitHub Actions y tarda unos minutos.

**Commit**
Un cambio guardado en la historia del proyecto, con su autor, su fecha y su
explicación. Se identifica con un código corto como `6efae74`.

**Compuerta** (*gate*) ★
Una comprobación automática que **detiene** el proceso si falla, en vez de
limitarse a avisar. Este proyecto tiene seis, y esa severidad es deliberada.

**Currículo** ★
Aquí, el archivo `curriculum.json` con las 24 clases. Ojo: **no** es el
currículum académico oficial de un país, aunque el proyecto se apoye en objetivos
del currículum nacional chileno.

**Deriva** (del metrónomo) ★
El retraso que se acumula cuando cada golpe se cuenta desde el anterior en lugar
de desde el inicio. Sin corregirla, un metrónomo se va quedando atrás minuto a
minuto. Este proyecto la corrige, y es una de sus decisiones técnicas más
cuidadas.

**Esquema** (*schema*)
La descripción formal de la forma que debe tener un archivo de datos: qué campos
lleva, de qué tipo y cuáles son obligatorios. Este proyecto **no tiene uno
formal**; en su lugar usa validadores con las reglas escritas a mano.

**Firma** (de una aplicación)
Un sello criptográfico que identifica quién construyó el programa. Android solo
instala una versión nueva sobre la anterior si ambas tienen el mismo sello.

**Firma efímera** ★
Un sello creado en el momento de compilar y descartado después. Sirve para
instalar, pero **no para actualizar**: la siguiente versión tendrá otro sello y
Android exigirá desinstalar. Es la situación de la versión 0.1.0.

**Hash** (SHA-256)
Una huella digital de un archivo. Si cambia un solo byte, la huella cambia por
completo. Sirve para comprobar que lo descargado es exactamente lo publicado.

**Landing**
La página web pública del proyecto, con capturas y enlaces de descarga. Se
publica en GitHub Pages.

**Local-first** ★
Un diseño en el que todo funciona en el dispositivo, sin servidor. Aquí es
absoluto: no hay ningún caso en que la aplicación necesite conexión.

**Manifiesto**
El archivo que describe una aplicación: su nombre, su versión y los permisos que
pide. Aquí hay dos que importan: `pubspec.yaml`, del proyecto, y el manifiesto
Android que se genera al compilar.

**Manifiesto fusionado** ★
El manifiesto **final** de un APK, después de mezclar el del proyecto con los que
aportan sus dependencias. Importa porque un permiso puede aparecer ahí sin haber
sido escrito por nadie del proyecto. Es lo único que ve `verify_apk.mjs`, y por
eso ese control existe.

**Permiso** (del sistema)
Una autorización que el sistema operativo pide antes de dejar que una aplicación
use algo sensible: la cámara, el micrófono, la ubicación. Esta aplicación **no
pide ninguno**.

**Capacidad** (del dispositivo) ★
Algo que el dispositivo puede hacer y que **no** requiere permiso, como emitir un
sonido o vibrar. El proyecto distingue con cuidado permiso de capacidad: sonido y
vibración son capacidades, no sensores. No escuchan nada.

**Persistencia**
Guardar información para que sobreviva al cierre del programa.

**Persistencia transaccional** ★
La regla más protegida de este proyecto: el programa solo muestra un cambio
**después** de que el disco confirme que lo guardó. Si el guardado falla, la
pantalla no miente.

**Portable** (versión)
Una carpeta que se descomprime y se ejecuta sin instalar. Hay que extraerla
**completa**: el ejecutable solo no funciona.

**Release**
Una versión publicada, con sus artefactos y sus notas.

**Repositorio**
El lugar donde vive todo el código y su historia.

**Semántica** (etiqueta) ★
Una descripción en texto que se adjunta a un elemento visual para que un lector
de pantalla pueda anunciarlo. Los esquemas de piso llevan una.

**Smoke test**
Una prueba rápida que comprueba que lo esencial funciona: que la aplicación abre
y que se puede navegar. No comprueba detalles.

**Validador** ★
Un programa pequeño que revisa que algo cumpla sus reglas. Este proyecto tiene
dos para el contenido y uno para el repositorio, y los tres funcionan **sin
instalar Flutter**, lo que permite comprobarlo casi desde cualquier máquina.

**Verificador del artefacto** ★
`verify_apk.mjs`: abre el archivo de instalación ya construido y cuenta lo que
lleva dentro. Existe porque un programa puede compilarse, firmarse y publicarse
correctamente y aun así instalarse **sin contenido**.

**Workflow**
Una receta automatizada que GitHub ejecuta al ocurrir algo: un cambio, una
etiqueta de versión. Este proyecto tiene tres.

---

## Términos de las herramientas

**Dart**
El lenguaje de programación en que está escrita la aplicación.

**Flutter**
La tecnología que permite escribir la aplicación una sola vez y que funcione en
Android y en Windows.

**Mermaid**
Una forma de escribir diagramas como texto. GitHub los dibuja solo; para el PDF
hay que convertirlos a imagen antes.

**Node.js**
El programa que ejecuta las herramientas de verificación del repositorio.
Deliberadamente, esas herramientas no necesitan Flutter.

**SharedPreferences**
El almacén sencillo que ofrece cada sistema operativo para guardar ajustes
pequeños. Aquí guarda la lista de clases completadas.

**WCAG**
Las pautas internacionales de accesibilidad. La regla que este proyecto mide es
que el texto contraste al menos 4,5 a 1 con su fondo.

---

## Términos culturales

**Cueca**
Baile tradicional chileno, declarado baile nacional en 1979. **No tiene una sola
forma correcta**: cambia entre territorios y comunidades, y este proyecto insiste
en no presentar una variante como la única válida.

**Escobillado**
Paso de cueca en el que los pies rozan el suelo suavemente. Aparece en la clase
11.

**Medialuna**
Recorrido en forma de arco que hacen las dos personas que bailan, una frente a
otra.

**Pañuelo**
El pañuelo que se lleva en la mano y se mueve mientras se baila. Da nombre a la
aplicación.

**Persona cultora**
Alguien que conoce y transmite una tradición desde dentro de su comunidad. El
proyecto declara que necesita la revisión de al menos dos, de contextos
distintos, antes de considerar validado su contenido cultural.

**Remate**
El cierre de una secuencia de baile.

**Zapateo**
Golpear el suelo con los pies siguiendo el ritmo. El currículo lo plantea
expresamente **sin impacto fuerte**, por seguridad.

**3+3 y 2+2+2** ★
Las dos maneras de agrupar seis pulsos que el laboratorio contrasta. En la cueca
pueden sentirse a la vez; separarlas es una simplificación para entrenar la
escucha, y la propia aplicación lo advierte.

---

Para el detalle pedagógico y cultural, [`../CURRICULUM.md`](../CURRICULUM.md),
[`../PEDAGOGY_AND_SAFETY.md`](../PEDAGOGY_AND_SAFETY.md) y
[`../SOURCES.md`](../SOURCES.md) siguen siendo la fuente autorizada.

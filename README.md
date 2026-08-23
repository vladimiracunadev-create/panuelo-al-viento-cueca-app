<div align="center">

# 🧣 Pañuelo al Viento

## **24 clases · 8 niveles · pulso, movimiento y cultura de la cueca**

**Aplicación educativa, privada y sin publicidad para acercarse a la cueca desde los 10 años. Una sola base Flutter para Android y Windows, preparada para aprender sin cuenta y sin conexión.**

[![CI](https://github.com/vladimiracunadev-create/panuelo-al-viento-cueca-app/actions/workflows/ci.yml/badge.svg)](https://github.com/vladimiracunadev-create/panuelo-al-viento-cueca-app/actions/workflows/ci.yml)
[![Release Android y Windows](https://github.com/vladimiracunadev-create/panuelo-al-viento-cueca-app/actions/workflows/release.yml/badge.svg)](https://github.com/vladimiracunadev-create/panuelo-al-viento-cueca-app/actions/workflows/release.yml)

[![Versión](https://img.shields.io/badge/versión-0.1.0-2b6f9f?style=for-the-badge)](CHANGELOG.md)
[![Clases](https://img.shields.io/badge/clases-24%20·%208%20niveles-d84a4a?style=for-the-badge)](docs/CURRICULUM.md)
[![Actividades](https://img.shields.io/badge/actividades-72-f2b544?style=for-the-badge)](docs/VALIDATION_RESULT.md)
[![Privacidad](https://img.shields.io/badge/cámara%20y%20micrófono-no%20usados-32856d?style=for-the-badge)](docs/PERMISSIONS.md)
[![Licencia](https://img.shields.io/badge/licencia-MIT-173b63?style=for-the-badge)](LICENSE)

[⬇️ Descargar](https://github.com/vladimiracunadev-create/panuelo-al-viento-cueca-app/releases/latest) ·
[👨‍👩‍👧 Guía para familias](docs/PARENT_GUIDE.md) ·
[🎓 Currículo](docs/CURRICULUM.md) ·
[🏗️ Arquitectura](docs/ARCHITECTURE.md) ·
[🔒 Privacidad](docs/PRIVACY.md) ·
[🗺️ Roadmap](ROADMAP.md)

![Android](https://img.shields.io/badge/Android%207+-3DDC84?logo=android&logoColor=white)
![Windows](https://img.shields.io/badge/Windows%2010%2F11-0078D6?logo=windows&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Offline](https://img.shields.io/badge/funciona-sin%20conexión-32856d)

</div>

---

> [!IMPORTANT]
> La aplicación **complementa, pero no reemplaza**, la guía de docentes y personas cultoras. La cueca es una tradición viva con expresiones territoriales diversas; esta versión enseña una ruta introductoria adaptable y no declara una coreografía única.

## ✅ Estado verificable

| Superficie | Evidencia en `0.1.0` |
|---|---|
| 🎓 **Currículo** | **24 clases**, 8 niveles y 72 actividades; numeración, duración, campos y unicidad validados automáticamente. |
| 🥁 **Pulso** | Ciclo visual de seis pulsos, agrupaciones **3+3** y **2+2+2**, 60–120 PPM y planificación corregida contra deriva acumulada. |
| 🗺️ **Movimiento** | Diagramas accesibles para vuelta, ocho, medialuna, pasos, diálogo y pañuelo; equivalencia funcional en cada clase. |
| 💾 **Progreso** | Guardado local transaccional, próxima clase, porcentaje total y por nivel, repetición y borrado confirmado. |
| 🧪 **Calidad** | Validador independiente con Node, pruebas de modelos, currículo, persistencia, transacciones y navegación; análisis Flutter en CI. |
| 📦 **Distribución** | APK Android; Windows en `.exe`, `.msi` y `.zip` portable; hashes SHA-256 en cada release. |
| 🔒 **Privacidad** | Sin servidor, cuentas, publicidad ni analítica. **No solicita cámara ni micrófono**; el workflow rechaza esos permisos si aparecen. |

## ✨ Características funcionales

- **Ruta de ocho semanas:** contexto cultural, pulso, espacio, pañuelo, recorridos, pasos, diálogo, zapateo de bajo impacto, creación y presentación.
- **24 clases breves:** cada clase dura de 10 a 15 minutos y conserva la secuencia mostrar o descubrir → practicar → interpretar o reflexionar.
- **72 actividades originales:** tres por clase, con tiempo visible, casillas de avance y cierre celebratorio privado.
- **Diagramas de piso:** seis patrones dibujados en Flutter y descritos semánticamente para tecnologías de apoyo.
- **Laboratorio de ritmo:** compara dos agrupaciones de seis pulsos, permite regular velocidad y combinar señal visual, clic del sistema y respuesta háptica.
- **Progreso local:** recuerda solo identificadores de clases completadas; calcula avance total, avance por nivel y la próxima clase.
- **Repetición libre:** completar otra vez una clase conserva el avance anterior y no crea puntuaciones, castigos ni rankings.
- **Seguridad integrada:** cada clase incluye espacio, calzado, intensidad, pausa, alternativa accesible y consejo para la persona adulta.
- **Diseño adaptable:** navegación inferior en celular y barra lateral en escritorio; modo claro u oscuro según el sistema y soporte de texto ampliado.
- **Recuperación comprensible:** si el currículo o el almacenamiento no pueden abrirse, la app muestra una pantalla de ayuda en vez de quedar vacía.
- **Local-first:** todo el currículo viaja dentro de la instalación y funciona sin iniciar sesión ni conectarse a internet.

## 🎤 Cámara, micrófono, sonido y vibración

Esta versión diferencia con precisión un **permiso del sistema** de una **capacidad del dispositivo**:

| Capacidad | Estado | Cuándo se activa | Qué dato conserva |
|---|---|---|---|
| 📷 Cámara | **No utilizada** | Nunca; no existe botón, API ni permiso de manifiesto. | Ninguno. |
| 🎤 Micrófono | **No utilizado** | Nunca; no existe botón, API ni permiso de manifiesto. | Ninguno. |
| 🔊 Clic del sistema | Opcional | Solo al pulsar **Comenzar** en Ritmo y mantener encendido **Sonido**. | Ninguno. |
| 📳 Respuesta háptica | Opcional | Solo en pulsos acentuados, después de **Comenzar**, con **Vibración** encendida y si el equipo la admite. | Ninguno. |
| 💾 Almacenamiento local | Necesario para recordar avance | Al completar o reiniciar clases. No pide acceso general a archivos. | Identificadores de clases completadas. |

Ni sonido ni vibración escuchan al entorno. Desactivar ambos deja un metrónomo completamente visual. En Windows la respuesta háptica normalmente no está disponible y la aplicación continúa sin error.

La ausencia de cámara y micrófono se comprueba en el código y, para Android, también después de generar la plataforma. Consulta [Permisos y activaciones](docs/PERMISSIONS.md) y [Privacidad infantil](docs/PRIVACY.md).

## 🗺️ Ruta de aprendizaje

```mermaid
flowchart LR
    N1["🌎 1 · Descubro"] --> N2["🧣 2 · Pañuelo"]
    N2 --> N3["🧭 3 · Recorridos"]
    N3 --> N4["👣 4 · Pasos"]
    N4 --> N5["🤝 5 · Diálogo"]
    N5 --> N6["⚡ 6 · Zapateo y remate"]
    N6 --> N7["🎶 7 · Música y creación"]
    N7 --> N8["🇨🇱 8 · Diversidad y presentación"]
```

La marca de una clase registra participación, no perfección corporal. Las adaptaciones sentadas, de recorrido reducido, con manos, voz, señas o ruedas pueden cumplir la misma intención pedagógica.

## ⬇️ Descargar e instalar

Los archivos oficiales se publican en [GitHub Releases](https://github.com/vladimiracunadev-create/panuelo-al-viento-cueca-app/releases). Cada versión incluye `SHA256SUMS.txt` para comprobar integridad.

| Plataforma | Archivo | Uso |
|---|---|---|
| Android 7 o superior | `PanueloAlViento-0.1.0-Android.apk` | Instalación directa fuera de Google Play. |
| Windows 10/11 | `PanueloAlViento-0.1.0-Windows-Setup.exe` | Instalador asistido con accesos directos opcionales. |
| Windows 10/11 | `PanueloAlViento-0.1.0-Windows.msi` | Instalador MSI para despliegue y administración. |
| Windows 10/11 | `PanueloAlViento-0.1.0-Windows-portable.zip` | Uso directo: descomprimir la carpeta completa y abrir `panuelo_al_viento.exe`. |

> [!WARNING]
> El APK `0.1.0` se firma en la automatización inicial. Antes de publicar una actualización debe configurarse una clave permanente; de lo contrario Android exigirá desinstalar la versión anterior y se perderá el progreso local. El procedimiento está en [Compilar Android](docs/BUILD_MOBILE.md).

### Android

1. Descarga el APK desde la release oficial.
2. Abre el archivo en el dispositivo.
3. Si Android lo solicita, autoriza a tu navegador o gestor de archivos a instalar aplicaciones desconocidas.
4. Revisa el resumen del sistema: Pañuelo al Viento no debe pedir cámara ni micrófono.
5. Instala y abre la aplicación.

### Windows

- Para una instalación normal, abre el `.exe` o `.msi`.
- Para uso directo, descomprime **todo** el ZIP; no extraigas solo el ejecutable porque necesita las DLL y la carpeta `data` que lo acompañan.
- Windows puede mostrar SmartScreen porque la versión comunitaria no tiene certificado comercial de firma de código. Verifica el origen de la descarga y el hash publicado antes de continuar.

## 🚀 Desarrollo

Requisitos:

- Flutter estable 3.29 o superior con Dart 3.7 o superior.
- Android Studio/JDK 17 para Android.
- Visual Studio 2022 con **Desktop development with C++** para Windows.

```powershell
.\tool\bootstrap.ps1
flutter run -d windows
```

En Linux o macOS, para Android:

```bash
./tool/bootstrap.sh
flutter devices
flutter run -d <id-del-dispositivo>
```

Los scripts generan las plantillas nativas oficiales para la versión estable de Flutter y aplican el nombre público, Android 7+ y la auditoría de permisos.

## 🧪 Verificar

Sin instalar Flutter se pueden comprobar repositorio y currículo:

```bash
node tool/validate_repository.mjs
node tool/validate_curriculum.mjs
```

Con Flutter:

```bash
flutter pub get
dart format --output=none lib test tool
flutter analyze
flutter test
```

El workflow de release repite estas verificaciones, compila ambas plataformas, comprueba la firma del APK, audita permisos, abre brevemente la aplicación Windows y publica los cuatro artefactos con hashes.

## 🏗️ Arquitectura

```text
assets/content/curriculum.json
             │
             ▼
CurriculumRepository ──► AppState ──► Inicio / Ruta / Clase / Avance
                             ▲
                             │
SharedPreferences ◄── ProgressRepository

Timer corregido por Stopwatch ──► Laboratorio de ritmo
```

La interfaz, el currículo y el estado son compartidos. Las carpetas `android/` y `windows/` se generan de forma reproducible al preparar o compilar; `tool/configure_platforms.mjs` aplica identidad y controles de permisos. Más detalle en [Arquitectura](docs/ARCHITECTURE.md).

## 📚 Documentación

| Documento | Contenido |
|---|---|
| [Currículo](docs/CURRICULUM.md) | Mapa de 24 clases, evaluación formativa y uso escolar. |
| [Plan de ocho semanas](docs/PRACTICE_PLAN_8_WEEKS.md) | Frecuencia, sesiones y evidencias observables. |
| [Guía para familias](docs/PARENT_GUIDE.md) | Instalación, acompañamiento, seguridad y progreso. |
| [Pedagogía y seguridad](docs/PEDAGOGY_AND_SAFETY.md) | Enfoque, consentimiento corporal y equivalencias. |
| [Accesibilidad](docs/ACCESSIBILITY.md) | Soporte actual, pruebas y límites conocidos. |
| [Permisos](docs/PERMISSIONS.md) | Activación exacta de cámara, micrófono, sonido, vibración y guardado. |
| [Privacidad](docs/PRIVACY.md) | Inventario de datos y condiciones para futuras ampliaciones. |
| [Compilar Android](docs/BUILD_MOBILE.md) | APK, firma, instalación y auditoría. |
| [Compilar Windows](docs/BUILD_WINDOWS.md) | EXE, MSI, portable y verificación. |
| [Arquitectura](docs/ARCHITECTURE.md) | Capas, persistencia y decisiones técnicas. |
| [Licencias de contenido](docs/CONTENT_LICENSES.md) | Procedencia de textos, marca y futuros medios. |
| [Validación](docs/VALIDATION_RESULT.md) | Resultado automatizado y revisiones humanas pendientes. |
| [Revisión docente](docs/TEACHER_REVIEW.md) | Protocolo para no confundir software verificado con pedagogía validada. |
| [Checklist de release](docs/RELEASE_CHECKLIST.md) | Criterios técnicos, infantiles y de distribución. |

## 🌱 Alcance responsable de `0.1.0`

La versión inicial enseña con texto breve, diagramas, retos y pulso. No incluye grabaciones musicales, video, reconocimiento de voz ni evaluación corporal. Esta decisión evita usar medios sin derechos claros y evita pedir permisos sensibles antes de demostrar que son necesarios.

Antes de usarla como curso escolar final se necesita revisión documentada por una persona docente de Educación Física y por personas cultoras de las variantes representadas. Las tareas pendientes están separadas de las comprobaciones automáticas en [Resultado de validación](docs/VALIDATION_RESULT.md).

## 📖 Fuentes culturales y curriculares

- [La cueca — Memoria Chilena, Biblioteca Nacional](https://www.memoriachilena.gob.cl/602/w3-article-3510.html)
- [La cueca, el baile nacional — Chile para Niños](https://www.chileparaninos.gob.cl/639/w3-article-348586.html)
- [EF05 OA 05 — Currículum Nacional](https://www.curriculumnacional.cl/614/w3-article-17931.html)
- [EF06 OA 05 — Currículum Nacional](https://www.curriculumnacional.cl/614/w3-article-17950.html)

Consulta [Fuentes y trazabilidad cultural](docs/SOURCES.md) para el criterio de uso y las revisiones pendientes.

## 🤝 Contribuir y licencia

Las contribuciones deben conservar lenguaje comprensible, diversidad territorial, alternativas accesibles, seguridad corporal y cero rastreo infantil. Lee [CONTRIBUTING.md](CONTRIBUTING.md) y [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

Código, textos originales y marca SVG bajo licencia MIT. Cualquier música, fotografía, video, interpretación o tipografía futura deberá declarar su licencia individual. Véanse [LICENSE](LICENSE) y [Licencias de contenido](docs/CONTENT_LICENSES.md).

# Historial de cambios

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

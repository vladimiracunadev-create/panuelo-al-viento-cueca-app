# Resultado de validación 0.1.0

Fecha técnica: 2026-08-23

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
| Repositorio | Versionado y documentación esencial comprobados por Node. |
| Cámara/micrófono | Ausentes del producto; manifiesto Android auditado durante release. |
| Compilación | Ejecutada en CI para APK y Windows al crear la release. |
| Artefactos | El workflow exige APK, Setup EXE, MSI, ZIP y SHA-256 antes de publicar. |

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
dart format --output=none lib test tool
flutter analyze
flutter test
```

La evidencia definitiva de compilación queda en la ejecución del workflow asociada al tag `v0.1.0`.

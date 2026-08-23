# Privacidad infantil

## Resumen comprensible

Pañuelo al Viento no necesita saber quién eres. No pide cuenta, nombre, edad, correo, escuela ni ubicación. **No usa cámara ni micrófono.** Solo recuerda en el dispositivo qué clases marcaste como completadas.

## Inventario de 0.1.0

| Dato, sensor o servicio | Estado | Finalidad y conservación |
|---|---|---|
| Identificadores de clases completadas | Guardado local | Mostrar avance; permanece hasta reiniciar datos o desinstalar. |
| Nombre, apodo o edad | No solicitado | No es necesario. |
| Cuenta, correo o identidad adulta | No existe | No hay autenticación ni servidor. |
| Cámara, fotos o video | No utilizado | Sin permiso, captura ni archivo. |
| Micrófono, voz o audio ambiental | No utilizado | Sin permiso, captura ni archivo. |
| Ubicación o contactos | No solicitado | No es necesario. |
| Sonido del sistema | Salida opcional | Clic rítmico después de una acción; no conserva datos. |
| Respuesta háptica | Salida opcional | Acento rítmico después de una acción; no conserva datos. |
| Internet | No usado por el producto | Currículo y progreso funcionan sin conexión. |
| Analítica, publicidad o rastreo | No incluidos | No se crean perfiles de comportamiento. |
| Chat o publicación pública | No incluidos | No hay exposición ni moderación de menores. |

## Qué se guarda

`shared_preferences` conserva una lista ordenada bajo la clave versionada `completed_lessons_v1`. Los valores son identificadores como `lesson-01`; no contienen respuestas, puntuaciones, tiempo de práctica, identidad, voz ni imagen.

El estado se actualiza de forma transaccional: si el almacenamiento informa un fallo, la interfaz no presenta la clase como guardada.

## Control familiar

La pantalla **Mi avance → Reiniciar el avance** pide confirmación y borra la lista local. Eliminar los datos de la aplicación o desinstalar también puede borrarla. No hay copia en la nube ni recuperación remota en 0.1.0.

## Cámara y micrófono

No basta con que una función esté “apagada”: en esta versión las APIs y permisos no forman parte del producto. El manifiesto Android se audita durante la release y el proceso falla si encuentra `CAMERA` o `RECORD_AUDIO`.

Sonido y vibración son salidas, no sensores. Su activación exacta se documenta en [PERMISSIONS.md](PERMISSIONS.md).

## Requisitos de cualquier ampliación

Antes de una función nueva se debe responder y documentar:

1. ¿Puede funcionar sin identificar al niño?
2. ¿Puede evitar el permiso sensible?
3. ¿Puede procesarse completamente en el dispositivo?
4. ¿Cuál es el tiempo mínimo de conservación?
5. ¿Quién accede, con qué finalidad y cómo se audita?
6. ¿Cómo retira el consentimiento una persona adulta?
7. ¿Qué alternativa equivalente funciona si se deniega?
8. ¿Qué riesgos de sesgo, seguridad y tienda infantil introduce?

La negativa a un permiso futuro no podrá bloquear la ruta principal.

## Distribución pública

Antes de una tienda, este documento debe convertirse en una política pública con identidad y contacto del responsable, matriz de dependencias y declaraciones de seguridad de datos de cada tienda. También se requiere revisión jurídica aplicable a los territorios de distribución.

## Reportes

No publiques datos reales de niñas o niños en issues. Los problemas de privacidad o permisos se informan mediante el canal privado definido en `SECURITY.md`.

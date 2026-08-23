# Seguridad

## Reportar en privado

No publiques una vulnerabilidad que pueda afectar a niñas, niños, permisos o dispositivos. Usa el reporte privado de seguridad de GitHub si está habilitado o contacta de forma privada al mantenedor del repositorio.

Incluye versión, plataforma, pasos mínimos, impacto, evidencia sin datos personales y posible mitigación. No adjuntes capturas con rostros, nombres, escuelas, direcciones ni historial real de menores.

## Superficie de 0.1.0

- no hay backend, cuenta ni autenticación;
- no hay red de producto, analítica ni publicidad;
- cámara, micrófono, ubicación y contactos no se declaran;
- el currículo es un activo de solo lectura incluido en la app;
- el avance es una lista local de identificadores;
- sonido y vibración son salidas activadas por el usuario;
- los principales riesgos son manipulación de artefactos, dependencias, persistencia local y cambios futuros de permisos.

## Controles incluidos

- validación estructural del currículo;
- persistencia transaccional;
- rechazo de clases inexistentes;
- confirmación antes de borrar progreso;
- auditoría de permisos Android en configuración y release;
- APK firmado y verificado;
- SHA-256 para cada artefacto;
- GitHub Actions con permisos mínimos por workflow.

## Firma y distribución

Una clave Android efímera permite instalar, pero no actualizar. Es una limitación operativa, no una garantía de identidad duradera. Configura y protege un keystore permanente antes de la siguiente versión.

Los binarios Windows comunitarios no tienen firma Authenticode. Verifica repositorio, release y SHA-256. No desactives defensas del sistema de forma permanente.

## Cambios sensibles

Cualquier cámara, micrófono, sincronización, importación de archivos, actualización automática o contenido comunitario exige modelo de amenaza, alternativa sin permiso, pruebas negativas y actualización simultánea de `PRIVACY.md`, `PERMISSIONS.md` y la checklist de release.

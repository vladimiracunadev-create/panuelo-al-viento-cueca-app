# Permisos y activaciones del dispositivo

## Resumen

La versión 0.1.0 no necesita permisos sensibles. **Cámara y micrófono no se solicitan, no se activan y no tienen código de captura.** La aplicación funciona completa sin internet.

## Matriz exacta

| Recurso | Declaración Android | Activación en la app | Procesamiento | Persistencia |
|---|---|---|---|---|
| Cámara | No existe `android.permission.CAMERA`. | Nunca. | Ninguno. | Ninguna imagen o video. |
| Micrófono | No existe `android.permission.RECORD_AUDIO`. | Nunca. | Ninguno. | Ningún audio. |
| Ubicación | No declarada. | Nunca. | Ninguno. | Ninguna coordenada. |
| Internet | No existe `android.permission.INTERNET` en el APK publicado. | No hay llamadas de red de producto. | Todo el curso es local. | Sin caché de red. |
| Sonido | No requiere permiso. | Al tocar **Comenzar** en Ritmo, si **Sonido** está encendido. | Solicita un clic breve al sistema. | Nada. |
| Vibración/háptica | No pide diálogo al usuario. | Solo en acentos del ritmo, después de **Comenzar**, con **Vibración** encendida. | `HapticFeedback.mediumImpact`; puede ser ignorado por el equipo. | Nada. |
| Preferencias locales | No pide acceso general a archivos. | Al completar o reiniciar clases. | Lista ordenada de identificadores. | `completed_lessons_v1`. |

## Secuencia de activación del laboratorio

1. Abrir **Ritmo** no reproduce ni activa nada.
2. Elegir 3+3, 2+2+2 o cambiar velocidad solo modifica estado en memoria.
3. **Comenzar** inicia el pulso visual.
4. Si **Sonido** está encendido, cada pulso solicita un clic del sistema.
5. Si **Vibración** está encendida, solo los acentos solicitan una respuesta háptica.
6. **Detener**, cambiar de pantalla o cerrar la app cancela el temporizador.
7. En ningún paso se consulta cámara ni micrófono.

El clic y la vibración no son sensores: no leen el entorno ni identifican a la persona.

## Controles automáticos

La ausencia de sensores se comprueba en tres momentos distintos, porque cada uno puede fallar sin que el anterior se entere:

1. **En el código.** `tool/validate_repository.mjs` busca dependencias o activaciones no autorizadas (`permission_handler`, `camera:`, `microphone:`, `dart:io`).
2. **En el manifiesto generado.** `tool/configure_platforms.mjs` revisa el `AndroidManifest.xml` que produce `flutter create`, y el workflow de release vuelve a buscar `CAMERA` y `RECORD_AUDIO` en `android/app/src`.
3. **En el APK ya compilado.** `tool/verify_apk.mjs` lee el manifiesto binario del paquete con `aapt2`. Este es el único control que ve el manifiesto **fusionado**, es decir, los permisos que podría añadir una dependencia sin que aparezcan en el código del proyecto.

El tercer control rechaza la release si el paquete declara cámara, micrófono, internet, ubicación, lectura de almacenamiento externo o contactos:

```bash
node tool/verify_apk.mjs PanueloAlViento-0.1.0-Android.apk 0.1.0
```

Sobre el APK publicado de `0.1.0` el resultado fue **sin permisos del sistema declarados**: la única entrada `uses-permission` del paquete es `cl.panueloalviento.panuelo_al_viento.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`, un permiso propio que AndroidX genera para registrar receptores internos y que no da acceso a ningún recurso del dispositivo.

La pantalla **Mi avance** muestra el estado de cámara y micrófono de forma comprensible para una familia.

## Si Android muestra un permiso inesperado

No continúes la instalación. Comprueba que el APK provenga de la release oficial, verifica su SHA-256 y abre un reporte. La ficha de una futura tienda también deberá declarar que la app no recopila audio, fotos ni video.

## Condiciones para incorporar cámara en el futuro

Una función de postura no entra automáticamente en el producto. Requeriría, antes de programarse:

- necesidad pedagógica demostrada frente a alternativas sin cámara;
- consentimiento adulto y activación separada;
- procesamiento completamente en el dispositivo;
- ausencia de grabación y descarte inmediato de cuadros;
- funcionamiento completo con el permiso denegado;
- evaluación de sesgos corporales, vestuario, tono de piel, movilidad y contexto;
- señal visible mientras el sensor esté activo;
- revisión jurídica y de tiendas para público infantil.

El roadmap no autoriza por sí solo ese permiso.

## Condiciones para incorporar micrófono en el futuro

Reconocer pulso o ambiente necesitaría una especificación equivalente: botón explícito, indicador visible, análisis en memoria, cero grabación, cero transmisión, apagado inmediato y alternativa manual. Hasta que exista y sea revisada, el permiso debe seguir ausente.

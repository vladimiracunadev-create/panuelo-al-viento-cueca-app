# Compilar e instalar Android

## Resultado oficial

El workflow de release genera un APK universal llamado `PanueloAlViento-0.1.0-Android.apk`. La versión mínima configurada es Android 7 (API 24).

## Requisitos locales

- Flutter estable 3.29 o superior;
- JDK 17;
- Android SDK y herramientas de compilación;
- dispositivo físico con depuración USB o emulador.

## Preparar el proyecto

Desde Linux o macOS:

```bash
./tool/bootstrap.sh
```

Desde Windows:

```powershell
.\tool\bootstrap.ps1
```

Los scripts ejecutan `flutter create`, aplican nombre, API mínima y auditoría de cámara/micrófono, descargan dependencias y corren calidad.

## Desarrollo y release local

```bash
flutter devices
flutter run -d <id>
flutter build apk --release
```

El APK local queda en `build/app/outputs/flutter-apk/app-release.apk`. Una build local de release necesita una configuración de firma; el workflow la prepara automáticamente.

## Firma de actualizaciones

Android solo instala una versión nueva sobre la anterior si ambas usan la misma clave. El workflow acepta estos secrets:

| Secret | Contenido |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Archivo JKS codificado en base64. |
| `ANDROID_KEY_ALIAS` | Alias de la clave. |
| `ANDROID_KEY_PASSWORD` | Contraseña de la clave. |
| `ANDROID_STORE_PASSWORD` | Contraseña del almacén. |

Si el primer secret no existe, CI genera una clave efímera y publica una advertencia. El APK funciona, pero una actualización compilada con otra clave obligará a desinstalar y borrará el progreso. Esto coincide con la limitación inicial de los repositorios de violín y guitarra y debe resolverse antes de `0.2.0`.

Para crear una clave permanente fuera del repositorio:

```bash
keytool -genkeypair -v -keystore panuelo-release.jks -alias panuelo \
  -keyalg RSA -keysize 2048 -validity 10000
```

Guárdala en un gestor seguro y conserva una copia de recuperación. No confirmes `.jks`, `key.properties` ni contraseñas; `.gitignore` los excluye. La pérdida de la clave impide actualizar instalaciones existentes.

## Verificación del APK

```bash
apksigner verify --verbose PanueloAlViento-0.1.0-Android.apk
apkanalyzer manifest permissions PanueloAlViento-0.1.0-Android.apk
```

El segundo comando no debe listar `android.permission.CAMERA` ni `android.permission.RECORD_AUDIO`.

## Prueba manual mínima

1. Instalar en Android 7 y en una versión reciente.
2. Abrir sin conexión.
3. Recorrer Inicio, Ruta, una clase, Ritmo y Avance.
4. Completar una clase, cerrar forzadamente y comprobar persistencia.
5. Probar sonido encendido/apagado y vibración encendida/apagada.
6. Confirmar que Android nunca muestra diálogos de cámara o micrófono.
7. Reiniciar el avance y comprobar la confirmación.
8. Desinstalar al finalizar si el dispositivo no es de prueba.

## Instalación familiar

Android llama “aplicación desconocida” a un APK instalado fuera de una tienda. La autorización corresponde al navegador o gestor de archivos que abre el APK, no a cámara, micrófono ni datos personales. Después de instalar puede revocarse esa autorización.

# Compilar e instalar Android

## Resultado oficial

El workflow de release genera un APK universal llamado `PanueloAlViento-<versión>-Android.apk`, con la versión tomada de `pubspec.yaml`. La versión mínima configurada es Android 7 (API 24) y el paquete es `cl.panueloalviento.panuelo_al_viento`.

El nombre del archivo no es la única garantía: antes de publicar, la release comprueba que el tag sea `v` + la versión del manifiesto y que el APK compilado declare esa misma versión por dentro.

## Requisitos locales

- Flutter estable 3.44.6 (la versión fijada en CI; funciona desde 3.29);
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

La comprobación completa, con una sola orden:

```bash
node tool/verify_apk.mjs PanueloAlViento-0.1.0-Android.apk 0.1.0
```

Comprueba el paquete, `versionName`, `versionCode`, `minSdkVersion`, los permisos del manifiesto **fusionado**, las arquitecturas nativas y que el currículo empaquetado tenga 8 niveles y 24 clases y coincida byte por byte con `assets/content/curriculum.json`. Ese último control es el que detecta el fallo silencioso: un APK que compila, se firma y cuadra en checksum pero se instala sin contenido.

Sin segundo argumento toma la versión esperada de `pubspec.yaml`. Necesita las build-tools de Android en `ANDROID_SDK_ROOT`, o la ruta a `aapt2` en la variable `AAPT2`.

Por separado, con las herramientas del SDK:

```bash
apksigner verify --verbose PanueloAlViento-0.1.0-Android.apk
aapt2 dump badging PanueloAlViento-0.1.0-Android.apk | grep uses-permission
```

El segundo comando no debe listar `android.permission.CAMERA`, `android.permission.RECORD_AUDIO` ni `android.permission.INTERNET`. La única entrada esperada es `cl.panueloalviento.panuelo_al_viento.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`, generada por AndroidX, que no da acceso a ningún recurso.

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

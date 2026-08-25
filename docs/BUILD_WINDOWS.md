# Compilar y distribuir Windows

## Artefactos de la release

| Archivo | Propósito |
|---|---|
| `PanueloAlViento-0.1.0-Windows-Setup.exe` | Instalador asistido creado con Inno Setup. |
| `PanueloAlViento-0.1.0-Windows.msi` | Paquete MSI creado con WiX para administración. |
| `PanueloAlViento-0.1.0-Windows-portable.zip` | Carpeta autocontenida para descomprimir y ejecutar directamente. |

El ZIP es la modalidad “directa”. El archivo `panuelo_al_viento.exe` no debe separarse de sus DLL ni de la carpeta `data`.

## Requisitos

- Windows 10 u 11 de 64 bits;
- Flutter estable 3.44.6 (la versión fijada en CI; funciona desde 3.29);
- Visual Studio 2022 con **Desktop development with C++**;
- Inno Setup 6 para el instalador EXE;
- WiX Toolset 3 para el MSI.

## Compilar la aplicación

```powershell
.\tool\bootstrap.ps1
flutter build windows --release
```

La carpeta directa queda en:

```text
build\windows\x64\runner\Release\
```

## Empaquetar

El workflow instala Inno Setup y WiX, comprime la carpeta Release, ejecuta `packaging/windows/installer.iss` y cosecha los mismos archivos para `packaging/windows/product.wxs`. Así las tres modalidades contienen el mismo binario Flutter.

Para repetirlo localmente, usa como referencia exacta los pasos PowerShell de `.github/workflows/release.yml`.

## Datos y actualizaciones

`shared_preferences` guarda el progreso en el perfil local del usuario, fuera de la carpeta de instalación. Reinstalar o actualizar con EXE/MSI normalmente conserva ese perfil. Borrar datos de la aplicación o el perfil de Windows puede eliminarlo.

El portable describe la forma de distribución, no un modo sin escritura: el progreso sigue usando las preferencias del usuario de Windows y no se escribe junto al EXE.

## SmartScreen y firma

Los instaladores comunitarios no incluyen un certificado comercial Authenticode. Windows puede mostrar SmartScreen aunque el archivo sea el publicado oficialmente. Comprueba:

1. que la URL pertenezca al repositorio oficial;
2. que el nombre coincida con la versión;
3. que SHA-256 coincida con `SHA256SUMS.txt`;
4. que el antivirus no detecte cambios.

Una release futura puede incorporar firma de código sin cambiar la funcionalidad.

## Prueba manual mínima

- abrir el EXE desde la carpeta Release durante CI;
- instalar con Setup EXE, abrir y desinstalar;
- instalar con MSI, reparar y desinstalar;
- descomprimir el ZIP en una ruta sin privilegios y abrir;
- cambiar tamaño de ventana y comprobar navegación lateral;
- completar una clase y verificar persistencia después de cerrar;
- comprobar modo oscuro y texto ampliado;
- comprobar que no aparecen solicitudes de cámara ni micrófono.

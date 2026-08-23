import { existsSync, readFileSync, writeFileSync } from 'node:fs';

const replacements = [
  {
    path: 'android/app/src/main/AndroidManifest.xml',
    apply(source) {
      return source.replace(
        /android:label="panuelo_al_viento"/g,
        'android:label="Pañuelo al Viento"',
      );
    },
  },
  {
    path: 'android/app/build.gradle.kts',
    apply(source) {
      return source.replace(
        /minSdk\s*=\s*flutter\.minSdkVersion/g,
        'minSdk = 24',
      );
    },
  },
  {
    path: 'windows/runner/main.cpp',
    apply(source) {
      return source.replace(/L"panuelo_al_viento"/g, 'L"Pañuelo al Viento"');
    },
  },
  {
    path: 'windows/runner/Runner.rc',
    apply(source) {
      return source
        .replace(/#define COMPANY_NAME "[^"]*"/g, '#define COMPANY_NAME "Vladimir Acuña"')
        .replace(/#define FILE_DESCRIPTION "[^"]*"/g, '#define FILE_DESCRIPTION "Pañuelo al Viento"')
        .replace(/#define INTERNAL_NAME "[^"]*"/g, '#define INTERNAL_NAME "Pañuelo al Viento"')
        .replace(/#define PRODUCT_NAME "[^"]*"/g, '#define PRODUCT_NAME "Pañuelo al Viento"')
        .replace(/VALUE "CompanyName", "[^"]*"/g, 'VALUE "CompanyName", "Vladimir Acuña"')
        .replace(/VALUE "FileDescription", "[^"]*"/g, 'VALUE "FileDescription", "Pañuelo al Viento"')
        .replace(/VALUE "InternalName", "[^"]*"/g, 'VALUE "InternalName", "Pañuelo al Viento"')
        .replace(/VALUE "ProductName", "[^"]*"/g, 'VALUE "ProductName", "Pañuelo al Viento"');
    },
  },
];

let configured = 0;
for (const replacement of replacements) {
  if (!existsSync(replacement.path)) continue;
  const before = readFileSync(replacement.path, 'utf8');
  const after = replacement.apply(before);
  writeFileSync(replacement.path, after, 'utf8');
  configured += 1;
  console.log(`Configurado: ${replacement.path}`);
}

const forbiddenPermissions = [
  'android.permission.CAMERA',
  'android.permission.RECORD_AUDIO',
];
const manifestPath = 'android/app/src/main/AndroidManifest.xml';
if (existsSync(manifestPath)) {
  const manifest = readFileSync(manifestPath, 'utf8');
  const found = forbiddenPermissions.filter((permission) => manifest.includes(permission));
  if (found.length) {
    throw new Error(`Permisos infantiles no autorizados en Android: ${found.join(', ')}`);
  }
}

if (!configured) {
  throw new Error('No se encontró ninguna plataforma generada. Ejecuta flutter create primero.');
}

console.log('Plataformas configuradas sin permisos de cámara ni micrófono.');

import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { join } from 'node:path';

import { readAppVersion } from './app_version.mjs';

/**
 * Verifica un APK ya compilado: identidad, versión operativa, nivel de API,
 * permisos y contenido real del currículo.
 *
 * Uso: node tool/verify_apk.mjs <ruta-al-apk> [version-esperada]
 *
 * Un APK que compila y se firma todavía puede publicarse con la versión
 * equivocada o sin el currículo dentro. Esta comprobación abre el archivo y
 * mide lo que contiene en vez de confiar en que la compilación salió verde.
 */

const EXPECTED_PACKAGE = 'cl.panueloalviento.panuelo_al_viento';
const EXPECTED_MIN_SDK = 24;
const CURRICULUM_ENTRY = 'assets/flutter_assets/assets/content/curriculum.json';

const FORBIDDEN_PERMISSIONS = [
  'android.permission.CAMERA',
  'android.permission.RECORD_AUDIO',
  'android.permission.INTERNET',
  'android.permission.ACCESS_FINE_LOCATION',
  'android.permission.ACCESS_COARSE_LOCATION',
  'android.permission.READ_EXTERNAL_STORAGE',
  'android.permission.READ_CONTACTS',
];

function findAapt2() {
  if (process.env.AAPT2) return process.env.AAPT2;
  const roots = [
    process.env.ANDROID_SDK_ROOT,
    process.env.ANDROID_HOME,
    process.env.LOCALAPPDATA ? join(process.env.LOCALAPPDATA, 'Android', 'Sdk') : undefined,
  ].filter(Boolean);

  for (const root of roots) {
    const buildTools = join(root, 'build-tools');
    if (!existsSync(buildTools)) continue;
    const versions = readdirSync(buildTools)
      .filter((name) => statSync(join(buildTools, name)).isDirectory())
      .sort((a, b) =>
        a.localeCompare(b, undefined, { numeric: true, sensitivity: 'base' }),
      );
    for (const version of versions.reverse()) {
      for (const binary of ['aapt2.exe', 'aapt2', 'aapt.exe', 'aapt']) {
        const candidate = join(buildTools, version, binary);
        if (existsSync(candidate)) return candidate;
      }
    }
  }
  throw new Error(
    'No se encontró aapt2. Instala las build-tools de Android o exporta AAPT2 con la ruta al binario.',
  );
}

function badging(apkPath) {
  const aapt2 = findAapt2();
  return execFileSync(aapt2, ['dump', 'badging', apkPath], {
    encoding: 'utf8',
    maxBuffer: 32 * 1024 * 1024,
  });
}

function readEntry(apkPath, entry) {
  return execFileSync('unzip', ['-p', apkPath, entry], {
    maxBuffer: 64 * 1024 * 1024,
  });
}

function sha256(buffer) {
  return createHash('sha256').update(buffer).digest('hex');
}

const apkPath = process.argv[2];
if (!apkPath) {
  console.error('Uso: node tool/verify_apk.mjs <ruta-al-apk> [version-esperada]');
  process.exit(1);
}
if (!existsSync(apkPath)) {
  console.error(`No existe el archivo ${apkPath}.`);
  process.exit(1);
}

const expected = process.argv[3] ?? readAppVersion().version;
const expectedBuild = process.argv[3] ? undefined : readAppVersion().build;

const errors = [];
const facts = [];

const dump = badging(apkPath);

const packageLine = dump.match(
  /^package: name='([^']+)' versionCode='(\d+)' versionName='([^']*)'/m,
);
if (!packageLine) {
  errors.push('aapt2 no devolvió una línea "package:" reconocible.');
} else {
  const [, packageName, versionCode, versionName] = packageLine;
  facts.push(`paquete ${packageName}`);
  facts.push(`versionName ${versionName}`);
  facts.push(`versionCode ${versionCode}`);

  if (packageName !== EXPECTED_PACKAGE) {
    errors.push(`El paquete es ${packageName} y debería ser ${EXPECTED_PACKAGE}.`);
  }
  if (versionName !== expected) {
    errors.push(`El APK declara versionName ${versionName} y se esperaba ${expected}.`);
  }
  if (expectedBuild !== undefined && versionCode !== expectedBuild) {
    errors.push(`El APK declara versionCode ${versionCode} y se esperaba ${expectedBuild}.`);
  }
}

const minSdk = dump.match(/^minSdkVersion:'(\d+)'/m);
if (!minSdk) {
  errors.push('El APK no declara minSdkVersion.');
} else {
  facts.push(`minSdkVersion ${minSdk[1]}`);
  if (Number(minSdk[1]) !== EXPECTED_MIN_SDK) {
    errors.push(
      `minSdkVersion es ${minSdk[1]} y debería ser ${EXPECTED_MIN_SDK} (Android 7.0), tal como anuncia la documentación.`,
    );
  }
}

const permissions = [...dump.matchAll(/^uses-permission: name='([^']+)'/gm)].map(
  (match) => match[1],
);
const declared = permissions.filter((name) => !name.startsWith(EXPECTED_PACKAGE));
facts.push(
  declared.length
    ? `permisos declarados: ${declared.join(', ')}`
    : 'sin permisos del sistema declarados',
);
for (const forbidden of FORBIDDEN_PERMISSIONS) {
  if (permissions.includes(forbidden)) {
    errors.push(`El APK declara el permiso prohibido ${forbidden}.`);
  }
}

const abis = [...dump.matchAll(/^native-code: (.+)$/gm)]
  .flatMap((match) => match[1].split(' '))
  .map((value) => value.replace(/'/g, ''));
if (abis.length) facts.push(`ABIs ${abis.join(', ')}`);
for (const abi of ['arm64-v8a', 'armeabi-v7a']) {
  if (!abis.includes(abi)) {
    errors.push(`El APK universal no incluye código nativo para ${abi}.`);
  }
}

try {
  const packed = readEntry(apkPath, CURRICULUM_ENTRY);
  const packedHash = sha256(packed);
  facts.push(`currículo empaquetado ${packed.length} bytes`);

  const curriculum = JSON.parse(packed.toString('utf8'));
  const levels = curriculum.levels?.length ?? 0;
  const lessons = (curriculum.levels ?? []).reduce(
    (total, level) => total + (level.lessons?.length ?? 0),
    0,
  );
  facts.push(`${levels} niveles y ${lessons} clases dentro del APK`);
  if (levels === 0 || lessons === 0) {
    errors.push('El currículo empaquetado está vacío.');
  }

  const repoPath = 'assets/content/curriculum.json';
  if (existsSync(repoPath)) {
    const repoHash = sha256(readFileSync(repoPath));
    if (repoHash !== packedHash) {
      errors.push(
        'El currículo dentro del APK no coincide con assets/content/curriculum.json del repositorio.',
      );
    } else {
      facts.push('el currículo del APK coincide con el del repositorio');
    }
  }
} catch (error) {
  errors.push(`No se pudo leer ${CURRICULUM_ENTRY} dentro del APK: ${error.message}`);
}

console.log(`APK verificado: ${apkPath}`);
for (const fact of facts) console.log(`  · ${fact}`);

if (errors.length) {
  console.error(`\nAPK inválido:\n- ${errors.join('\n- ')}`);
  process.exit(1);
}

console.log(`\nAPK correcto para la versión ${expected}.`);

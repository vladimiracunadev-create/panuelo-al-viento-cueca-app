import { existsSync, readFileSync } from 'node:fs';

import { readAppVersion } from './app_version.mjs';

/**
 * Comprueba que el repositorio publicado sea coherente consigo mismo.
 *
 * No mide calidad de código: mide que lo que la documentación afirma sea lo
 * que el repositorio contiene, y que la versión sea la misma en todas partes.
 * Corre sin instalar Flutter ni dependencias.
 */

const requiredFiles = [
  'README.md',
  'LICENSE',
  'CHANGELOG.md',
  'SECURITY.md',
  'CONTRIBUTING.md',
  'CODE_OF_CONDUCT.md',
  'ROADMAP.md',
  'docs/ACCESSIBILITY.md',
  'docs/ARCHITECTURE.md',
  'docs/BUILD_MOBILE.md',
  'docs/BUILD_WINDOWS.md',
  'docs/CONTENT_LICENSES.md',
  'docs/CURRICULUM.md',
  'docs/PARENT_GUIDE.md',
  'docs/PEDAGOGY_AND_SAFETY.md',
  'docs/PERMISSIONS.md',
  'docs/PRACTICE_PLAN_8_WEEKS.md',
  'docs/PRIVACY.md',
  'docs/RELEASE_CHECKLIST.md',
  'docs/SOURCES.md',
  'docs/TEACHER_GUIDE.md',
  'docs/TEACHER_REVIEW.md',
  'docs/VALIDATION.md',
  'docs/VALIDATION_RESULT.md',
  'assets/content/curriculum.json',
  'assets/branding/logo.svg',
  'assets/branding/app-icon.png',
  'tool/app_version.mjs',
  'tool/verify_apk.mjs',
  'tool/capture_screenshots.mjs',
];

const errors = [];

for (const path of requiredFiles) {
  if (!existsSync(path)) errors.push(`Falta ${path}.`);
}

let version = null;
let build = null;
try {
  ({ version, build } = readAppVersion());
} catch (error) {
  errors.push(error.message);
}

const readme = existsSync('README.md') ? readFileSync('README.md', 'utf8') : '';
const changelog = existsSync('CHANGELOG.md') ? readFileSync('CHANGELOG.md', 'utf8') : '';

if (version) {
  // La versión declarada debe tener notas de publicación propias.
  const notes = `docs/releases/v${version}.md`;
  if (!existsSync(notes)) {
    errors.push(
      `Falta ${notes}. Cada versión publicable necesita sus propias notas antes del tag.`,
    );
  }

  // El historial debe encabezarse con la versión que se va a publicar.
  const firstEntry = changelog.match(/^##\s+(\d+\.\d+\.\d+)\s+—\s+(\d{4}-\d{2}-\d{2})\s*$/m);
  if (!firstEntry) {
    errors.push('CHANGELOG.md debe tener una entrada "## X.Y.Z — AAAA-MM-DD".');
  } else if (firstEntry[1] !== version) {
    errors.push(
      `CHANGELOG.md encabeza la versión ${firstEntry[1]} y pubspec.yaml declara ${version}.`,
    );
  }

  // Los nombres de los artefactos publicados llevan la versión dentro.
  const artifacts = [
    `PanueloAlViento-${version}-Android.apk`,
    `PanueloAlViento-${version}-Windows-Setup.exe`,
    `PanueloAlViento-${version}-Windows.msi`,
    `PanueloAlViento-${version}-Windows-portable.zip`,
  ];
  for (const artifact of artifacts) {
    if (!readme.includes(artifact)) {
      errors.push(`README.md no nombra el artefacto ${artifact} de la versión actual.`);
    }
  }

  // Un versionCode que no crece impide actualizar en Android.
  if (build && Number(build) < 1) {
    errors.push('El número de compilación de pubspec.yaml debe ser 1 o mayor.');
  }
}

// Las capturas que el README enseña tienen que existir de verdad.
const referencedImages = [...readme.matchAll(/!\[[^\]]*\]\((docs\/[^)\s]+)\)/g)].map(
  (match) => match[1],
);
for (const image of new Set(referencedImages)) {
  if (!existsSync(image)) {
    errors.push(`README.md muestra ${image} pero el archivo no existe.`);
  }
}

// Las notas de publicación se leen en GitHub Releases, donde los enlaces
// relativos al repositorio no resuelven.
if (version && existsSync(`docs/releases/v${version}.md`)) {
  const notes = readFileSync(`docs/releases/v${version}.md`, 'utf8');
  const relative = [...notes.matchAll(/\]\((\.\.?\/[^)\s]+)\)/g)].map((match) => match[1]);
  if (relative.length) {
    errors.push(
      `Las notas de la versión usan enlaces relativos que se rompen en la página de releases: ${relative.join(', ')}.`,
    );
  }
}

// La versión 0.x no activa sensores; el compromiso se comprueba en el código.
const sourceFiles = ['pubspec.yaml', 'lib/main.dart', 'lib/app.dart'];
const libSources = [
  'lib/screens/rhythm_lab_screen.dart',
  'lib/screens/lesson_screen.dart',
  'lib/screens/progress_tab.dart',
  'lib/data/progress_repository.dart',
];
const combined = [...sourceFiles, ...libSources]
  .filter((path) => existsSync(path))
  .map((path) => readFileSync(path, 'utf8'))
  .join('\n');
for (const forbidden of ['permission_handler', 'camera:', 'microphone:', 'dart:io']) {
  if (combined.includes(forbidden)) {
    errors.push(`Esta versión no debe usar ${forbidden}.`);
  }
}

if (errors.length) {
  console.error(`Repositorio inválido:\n- ${errors.join('\n- ')}`);
  process.exit(1);
}

console.log(
  `Repositorio válido: ${requiredFiles.length} archivos esenciales, ${referencedImages.length} capturas y versión ${version}+${build} coherente en pubspec, CHANGELOG, notas y README.`,
);

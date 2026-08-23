import { existsSync, readFileSync } from 'node:fs';

const requiredFiles = [
  'README.md',
  'LICENSE',
  'CHANGELOG.md',
  'SECURITY.md',
  'docs/ACCESSIBILITY.md',
  'docs/ARCHITECTURE.md',
  'docs/BUILD_MOBILE.md',
  'docs/BUILD_WINDOWS.md',
  'docs/PERMISSIONS.md',
  'docs/PRIVACY.md',
  'docs/RELEASE_CHECKLIST.md',
  'assets/content/curriculum.json',
  'assets/branding/logo.svg',
  'assets/branding/app-icon.png',
];

const errors = [];
for (const path of requiredFiles) {
  if (!existsSync(path)) errors.push(`Falta ${path}.`);
}

const pubspec = readFileSync('pubspec.yaml', 'utf8');
if (!/^version:\s+0\.1\.0\+1$/m.test(pubspec)) {
  errors.push('pubspec.yaml debe declarar version: 0.1.0+1.');
}

const sourceFiles = [
  ...['pubspec.yaml', 'lib/main.dart', 'lib/app.dart', 'lib/screens/rhythm_lab_screen.dart'],
].map((path) => readFileSync(path, 'utf8')).join('\n');
for (const forbidden of ['permission_handler', 'camera:', 'microphone:']) {
  if (sourceFiles.includes(forbidden)) {
    errors.push(`La versión 0.1.0 no debe activar ${forbidden}.`);
  }
}

if (errors.length) {
  console.error(`Repositorio inválido:\n- ${errors.join('\n- ')}`);
  process.exit(1);
}

console.log(`Repositorio válido: ${requiredFiles.length} archivos esenciales y versión 0.1.0+1.`);

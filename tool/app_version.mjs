import { readFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';

/**
 * Única fuente de verdad de la versión publicable: `pubspec.yaml`.
 * Para `version: 0.1.0+1` devuelve `{ version: '0.1.0', build: '1', full: '0.1.0+1' }`.
 */
export function readAppVersion(pubspecPath = 'pubspec.yaml') {
  const source = readFileSync(pubspecPath, 'utf8');
  const match = source.match(/^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$/m);
  if (!match) {
    throw new Error(
      'pubspec.yaml debe declarar una línea "version: X.Y.Z+N" con versión semántica y número de compilación.',
    );
  }
  const [, version, build] = match;
  return { version, build, full: `${version}+${build}` };
}

const invokedDirectly =
  process.argv[1] !== undefined &&
  import.meta.url === pathToFileURL(process.argv[1]).href;

if (invokedDirectly) {
  const values = readAppVersion();
  const field = process.argv[2] ?? 'version';
  if (!(field in values)) {
    console.error(`Campo desconocido: ${field}. Usa version, build o full.`);
    process.exit(1);
  }
  console.log(values[field]);
}

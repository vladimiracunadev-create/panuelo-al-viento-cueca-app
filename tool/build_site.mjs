import { cpSync, existsSync, mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';

import { readAppVersion } from './app_version.mjs';

/**
 * Ensambla la landing publicable en `build/site/`.
 *
 * La versión y los nombres de archivo de las descargas no se escriben a mano
 * en el HTML: se sustituyen desde `pubspec.yaml`. Una landing que promete
 * `PanueloAlViento-0.1.0-Android.apk` después de publicar 0.2.0 ofrece una
 * descarga que devuelve 404, y nadie se entera hasta que alguien la intenta.
 *
 * Uso:
 *   node tool/build_site.mjs             # ensambla en build/site
 *   node tool/build_site.mjs --serve     # además lo sirve en localhost:8080
 */

const SOURCE = resolve('site');
const SCREENSHOTS = resolve('docs/screenshots');
const OUTPUT = resolve(process.env.SITE_OUT ?? 'build/site');
const PLACEHOLDER = '__APP_VERSION__';

const { version } = readAppVersion();

if (!existsSync(SOURCE)) {
  console.error('No existe el directorio site/.');
  process.exit(1);
}

rmSync(OUTPUT, { recursive: true, force: true });
mkdirSync(OUTPUT, { recursive: true });

let substitutions = 0;
for (const name of readdirSync(SOURCE)) {
  const from = join(SOURCE, name);
  const to = join(OUTPUT, name);
  if (name.endsWith('.html')) {
    const source = readFileSync(from, 'utf8');
    substitutions += source.split(PLACEHOLDER).length - 1;
    writeFileSync(to, source.replaceAll(PLACEHOLDER, version), 'utf8');
  } else {
    cpSync(from, to, { recursive: true });
  }
}

if (!substitutions) {
  console.error(
    `Ningún archivo de site/ usa ${PLACEHOLDER}. La versión quedaría escrita a mano en la landing.`,
  );
  process.exit(1);
}

// La marca y las capturas viven en el repositorio, no duplicadas dentro de site/.
cpSync(resolve('assets/branding/logo.svg'), join(OUTPUT, 'logo.svg'));

mkdirSync(join(OUTPUT, 'screenshots'), { recursive: true });
const shots = readdirSync(SCREENSHOTS).filter((name) => name.endsWith('.png'));
if (!shots.length) {
  console.error('No hay capturas en docs/screenshots/.');
  process.exit(1);
}
for (const shot of shots) {
  cpSync(join(SCREENSHOTS, shot), join(OUTPUT, 'screenshots', shot));
}

// Ninguna imagen referenciada puede faltar: en una landing eso es un hueco roto.
const html = readFileSync(join(OUTPUT, 'index.html'), 'utf8');
const referenced = [...html.matchAll(/src="([^"]+)"/g)].map((match) => match[1]);
const missing = referenced.filter((path) => !existsSync(join(OUTPUT, path)));
if (missing.length) {
  console.error(`La landing referencia archivos que no existen: ${missing.join(', ')}`);
  process.exit(1);
}

console.log(
  `Landing ensamblada en ${OUTPUT}: versión ${version} en ${substitutions} lugares, ${shots.length} capturas y ${referenced.length} imágenes comprobadas.`,
);

if (process.argv.includes('--serve')) {
  const { createServer } = await import('node:http');
  const { extname } = await import('node:path');
  const port = Number(process.env.SITE_PORT ?? 8080);
  const types = {
    '.html': 'text/html; charset=utf-8',
    '.svg': 'image/svg+xml',
    '.png': 'image/png',
  };
  createServer((request, response) => {
    const path = decodeURIComponent(new URL(request.url, 'http://localhost').pathname);
    const file = join(OUTPUT, path === '/' ? 'index.html' : path);
    if (!file.startsWith(OUTPUT) || !existsSync(file)) {
      response.writeHead(404).end('No encontrado');
      return;
    }
    response.writeHead(200, {
      'Content-Type': types[extname(file)] ?? 'application/octet-stream',
    });
    response.end(readFileSync(file));
  }).listen(port, '127.0.0.1', () => {
    console.log(`Sirviendo en http://127.0.0.1:${port}/ · Ctrl+C para detener.`);
  });
}

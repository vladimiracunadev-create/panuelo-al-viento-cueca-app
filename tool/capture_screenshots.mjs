import { spawn, spawnSync } from 'node:child_process';
import { createServer } from 'node:http';
import { cpSync, existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { extname, join, resolve } from 'node:path';

/**
 * Regenera las capturas de `docs/screenshots/` con la aplicación real.
 *
 * Compila la app para web (la única superficie que se puede renderizar sin
 * Visual Studio ni un dispositivo Android), la sirve en localhost y conduce un
 * Chrome sin ventana con el protocolo DevTools: navega, pulsa y guarda cada
 * pantalla. La interfaz, el currículo y el estado son los mismos que en
 * Android y Windows, así que lo que se ve aquí es lo que se ve allí.
 *
 * Uso:
 *   node tool/capture_screenshots.mjs            # compila, captura y reemplaza
 *   node tool/capture_screenshots.mjs --keep     # conserva el directorio temporal
 *
 * Requisitos: Flutter estable en el PATH y Google Chrome instalado
 * (o la variable CHROME_BIN apuntando al ejecutable).
 */

const OUTPUT_DIR = resolve('docs/screenshots');
const PORT = Number(process.env.SHOT_PORT ?? 8731);
const DEBUG_PORT = Number(process.env.SHOT_DEBUG_PORT ?? 9333);
const KEEP = process.argv.includes('--keep');

const CHROME_CANDIDATES = [
  process.env.CHROME_BIN,
  'C:/Program Files/Google/Chrome/Application/chrome.exe',
  'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe',
  process.env.LOCALAPPDATA
    ? join(process.env.LOCALAPPDATA, 'Google/Chrome/Application/chrome.exe')
    : undefined,
  '/usr/bin/google-chrome',
  '/usr/bin/chromium',
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
].filter(Boolean);

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.png': 'image/png',
  '.svg': 'image/svg+xml',
  '.wasm': 'application/wasm',
  '.otf': 'font/otf',
  '.ttf': 'font/ttf',
  '.ico': 'image/x-icon',
};

const sleep = (ms) => new Promise((done) => setTimeout(done, ms));

function run(command, args, options = {}) {
  const result = spawnSync(command, args, { stdio: 'inherit', shell: true, ...options });
  if (result.status !== 0) {
    throw new Error(`Falló: ${command} ${args.join(' ')}`);
  }
}

function findChrome() {
  const found = CHROME_CANDIDATES.find((candidate) => existsSync(candidate));
  if (!found) {
    throw new Error(
      'No se encontró Chrome. Instálalo o exporta CHROME_BIN con la ruta al ejecutable.',
    );
  }
  return found;
}

function buildWeb(workDir) {
  console.log('Compilando la aplicación para web…');
  cpSync('lib', join(workDir, 'lib'), { recursive: true });
  cpSync('assets', join(workDir, 'assets'), { recursive: true });
  cpSync('pubspec.yaml', join(workDir, 'pubspec.yaml'));
  cpSync('analysis_options.yaml', join(workDir, 'analysis_options.yaml'));

  const flutterArgs = [
    'create',
    '--project-name',
    'panuelo_al_viento',
    '--org',
    'cl.panueloalviento',
    '--platforms=web',
    '--no-pub',
    '.',
  ];
  run('flutter', flutterArgs, { cwd: workDir });
  run('flutter', ['pub', 'get'], { cwd: workDir });
  run('flutter', ['build', 'web', '--release'], { cwd: workDir });
  return join(workDir, 'build', 'web');
}

function serve(root) {
  const server = createServer((request, response) => {
    const path = decodeURIComponent(new URL(request.url, 'http://localhost').pathname);
    const file = join(root, path === '/' ? 'index.html' : path);
    if (!file.startsWith(root) || !existsSync(file)) {
      response.writeHead(404).end('No encontrado');
      return;
    }
    response.writeHead(200, {
      'Content-Type': MIME[extname(file)] ?? 'application/octet-stream',
      'Cache-Control': 'no-store',
    });
    response.end(readFileSync(file));
  });
  return new Promise((ready) => server.listen(PORT, '127.0.0.1', () => ready(server)));
}

async function connectDevTools() {
  for (let attempt = 0; attempt < 60; attempt += 1) {
    try {
      const response = await fetch(`http://127.0.0.1:${DEBUG_PORT}/json/list`);
      const targets = await response.json();
      const page = targets.find((target) => target.type === 'page');
      if (page?.webSocketDebuggerUrl) return page.webSocketDebuggerUrl;
    } catch {
      // Chrome todavía no abrió el puerto de depuración.
    }
    await sleep(500);
  }
  throw new Error('Chrome no expuso el puerto de depuración.');
}

async function main() {
  const chromeBinary = findChrome();
  const workDir = mkdtempSync(join(tmpdir(), 'panuelo-shots-'));
  const profileDir = join(workDir, 'chrome-profile');
  let server;
  let chrome;

  try {
    const webRoot = buildWeb(workDir);
    server = await serve(webRoot);
    console.log(`Sirviendo la build en http://127.0.0.1:${PORT}/`);

    chrome = spawn(
      chromeBinary,
      [
        '--headless=new',
        `--remote-debugging-port=${DEBUG_PORT}`,
        `--user-data-dir=${profileDir}`,
        '--no-first-run',
        '--no-default-browser-check',
        '--disable-extensions',
        '--hide-scrollbars',
        'about:blank',
      ],
      { stdio: 'ignore' },
    );

    const socket = new WebSocket(await connectDevTools());
    await new Promise((open) => {
      socket.onopen = open;
    });

    let nextId = 1;
    const pending = new Map();
    const events = [];
    socket.onmessage = (message) => {
      const payload = JSON.parse(message.data);
      if (payload.id && pending.has(payload.id)) {
        const { resolveCall, rejectCall } = pending.get(payload.id);
        pending.delete(payload.id);
        payload.error ? rejectCall(new Error(payload.error.message)) : resolveCall(payload.result);
      } else if (payload.method) {
        events.push(payload.method);
      }
    };

    const send = (method, params = {}) => {
      const id = nextId++;
      socket.send(JSON.stringify({ id, method, params }));
      return new Promise((resolveCall, rejectCall) =>
        pending.set(id, { resolveCall, rejectCall }),
      );
    };

    const waitFor = async (event, timeout = 30000) => {
      const start = Date.now();
      while (Date.now() - start < timeout) {
        const index = events.indexOf(event);
        if (index >= 0) {
          events.splice(index, 1);
          return;
        }
        await sleep(50);
      }
      throw new Error(`Sin evento ${event}.`);
    };

    const boot = async ({ dark = false, width = 400, height = 860 } = {}) => {
      await send('Emulation.setDeviceMetricsOverride', {
        width,
        height,
        deviceScaleFactor: 2,
        mobile: width < 840,
      });
      await send('Emulation.setEmulatedMedia', {
        media: '',
        features: [{ name: 'prefers-color-scheme', value: dark ? 'dark' : 'light' }],
      });
      await send('Page.navigate', { url: `http://127.0.0.1:${PORT}/?t=${nextId}` });
      await waitFor('Page.loadEventFired');
      await sleep(6000);
    };

    const click = async (x, y) => {
      await send('Input.dispatchMouseEvent', {
        type: 'mousePressed',
        x,
        y,
        button: 'left',
        buttons: 1,
        clickCount: 1,
      });
      await sleep(60);
      await send('Input.dispatchMouseEvent', {
        type: 'mouseReleased',
        x,
        y,
        button: 'left',
        buttons: 0,
        clickCount: 1,
      });
      await sleep(900);
    };

    const scroll = async (deltaY) => {
      await send('Input.dispatchMouseEvent', {
        type: 'mouseWheel',
        x: 200,
        y: 500,
        deltaX: 0,
        deltaY,
      });
      await sleep(900);
    };

    const shot = async (name) => {
      const { data } = await send('Page.captureScreenshot', { format: 'png' });
      writeFileSync(join(OUTPUT_DIR, `${name}.png`), Buffer.from(data, 'base64'));
      console.log(`  capturada ${name}.png`);
    };

    await send('Page.enable');
    mkdirSync(OUTPUT_DIR, { recursive: true });

    const navY = 820;
    const NAV = { inicio: 50, ruta: 150, ritmo: 250, avance: 350 };

    console.log('Capturando pantallas…');
    await boot();
    await shot('01-inicio');

    await click(NAV.ruta, navY);
    await shot('02-ruta');

    await click(200, 346); // primera clase de la ruta
    await shot('03-clase');
    await scroll(1500);
    await shot('04-clase-pasos');
    await click(28, 28); // volver

    await click(NAV.ritmo, navY);
    await shot('05-ritmo');

    await click(NAV.avance, navY);
    await shot('06-avance');
    await scroll(2600);
    await shot('07-privacidad');

    await boot({ dark: true });
    await scroll(700); // deja a la vista las dos tarjetas de acción
    await shot('08-oscuro');

    await boot({ width: 1180, height: 780 });
    await shot('09-escritorio');

    socket.close();
    console.log(`\nCapturas escritas en ${OUTPUT_DIR}.`);
    console.log('Optimiza el peso antes de commitear si el repositorio crece demasiado.');
  } finally {
    chrome?.kill();
    server?.close();
    if (KEEP) {
      console.log(`Directorio temporal conservado en ${workDir}.`);
    } else {
      // Chrome tarda un momento en soltar su perfil; en Windows borrarlo
      // demasiado pronto lanza EPERM. Un temporal que sobrevive no es motivo
      // para dar por fallida una captura que ya se escribió.
      for (let attempt = 0; attempt < 5; attempt += 1) {
        try {
          rmSync(workDir, { recursive: true, force: true });
          break;
        } catch {
          if (attempt === 4) {
            console.warn(`No se pudo borrar el temporal ${workDir}.`);
            break;
          }
          await sleep(1000);
        }
      }
    }
  }
}

await main();

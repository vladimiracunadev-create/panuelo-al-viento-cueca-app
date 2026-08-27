#!/usr/bin/env python3
"""Genera los PDF de `docs/system-documentation/` desde sus propios Markdown.

Los Markdown son la fuente única. Este script nunca los modifica: los lee, los
compone y escribe un PDF por documento en `docs/system-documentation/pdf/`, más
un consolidado con todos ellos.

La versión y el commit de la portada se leen del repositorio —`pubspec.yaml` y
`git rev-parse`—, nunca se escriben a mano: una portada con números a mano queda
obsoleta en el primer commit.

Uso
---
    python tool/build_docs_pdf.py
    python tool/build_docs_pdf.py --only 03-architecture.md
    python tool/build_docs_pdf.py --no-mermaid     # degrada los diagramas a texto

Dependencias
------------
    pip install markdown xhtml2pdf
    npm install -g @mermaid-js/mermaid-cli    # opcional, para rasterizar diagramas

Sin `mmdc` los diagramas Mermaid **no se pierden**: se incluyen como bloque
monoespaciado con un aviso visible, y el resumen final dice cuántos degradaron.
Nunca se degrada en silencio.
"""

from __future__ import annotations

import argparse
import hashlib
import html
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DOCS = ROOT / "docs" / "system-documentation"
OUT = DOCS / "pdf"
CACHE = ROOT / ".mermaid-cache"

SYSTEM_NAME = "Pañuelo al Viento"
SUBTITLE = "Documentación de sistema"

# Marcador que el conversor de Markdown no toca: sin guiones bajos, sin
# asteriscos y sin nada que parezca sintaxis.
PLACEHOLDER = "MERMAIDDIAGRAMSLOT{0}ENDSLOT"

MERMAID_BLOCK = re.compile(r"^```mermaid[ \t]*\n(.*?)^```[ \t]*$", re.DOTALL | re.MULTILINE)


# --------------------------------------------------------------------------- #
# Datos del repositorio
# --------------------------------------------------------------------------- #

def read_app_version() -> str:
    """Lee `version: X.Y.Z+N` de pubspec.yaml. Misma regla que tool/app_version.mjs."""
    source = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
    match = re.search(r"^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$", source, re.MULTILINE)
    if not match:
        raise SystemExit('pubspec.yaml debe declarar "version: X.Y.Z+N".')
    return f"{match.group(1)}+{match.group(2)}"


def read_commit() -> tuple[str, str]:
    """Devuelve (hash corto, fecha ISO) del HEAD, o ('desconocido', '') sin git."""
    try:
        short = subprocess.run(
            ["git", "rev-parse", "--short", "HEAD"],
            cwd=ROOT, capture_output=True, text=True, check=True,
        ).stdout.strip()
        date = subprocess.run(
            ["git", "log", "-1", "--format=%ad", "--date=short"],
            cwd=ROOT, capture_output=True, text=True, check=True,
        ).stdout.strip()
        return short, date
    except (OSError, subprocess.CalledProcessError):
        return "desconocido", ""


# --------------------------------------------------------------------------- #
# Tipografía
# --------------------------------------------------------------------------- #

FONT_CANDIDATES = {
    "sans": ["DejaVuSans.ttf", "arial.ttf", "segoeui.ttf"],
    "sans-bold": ["DejaVuSans-Bold.ttf", "arialbd.ttf", "segoeuib.ttf"],
    "mono": ["DejaVuSansMono.ttf", "consola.ttf", "cour.ttf"],
    "mono-bold": ["DejaVuSansMono-Bold.ttf", "consolab.ttf", "courbd.ttf"],
}


def font_search_paths() -> list[Path]:
    paths = [
        Path("C:/Windows/Fonts"),
        Path("/usr/share/fonts/truetype/dejavu"),
        Path("/usr/share/fonts/TTF"),
        Path("/Library/Fonts"),
    ]
    try:  # matplotlib empaqueta DejaVu completo; es el respaldo más fiable.
        import matplotlib  # type: ignore

        paths.append(Path(matplotlib.__file__).parent / "mpl-data" / "fonts" / "ttf")
    except Exception:  # noqa: BLE001 - matplotlib es opcional
        pass
    return [p for p in paths if p.is_dir()]


def resolve_fonts() -> dict[str, Path]:
    """Localiza fuentes con cobertura de acentos y de → ≥ ● ★.

    Sin ellas el PDF sale igual, pero con las fuentes base de PDF, que no cubren
    esos signos. El resumen final avisa si se llegó a ese caso.
    """
    found: dict[str, Path] = {}
    directories = font_search_paths()
    for role, names in FONT_CANDIDATES.items():
        for name in names:
            for directory in directories:
                candidate = directory / name
                if candidate.is_file():
                    found[role] = candidate
                    break
            if role in found:
                break
    return found


# --------------------------------------------------------------------------- #
# Diagramas
# --------------------------------------------------------------------------- #

def find_mmdc() -> list[str] | None:
    """En Windows `mmdc` es un .cmd y Node >= 20.12 se niega a lanzarlo sin shell.

    Devuelve la lista de argumentos base con la que invocarlo, o None.
    """
    executable = shutil.which("mmdc")
    if not executable:
        return None
    if executable.lower().endswith((".cmd", ".bat")):
        return ["cmd", "/c", executable]
    return [executable]


def render_mermaid(code: str, mmdc: list[str] | None) -> Path | None:
    """Rasteriza un diagrama a PNG, cacheando por hash de su código fuente.

    La caché evita rehacer veinte diagramas para ver un cambio de margen.
    """
    if mmdc is None:
        return None
    digest = hashlib.sha1(code.encode("utf-8")).hexdigest()[:16]
    target = CACHE / f"{digest}.png"
    if target.is_file() and target.stat().st_size > 0:
        return target

    CACHE.mkdir(parents=True, exist_ok=True)
    source = CACHE / f"{digest}.mmd"
    source.write_text(code, encoding="utf-8", newline="\n")
    command = mmdc + [
        "-i", str(source), "-o", str(target),
        "-b", "white", "-w", "1600", "-s", "2",
    ]
    try:
        subprocess.run(command, cwd=ROOT, capture_output=True, text=True,
                       check=True, timeout=180)
    except (OSError, subprocess.SubprocessError):
        return None
    finally:
        source.unlink(missing_ok=True)
    return target if target.is_file() and target.stat().st_size > 0 else None


# --------------------------------------------------------------------------- #
# Composición
# --------------------------------------------------------------------------- #

def extract_mermaid(text: str) -> tuple[str, list[str]]:
    """Sustituye cada bloque mermaid por un marcador y devuelve los códigos."""
    blocks: list[str] = []

    def swap(match: re.Match[str]) -> str:
        blocks.append(match.group(1))
        return f"\n\n{PLACEHOLDER.format(len(blocks) - 1)}\n\n"

    return MERMAID_BLOCK.sub(swap, text), blocks


def markdown_to_html(text: str) -> str:
    import markdown as md

    return md.markdown(
        text,
        extensions=["tables", "fenced_code", "sane_lists", "attr_list"],
        output_format="html5",
    )


# Nota de maquetación: se probó insertar un espacio de ancho cero (U+200B) tras
# `/ _ . :` dentro de las celdas para dar puntos de corte a las rutas largas.
# reportlab lo dibuja como un rectángulo negro aunque la fuente declare el
# glifo, así que el remedio salía peor que la enfermedad. La solución correcta
# está en el Markdown: mantener cortos los identificadores de las tablas anchas.

def restore_diagrams(body: str, blocks: list[str], mmdc: list[str] | None,
                     stats: dict[str, int]) -> str:
    """Devuelve el marcador a su sitio como imagen, o degradado con aviso."""
    for index, code in enumerate(blocks):
        image = render_mermaid(code, mmdc)
        if image is not None:
            stats["renderizados"] += 1
            replacement = (
                '<div class="diagram">'
                f'<img src="{image.as_posix()}" alt="Diagrama" />'
                "</div>"
            )
        else:
            stats["degradados"] += 1
            replacement = (
                '<div class="diagram-fallback">'
                "<p class=\"warn\">Diagrama no rasterizado. Se muestra su código "
                "fuente Mermaid. Instala <code>@mermaid-js/mermaid-cli</code> y "
                "vuelve a generar para verlo dibujado.</p>"
                f"<pre><code>{html.escape(code.strip())}</code></pre>"
                "</div>"
            )
        token = PLACEHOLDER.format(index)
        # El conversor puede haber envuelto el marcador en un párrafo.
        body = body.replace(f"<p>{token}</p>", replacement).replace(token, replacement)
    return body


HEADING = re.compile(r"^##\s+(.+?)\s*$", re.MULTILINE)
INLINE_MARKUP = re.compile(r"[`*]+")  # no se tocan los _ : forman parte de los identificadores


def build_index(text: str) -> str:
    """Índice de secciones de primer nivel. Solo si el documento lo justifica.

    Se indexan únicamente los `##`: incluir también los `###` producía índices de
    treinta entradas que ocupaban más que la sección que anunciaban.

    Los estilos van en línea y no en la hoja: xhtml2pdf no aplica de forma
    fiable un selector descendente como `.toc p`, y el resultado eran párrafos
    con la separación por defecto, uno por página y media.
    """
    titles = [INLINE_MARKUP.sub("", t).strip() for t in HEADING.findall(text)]
    if len(titles) < 5:
        return ""
    items = "".join(
        f'<p style="font-size:8.4pt; margin-bottom:0;">'
        f"{html.escape(title)}</p>"
        for title in titles
    )
    return (
        '<div class="toc"><h2 style="margin:0 0 4pt 0; font-size:10.5pt;">'
        f"Contenido de este documento</h2>{items}</div>"
    )


def register_fonts(fonts: dict[str, Path]) -> tuple[str, str]:
    """Registra las fuentes en reportlab y devuelve (familia sans, familia mono).

    Se registran por API en vez de con `@font-face` en el CSS: xhtml2pdf trata
    el `src` de una regla `@font-face` como un recurso remoto, lo descarga a un
    temporal y reportlab falla al abrirlo. Registrarlas aquí evita ese rodeo.
    """
    from reportlab.pdfbase import pdfmetrics
    from reportlab.pdfbase.ttfonts import TTFont

    family_sans, family_mono = "Helvetica", "Courier"

    def register(role_regular: str, role_bold: str, family: str) -> str | None:
        if role_regular not in fonts:
            return None
        try:
            pdfmetrics.registerFont(TTFont(family, str(fonts[role_regular])))
            bold = family
            if role_bold in fonts:
                bold = f"{family}-Bold"
                pdfmetrics.registerFont(TTFont(bold, str(fonts[role_bold])))
            pdfmetrics.registerFontFamily(
                family, normal=family, bold=bold, italic=family, boldItalic=bold
            )
            return family
        except Exception:  # noqa: BLE001 - una fuente ilegible no debe detener el PDF
            return None

    family_sans = register("sans", "sans-bold", "DocSans") or family_sans
    family_mono = register("mono", "mono-bold", "DocMono") or family_mono
    return family_sans, family_mono


def stylesheet(family_sans: str, family_mono: str) -> str:
    return f"""
@page {{
  size: a4 portrait;
  margin: 2.0cm 1.7cm 2.0cm 1.7cm;
  @frame footer {{
    -pdf-frame-content: pieDePagina;
    bottom: 1.0cm; left: 1.7cm; right: 1.7cm; height: 1.0cm;
  }}
}}
body {{ font-family: "{family_sans}"; font-size: 9.4pt; line-height: 1.45; color: #202A35; }}
h1 {{ font-size: 17pt; color: #173B63; margin: 0 0 8pt 0; padding-bottom: 4pt;
     border-bottom: 1.6pt solid #173B63; }}
h2 {{ font-size: 12.5pt; color: #173B63; margin: 15pt 0 5pt 0; }}
h3 {{ font-size: 10.6pt; color: #2B6F9F; margin: 11pt 0 4pt 0; }}
h4 {{ font-size: 9.8pt; color: #2B6F9F; margin: 9pt 0 3pt 0; }}
p  {{ margin: 0 0 6pt 0; text-align: left; }}
ul, ol {{ margin: 0 0 6pt 14pt; }}
li {{ margin-bottom: 2pt; }}
a  {{ color: #2B6F9F; text-decoration: none; }}
code {{ font-family: "{family_mono}"; font-size: 8.4pt; background-color: #F2EFE9; }}
pre {{ background-color: #F7F4EE; border-left: 2.4pt solid #2B6F9F;
      padding: 6pt 8pt; margin: 6pt 0 9pt 0; }}
pre code {{ font-family: "{family_mono}"; font-size: 7.7pt; line-height: 1.30;
           background-color: transparent; }}
/* Sin `-pdf-keep-in-frame-mode: shrink`: esa opción encoge la fuente de toda la
   tabla hasta que quepa, y una tabla de cinco columnas acaba a 5 pt. Es
   preferible dejar que el texto haga saltos de línea dentro de la celda. */
table {{ width: 100%; border-collapse: collapse; margin: 6pt 0 10pt 0; }}
th {{ background-color: #173B63; color: #FFFFFF; font-size: 8.2pt;
     padding: 3.5pt 4pt; text-align: left; }}
td {{ font-size: 8.2pt; padding: 3.5pt 4pt; border-bottom: 0.5pt solid #D8CBB9;
     vertical-align: top; }}
blockquote {{ background-color: #F7EFE3; border-left: 2.4pt solid #F2B544;
             padding: 5pt 9pt; margin: 6pt 0 9pt 0; }}
hr {{ border: none; border-top: 0.6pt solid #D8CBB9; margin: 11pt 0; }}
.diagram {{ margin: 8pt 0 10pt 0; text-align: center; }}
.diagram img {{ width: 15.5cm; }}
.diagram-fallback {{ margin: 8pt 0 10pt 0; }}
.warn {{ background-color: #FBE9E7; border-left: 2.4pt solid #B63535;
        padding: 5pt 8pt; font-size: 8.4pt; }}
/* El índice se compone con párrafos y no con <li>: xhtml2pdf da a cada elemento
   de lista una caja propia con separación generosa, y doce entradas ocupaban
   una página entera. Su tipografía va en línea; ver build_index(). */
.toc {{ background-color: #F7F4EE; padding: 7pt 11pt; margin: 0 0 12pt 0; }}
.cover {{ text-align: center; }}
.cover-pad {{ height: 4.6cm; }}
.cover-brand {{ font-size: 11pt; color: #2B6F9F; letter-spacing: 2pt; }}
.cover-name {{ font-size: 27pt; color: #173B63; margin: 6pt 0 2pt 0; }}
.cover-sub {{ font-size: 12.5pt; color: #5A6675; margin: 0 0 22pt 0; }}
.cover-rule {{ border-top: 2pt solid #F2B544; width: 5cm; margin: 0 auto 20pt auto; }}
.cover-title {{ font-size: 16pt; color: #202A35; margin: 0 0 24pt 0; }}
.cover-meta {{ font-size: 9pt; color: #5A6675; line-height: 1.6; }}
.cover-note {{ font-size: 7.8pt; color: #5A6675; margin-top: 24pt; }}
.pagefoot {{ font-size: 7.4pt; color: #7A8492; text-align: center; }}
"""


def cover_html(title: str, version: str, commit: str, commit_date: str) -> str:
    fecha = f" · {commit_date}" if commit_date else ""
    return f"""
<div class="cover">
  <div class="cover-pad"></div>
  <div class="cover-brand">DOCUMENTACIÓN DE SISTEMA</div>
  <h1 class="cover-name" style="border:none;">{html.escape(SYSTEM_NAME)}</h1>
  <div class="cover-sub">{html.escape(SUBTITLE)}</div>
  <div class="cover-rule"></div>
  <div class="cover-title">{html.escape(title)}</div>
  <div class="cover-meta">
    Versión del producto <b>{html.escape(version)}</b><br/>
    Commit <b>{html.escape(commit)}</b>{html.escape(fecha)}<br/>
    Rama <b>main</b>
  </div>
  <div class="cover-note">
    Generado desde los Markdown de docs/system-documentation/ con
    tool/build_docs_pdf.py.<br/>
    La versión y el commit se leen del repositorio; no están escritos a mano.
  </div>
</div>
<pdf:nextpage />
"""


def document_title(text: str, fallback: str) -> str:
    match = re.search(r"^#\s+(.+?)\s*$", text, re.MULTILINE)
    return match.group(1).strip() if match else fallback


def wrap(title: str, css: str, cover: str, body: str) -> str:
    return f"""<!DOCTYPE html>
<html><head><meta charset="utf-8" /><title>{html.escape(title)}</title>
<style>{css}</style></head>
<body>
<div id="pieDePagina" class="pagefoot">
  {html.escape(SYSTEM_NAME)} · {html.escape(title)} · página
  <pdf:pagenumber /> de <pdf:pagecount />
</div>
{cover}
{body}
</body></html>
"""


def write_pdf(document_html: str, destination: Path) -> int:
    from xhtml2pdf import pisa

    destination.parent.mkdir(parents=True, exist_ok=True)
    with destination.open("wb") as handle:
        result = pisa.CreatePDF(document_html, dest=handle, encoding="utf-8")
    if result.err:
        raise SystemExit(f"xhtml2pdf falló al escribir {destination.name}.")
    size = destination.stat().st_size
    if size <= 0:
        raise SystemExit(f"{destination.name} salió de 0 bytes.")
    return size


# --------------------------------------------------------------------------- #

def ordered_documents() -> list[Path]:
    """Portada primero, después los numéricos en orden."""
    files = sorted(p for p in DOCS.glob("*.md"))
    readme = [p for p in files if p.name == "README.md"]
    rest = [p for p in files if p.name != "README.md"]
    return readme + rest


def main() -> int:
    parser = argparse.ArgumentParser(description="Genera los PDF de la documentación de sistema.")
    parser.add_argument("--only", help="Regenera un solo documento, por nombre de archivo.")
    parser.add_argument("--no-mermaid", action="store_true",
                        help="No rasterizar: degradar todos los diagramas a texto.")
    args = parser.parse_args()

    if not DOCS.is_dir():
        raise SystemExit(f"No existe {DOCS}.")

    version = read_app_version()
    commit, commit_date = read_commit()
    fonts = resolve_fonts()
    family_sans, family_mono = register_fonts(fonts)
    css = stylesheet(family_sans, family_mono)
    mmdc = None if args.no_mermaid else find_mmdc()

    print(f"Versión {version} · commit {commit} · tipografía {family_sans}/{family_mono}")
    print("Mermaid: " + ("mmdc disponible" if mmdc else "sin mmdc, los diagramas degradarán a texto"))

    documents = ordered_documents()
    if args.only:
        documents = [p for p in documents if p.name == args.only]
        if not documents:
            raise SystemExit(f"No se encontró {args.only} en {DOCS}.")

    stats = {"renderizados": 0, "degradados": 0}
    consolidated: list[str] = []
    total_bytes = 0

    for path in documents:
        raw = path.read_text(encoding="utf-8")
        title = document_title(raw, path.stem)
        text, blocks = extract_mermaid(raw)
        body = markdown_to_html(text)
        body = restore_diagrams(body, blocks, mmdc, stats)
        body = build_index(raw) + body

        destination = OUT / f"{path.stem}.pdf"
        size = write_pdf(wrap(title, css, cover_html(title, version, commit, commit_date), body),
                         destination)
        total_bytes += size
        print(f"  {destination.name:<42} {size/1024:7.1f} KB   {title}")
        consolidated.append(body)

    if not args.only:
        joined = '<pdf:nextpage />'.join(consolidated)
        title = "Documentación completa"
        destination = OUT / "00-documentacion-completa.pdf"
        size = write_pdf(
            wrap(title, css, cover_html(title, version, commit, commit_date), joined),
            destination,
        )
        total_bytes += size
        print(f"  {destination.name:<42} {size/1024:7.1f} KB   {title}")

    print(
        f"\nListo: {len(documents)} documento(s)"
        f"{'' if args.only else ' + 1 consolidado'}, {total_bytes/1024/1024:.2f} MB en total."
    )
    print(f"Diagramas: {stats['renderizados']} rasterizados, {stats['degradados']} degradados a texto.")
    if stats["degradados"]:
        print("AVISO: hay diagramas incluidos como código fuente. Instala "
              "@mermaid-js/mermaid-cli para rasterizarlos.")
    if family_sans == "Helvetica" or family_mono == "Courier":
        print("AVISO: se usó una fuente base de PDF. Signos como → ≥ ● ★ podrían "
              "no dibujarse. Instala DejaVu o ejecuta desde un sistema con Arial "
              "y Consolas disponibles.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

# Recursos de la documentación de sistema

Carpeta reservada para imágenes que los documentos referencien directamente:
capturas anotadas, esquemas hechos a mano o cualquier ilustración que no se
pueda expresar como diagrama Mermaid.

**Hoy está vacía, y es intencionado.** Los 17 diagramas de esta documentación se
escriben en Mermaid dentro del propio Markdown, de modo que GitHub los dibuja sin
intermediarios y no hay ninguna imagen que pueda quedar desincronizada del texto
que la explica.

Para el PDF, `tool/build_docs_pdf.py` rasteriza esos diagramas con `mmdc` y los
guarda en `.mermaid-cache/`, **fuera del control de versiones** (`.gitignore`).
La caché se indexa por el hash del código fuente de cada diagrama, así que una
regeneración solo rehace lo que cambió, y borrarla no pierde nada: se reconstruye
sola.

Si algún día hace falta añadir una imagen aquí:

- referénciala con ruta relativa desde el documento (`assets/nombre.png`);
- decláralas `binary` en `.gitattributes` si su extensión no lo está ya;
- comprueba que el PDF la incluye, no solo que GitHub la muestra.

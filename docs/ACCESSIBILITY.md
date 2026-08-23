# Accesibilidad

## Objetivo

Pañuelo al Viento intenta que la intención pedagógica no dependa de una única forma corporal, sensorial o de interacción. Una adaptación segura puede cumplir el objetivo aunque no reproduzca el mismo recorrido o gesto.

## Soporte incluido en 0.1.0

- navegación adaptable a celular, tableta y escritorio;
- texto escalable con las preferencias del sistema;
- modo claro u oscuro según el sistema;
- acciones con etiquetas textuales además de iconos;
- objetivos táctiles amplios y controles nativos Flutter;
- diagramas de movimiento con descripción semántica;
- progreso comunicado con texto y porcentaje, no solo con color;
- pulso visual utilizable sin sonido ni vibración;
- alternativas de bajo impacto, sentadas, con manos, voz, señas o ruedas en cada clase;
- repetición sin penalización ni límite;
- ausencia de límites de tiempo para leer o completar una actividad.

## Equivalencias funcionales

| Intención | Ejemplos equivalentes |
|---|---|
| Mantener pulso | Dedos, palmas, voz, hombros, ruedas, luz o vibración. |
| Dibujar un recorrido | Mirada, manos, torso, silla, medio recorrido o pareja móvil. |
| Dialogar | Orientación corporal, gesto, señas, voz, color o sonido. |
| Aumentar energía | Amplitud disponible, contraste, percusión suave o velocidad moderada. |
| Cerrar | Pausa simultánea, gesto, orientación o sonido compartido. |

## Uso por teclado y lector de pantalla

Flutter aporta foco y semántica a botones, navegación, casillas, controles segmentados y sliders. En Windows se recomienda recorrer toda la app con `Tab`, `Shift+Tab`, flechas, `Espacio` y `Enter`. En Android se recomienda TalkBack.

Los diagramas son imágenes semánticas con una descripción del recorrido. La descripción explica la intención; no intenta convertir un dibujo espacial en una orden corporal obligatoria.

## Pendiente de validación humana

La existencia de etiquetas en el código no equivale a una auditoría completa. Antes de afirmar conformidad formal se debe comprobar:

1. TalkBack en un teléfono Android real.
2. Narrador de Windows y navegación solo por teclado.
3. Texto al 200 % en pantallas pequeñas.
4. Contraste de cada estado interactivo.
5. Reducción de movimiento del sistema.
6. Comprensión con personas que utilicen las adaptaciones propuestas.

Registra dispositivo, sistema operativo, tecnología de apoyo, versión y resultado. Los hallazgos se convierten en issues sin incluir datos de niñas o niños.

## Límites conocidos

- La vibración depende del hardware y normalmente no funciona en Windows.
- El clic usa el sonido del sistema y puede variar o estar silenciado.
- Los diagramas son esquemas bidimensionales; no sustituyen una demostración accesible.
- La versión 0.1.0 está solo en español.

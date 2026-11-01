# RandomDash
Juego móvil 2D pixel art estilo Diner Dash. Niveles cortos de servir a clientes.

## Técnica
- Motor: Godot 4.7.2, GDScript tipado
- Renderer: Compatibility
- Orientación: horizontal (landscape)
- Resolución base: 640x360, escalado viewport, filtro de texturas Nearest
- Plataformas: Android (pruebas en Samsung por USB), iOS más adelante

## Estructura
- scenes/ escenas (.tscn)
- scripts/ lógica (.gd), un script por responsabilidad
- assets/sprites, assets/audio
- data/ platos, clientes y niveles en JSON
- tools/ scripts que generan assets (arte procedural)

## Reglas
- Comunicar nodos con señales, no con referencias cruzadas
- Datos en data/, no escritos dentro del código
- No editar .tscn a mano salvo cambios mínimos
- Sprites de 32x32, paleta de 16 colores (por definir)
- Nunca subir keystores ni contraseñas al repositorio
- node_2d.gd es el script del nodo raíz de la escena principal; no adjuntar otro script a ese nodo

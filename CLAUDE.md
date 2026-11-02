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
- Arte: sprites de 16x16 dibujados como texto en scripts/sprite_data.gd, mostrados a escala x2; paleta fija de 16 colores en SpriteFactory.PALETTE; la letra X es el color de tinte
- Nunca subir keystores ni contraseñas al repositorio
- node_2d.gd es el script del nodo raíz de la escena principal; no adjuntar otro script a ese nodo
- El progreso se guarda en user://save.json (clase SaveData); es el dato que más adelante se sincronizará con la cuenta de Google

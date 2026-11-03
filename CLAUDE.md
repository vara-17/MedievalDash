# Medieval Dash
Juego móvil 2D pixel art estilo Diner Dash. Niveles cortos de servir a clientes.

## Técnica
- Motor: Godot 4.7.2, GDScript tipado
- Renderer: Compatibility
- Orientación: horizontal (landscape)
- Resolución base: 640x360, escalado viewport, filtro de texturas Nearest
- Plataformas: Android (pruebas en Samsung por USB), iOS más adelante

## Estructura
- scenes/ escenas (.tscn); la principal es scenes/node_2d.tscn
- scripts/ lógica (.gd), un script por responsabilidad, agrupados por carpeta:
  - node_2d.gd: script del nodo raíz; cambia de pantalla y conecta señales
  - core/ datos y progreso (SaveData, VenueCatalog)
  - online/ cuenta y nube (Auth, CloudSave, Firebase, HTTP)
  - art/ sprites en texto, SpriteFactory y decorados (fondo, portada)
  - ui/ piezas de interfaz comunes (UiDraw)
  - screens/ una por pantalla: login, mapa, niveles, resultado
  - levels/ jugabilidad: level.gd es la base (tiempo, puntos, marcador); service_level.gd, service_customer.gd, spot.gd y staff.gd son lo común de atender clientes (cola, sitios, quien atiende); una subcarpeta por tipo de escenario (tavern/, armory/, inn/)
- assets/sprites, assets/audio, assets/fonts (Pixelify Sans, licencia OFL en OFL.txt)
- data/ escenarios y niveles (venues.json) y config en JSON
- docs/ diseño (DISENO.md) y estado del proyecto (ESTADO.md)
- tools/ scripts de apoyo: generar assets y medir la dificultad de los niveles (balance_levels.gd)
- addons/ y plugins/ plugin de Google Sign-In (Godot y fuente Android)

## Reglas
- Comunicar nodos con señales, no con referencias cruzadas
- Datos en data/, no escritos dentro del código
- No editar .tscn a mano salvo cambios mínimos
- Arte: sprites de 16x16 dibujados como texto en scripts/art/sprite_data.gd, mostrados a escala x2; paleta fija de 16 colores en SpriteFactory.PALETTE; la letra X es el color de tinte
- Nunca subir keystores ni contraseñas al repositorio
- scripts/node_2d.gd es el script del nodo raíz de la escena principal; no adjuntar otro script a ese nodo
- El progreso se guarda en user://save.json (clase SaveData); es el dato que más adelante se sincronizará con la cuenta de Google
- Un tipo de escenario nuevo = subclase de ServiceLevel (o de Level si no es de atender clientes) en scripts/levels/<tipo>/, registrada en gameplays de node_2d.gd y con "gameplay" en data/venues.json
- Textos: fuente Pixelify Sans (se asigna a ThemeDB.fallback_font al arrancar); usar solo los tamaños de UiDraw (TINY, SMALL, MEDIUM, LARGE, HUGE), porque otros se ven borrosos

# Estado
## Hecho
- Godot 4.7.2 exportando a Samsung
- Repositorio en GitHub (vara-17/MedievalDash)
- Ambientación: edad media (tabernas, armerías...)
- Cola de espera, elegir mesa, camarero, barra con cola, niveles en JSON, menú y progreso local
- Sprites en texto 16x16 (x2): tabernero, cliente, mesa, jarra, casa, árbol, espada, escudo, casco, yunque, herrero, suelo de piedra
- Pantallas: inicio (login) > mapa de escenarios > niveles del escenario > nivel > resultado
- Fuente pixel art Pixelify Sans
- Interfaz de madera y pergamino (UiDraw): marcador con monedas, barra hacia las estrellas y reloj; estrellas, candado, puerta, barra y barril con sprite
- Código ordenado por carpetas (core, online, art, ui, screens, levels); taberna y armería sobre una base común (ServiceLevel, ServiceCustomer, Spot, Staff)
- Escenarios en data/venues.json (taberna y armería jugables, 3 niveles cada una); progreso guardado por escenario
## Siguiente
- Más variedad de clientes (humano, enano, elfo) y 2 frames de animación
- Ajustar dificultad y estrellas de la armería tras probarla
- Propinas por rapidez
## Bugs conocidos
- Ninguno

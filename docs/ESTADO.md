# Estado
## Hecho
- Godot 4.7.2 exportando a Samsung
- Repositorio en GitHub (vara-17/MedievalDash)
- Ambientación: edad media (tabernas, armerías...)
- Cola de espera, elegir mesa, camarero, barra con cola, niveles en JSON, menú y progreso local
- Sprites en texto 16x16 (x2): tabernero, cliente, mesa, jarra, casa, árbol, espada, escudo, casco, yunque, herrero, suelo de piedra
- Pantallas: inicio (login) > mapa de escenarios > niveles del escenario > nivel > resultado
- Fuente pixel art Pixelify Sans
- Pausa en el nivel, botón atrás de Android y pausa al pasar a segundo plano
- Interfaz de madera y pergamino (UiDraw): marcador con monedas, barra hacia las estrellas y reloj; estrellas, candado, puerta, barra y barril con sprite
- Código ordenado por carpetas (core, online, art, ui, screens, levels); taberna y armería sobre una base común (ServiceLevel, ServiceCustomer, Spot, Staff)
- Escenarios en data/venues.json (taberna, armería, posada y enfermería jugables, 7 niveles cada una de fácil a extremo); progreso guardado por escenario
## Siguiente
- Posada: niveles con grupos de 2 y camas dobles
- Más variedad de clientes (humano, enano, elfo) y 2 frames de animación
- Propinas por rapidez
## Bugs conocidos
- Ninguno

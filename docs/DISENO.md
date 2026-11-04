# Diseño
## Acciones en cola (como Diner Dash)
Cada toque añade una acción a una cola FIFO (máximo 6), con un marcador numerado en el suelo.
Al llegar a cada punto, si hay algo que hacer y se puede, lo hace; si no, pasa a la siguiente.
Si un cliente se va, se quitan las acciones que eran para él.
El botón "Cancelar" del marcador borra todas las acciones pendientes (y la selección de cliente): el personaje se
queda donde está y el siguiente toque vuelve a ser la acción 1. Lo que ya está haciendo en el sitio (hacer una cama) lo termina.
## Taberna: ciclo de un cliente
Llega > espera sitio > se sienta > pide > espera plato > come > paga > se va
## Armería: ciclo de un cliente
Llega > espera sitio > va al mostrador > pide comprar o reparar un objeto
- Comprar: el herrero coge el objeto del estante y se lo da > paga y se va
- Reparar: el herrero recoge el objeto roto > lo lleva al yunque > lo recoge arreglado > se lo devuelve > paga y se va
Precios de compra y reparación por objeto en data/venues.json
- El herrero lleva un objeto cada vez. Si necesita las manos libres (recoger un objeto roto o un arreglo) y lleva uno nuevo del estante, lo devuelve solo; el de un cliente no lo suelta
- Ir al yunque con un objeto nuevo del estante lo desecha siempre
## Posada: ciclo de un huésped
Llega > espera cama > se acuesta > duerme ("sleep_time", sin perder paciencia) > se despierta y deja la cama deshecha > paga y se va > el posadero hace la cama ("make_time", se queda quieto con una barra)
- Una cama deshecha no admite a nadie hasta que se hace
- Tocar una cama encola "cobrar si está despierto; si no hay nadie y está deshecha, hacerla" (dos toques seguidos = cobrar y hacer)
- Precio por persona: "price" del escenario
- Preparado para grupos: cada cliente puede traer "party" (1 o 2 personas) y cada cama tiene capacidad ("beds": [1, 2, ...]; 1 individual, 2 doble). Un grupo cabe en una cama de su capacidad o mayor; paga por persona. De momento todos los niveles son individuales
## Enfermería: cola con mostrador
La cola acaba en un mostrador y solo se atiende al primero (el que está en el mostrador); los demás esperan.
Al llegar al mostrador su paciencia pasa a "desk_patience".
- Comprar: la curandera coge la medicina del estante y la entrega en el mostrador > paga ("buy") y se va
- Curarse ("treat": true): se le lleva a una camilla libre > tumbado espera su medicina ("stretcher_patience") > se le da > se recupera ("recover_time", sin perder paciencia) > se levanta > paga ("treat") y se va
- Si el del mostrador viene a curarse y no hay camilla libre, bloquea la cola
- La curandera lleva una medicina cada vez; al coger otra deja la que llevaba
- Los estantes son las medicinas que pide algún cliente del nivel
## Niveles fijos
Cada nivel tiene su lista de clientes en data/venues.json ("customers"): cuándo llega cada uno ("at", segundos)
y, en la armería, qué objeto ("item") y si es reparación ("repair"). Siempre salen igual, en el mismo orden.
Si la cola está llena, el siguiente espera en la puerta. El nivel acaba al irse el último cliente o al agotarse el tiempo.
Los estantes de la armería son los objetos que algún cliente viene a comprar.
## Dificultad de los niveles
7 niveles por zona: 1-3 fáciles, 4-5 normales, 6 difícil y 7 extremo ("difficulty" en cada nivel).
Jugando perfecto (bot sin tiempo de reacción) debe sobrar este tiempo, y el nivel durar:

| Dificultad | Sobra | Duración |
|---|---|---|
| easy (Fácil) | 25% | 1-2 min |
| medium (Normal) | 15% | 1-3 min |
| hard (Difícil) | 10% | 2-4 min |
| extreme (Extremo) | 5% | 3-5 min |

Estrellas sobre las monedas posibles: 1 = 40%, 2 = 65%, 3 = 85% (fácil), 88% (normal), 92% (difícil), 95% (extremo).
Paciencia más baja y llegadas más seguidas cuanto más difícil; los niveles difíciles usan más sitios (4 mesas, 4 mostradores...).
tools/balance_levels.gd mide todos los niveles (con --open, sin límite de tiempo, da cuánto tarda el perfecto; el tiempo
del nivel es eso / (1 - sobra)). Los fáciles también deberían dar 3 estrellas al jugador lento (0,9 s de reacción).
## Pausa y botón atrás
- En el nivel, el botón "Pausa" congela todo (tiempo, clientes, personaje) y abre Continuar / Repetir / Salir
- Botón atrás de Android (Escape en el ordenador): pantalla anterior; en el nivel abre la pausa y en la pausa sigue; en el inicio y el mapa sale del juego
- Si la app pasa a segundo plano (llamada, botón de inicio, pantalla apagada) el nivel se pausa
## Desbloqueo de zonas
Las zonas se abren en el orden de data/venues.json. Cada una pide un 75% de la suma de estrellas de todas las anteriores
(VenueCatalog.UNLOCK_RATIO). El mapa muestra arriba las estrellas totales y en cada zona cerrada cuántas hacen falta.
Dentro de una zona, cada nivel se abre con al menos 1 estrella en el anterior.
## Pendiente de definir
- Paciencia, precios, tiempos, propinas, combos
- Objetivos de nivel y progresión

# Diseño
## Acciones en cola (como Diner Dash)
Cada toque añade una acción a una cola FIFO (máximo 6), con un marcador numerado en el suelo.
Al llegar a cada punto, si hay algo que hacer y se puede, lo hace; si no, pasa a la siguiente.
Si un cliente se va, se quitan las acciones que eran para él.
## Taberna: ciclo de un cliente
Llega > espera sitio > se sienta > pide > espera plato > come > paga > se va
## Armería: ciclo de un cliente
Llega > espera sitio > va al mostrador > pide comprar o reparar un objeto
- Comprar: el herrero coge el objeto del estante y se lo da > paga y se va
- Reparar: el herrero recoge el objeto roto > lo lleva al yunque > lo recoge arreglado > se lo devuelve > paga y se va
Precios de compra y reparación por objeto en data/venues.json
- El herrero lleva un objeto cada vez. Si necesita las manos libres (recoger un objeto roto o un arreglo) y lleva uno nuevo del estante, lo devuelve solo; el de un cliente no lo suelta
- Ir al yunque con un objeto nuevo del estante lo desecha siempre
## Niveles fijos
Cada nivel tiene su lista de clientes en data/venues.json ("customers"): cuándo llega cada uno ("at", segundos)
y, en la armería, qué objeto ("item") y si es reparación ("repair"). Siempre salen igual, en el mismo orden.
Si la cola está llena, el siguiente espera en la puerta. El nivel acaba al irse el último cliente o al agotarse el tiempo.
Los estantes de la armería son los objetos que algún cliente viene a comprar.
Dificultad: tools/balance_levels.gd juega todos los niveles; los 3 primeros de cada zona deben dar 3 estrellas
al jugador lento. Las 3 estrellas piden ~85% de las monedas posibles (se puede perder un cliente).
## Pendiente de definir
- Paciencia, precios, tiempos, propinas, combos
- Objetivos de nivel y progresión

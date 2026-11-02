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
## Pendiente de definir
- Paciencia, precios, tiempos, propinas, combos
- Objetivos de nivel y progresión

class_name Spot
extends Node2D

# Sitio donde se atiende a un cliente: mesa en la taberna, mostrador en la
# armería, cama en la posada... Tiene un hueco para el cliente y otro para quien
# le atiende. "capacity" es cuántas personas caben (un grupo de 2 necesita 2).

const TAP_MARGIN := Vector2(12, 12)

var size: Vector2 = Vector2(32, 32)
var customer: ServiceCustomer = null
var capacity: int = 1


# Si se puede llevar aquí al cliente "c" (cola): libre y con sitio para su grupo.
func accepts(c: ServiceCustomer) -> bool:
	return customer == null and c.party <= capacity


# Zona que responde al toque, algo mayor que el dibujo.
func tap_rect() -> Rect2:
	return Rect2(position - size / 2.0 - TAP_MARGIN, size + TAP_MARGIN * 2.0)


func customer_position() -> Vector2:
	return position


func staff_position() -> Vector2:
	return position

class_name Spot
extends Node2D

# Sitio donde se atiende a un cliente: mesa en la taberna, mostrador en la
# armería... Tiene un hueco para el cliente y otro para quien le atiende.

const TAP_MARGIN := Vector2(12, 12)

var size: Vector2 = Vector2(32, 32)
var customer: ServiceCustomer = null


# Zona que responde al toque, algo mayor que el dibujo.
func tap_rect() -> Rect2:
	return Rect2(position - size / 2.0 - TAP_MARGIN, size + TAP_MARGIN * 2.0)


func customer_position() -> Vector2:
	return position


func staff_position() -> Vector2:
	return position

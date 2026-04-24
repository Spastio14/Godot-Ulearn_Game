extends Area2D

var energizado: bool = false
var salidas: Array[Callable] = []

func _ready():
	input_pickable = true
	actualizar_visual()
	await get_tree().process_frame
	propagar()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		set_energia(!energizado)

func set_energia(valor: bool):
	if energizado == valor:
		return

	energizado = valor
	actualizar_visual()
	propagar()

func propagar():
	for salida in salidas:
		salida.call(energizado)

func actualizar_visual():
	if energizado:
		$Sprite2D.modulate = Color.GREEN
	else:
		$Sprite2D.modulate = Color.RED

extends Area2D

@export var textura_encendido: Texture2D
@export var textura_apagado: Texture2D

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
		if textura_encendido:
			$Sprite2D.texture = textura_encendido
			$Sprite2D.modulate = Color.WHITE # Restaurar color original si usa sprite
		else:
			$Sprite2D.modulate = Color.GREEN # Fallback al color si no hay sprite
	else:
		if textura_apagado:
			$Sprite2D.texture = textura_apagado
			$Sprite2D.modulate = Color.WHITE # Restaurar color original si usa sprite
		else:
			$Sprite2D.modulate = Color.RED # Fallback al color si no hay sprite

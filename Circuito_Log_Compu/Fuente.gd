extends "res://Circuito_Log_Compu/CircuitNode.gd"

@export var textura_encendido: Texture2D
@export var textura_apagado: Texture2D

func _ready():
	$Sprite2D.modulate = Color.RED

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		set_energia(!energizado)

func actualizar_visual():
	if energizado:
		if textura_encendido:
			$Fuente.texture = textura_encendido
			$Fuente.modulate = Color.WHITE
		else:
			$Fuente.modulate = Color.GREEN
	else:
		if textura_apagado:
			$Fuente.texture = textura_apagado
			$Fuente.modulate = Color.WHITE
		else:
			$Fuente.modulate = Color.RED

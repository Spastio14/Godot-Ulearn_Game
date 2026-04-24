extends "res://Circuito_Log_Compu/CircuitNode.gd"

func _ready():
	$Sprite2D.modulate = Color.RED

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		set_energia(!energizado)

func actualizar_visual():
	if energizado:
		$Fuente.modulate = Color.GREEN
	else:
		$Fuente.modulate = Color.RED

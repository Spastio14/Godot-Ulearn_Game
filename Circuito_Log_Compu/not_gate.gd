extends "res://Circuito_Log_Compu/CircuitNode.gd"

func _ready():
	actualizar_visual()

func recibir_energia(valor: bool):
	set_energia(!valor)

func actualizar_visual():
	if energizado:
		$Sprite2D.modulate = Color.GREEN
	else:
		$Sprite2D.modulate = Color.RED

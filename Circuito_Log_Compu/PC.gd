extends "res://Circuito_Log_Compu/CircuitNode.gd"

signal nivel_completado

func _ready():
	actualizar_visual()

func recibir_energia(valor: bool):
	set_energia(valor)

	if energizado:
		nivel_completado.emit()

func actualizar_visual():
	if energizado:
		$Sprite2D.modulate = Color.CYAN
	else:
		$Sprite2D.modulate = Color.DARK_GRAY

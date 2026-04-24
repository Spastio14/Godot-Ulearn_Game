extends "res://Circuito_Log_Compu/CircuitNode.gd"

var entrada1: bool = false
var entrada2: bool = false

func _ready():
	actualizar_visual()

func recibir_energia_1(valor: bool):
	entrada1 = valor
	calcular()

func recibir_energia_2(valor: bool):
	entrada2 = valor
	calcular()

func calcular():
	var resultado = entrada1 and entrada2
	set_energia(resultado)

func actualizar_visual():
	if energizado:
		$Sprite2D.modulate = Color.GREEN
	else:
		$Sprite2D.modulate = Color.RED

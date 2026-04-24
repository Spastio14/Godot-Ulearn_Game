extends Node2D

var energizado: bool = false
var salidas: Array[Callable] = []

func set_energia(valor: bool):
	if energizado == valor:
		return

	energizado = valor
	actualizar_visual()
	propagar()

func propagar():
	for salida in salidas:
		salida.call(energizado)

func recibir_energia(valor: bool):
	set_energia(valor)

func actualizar_visual():
	pass

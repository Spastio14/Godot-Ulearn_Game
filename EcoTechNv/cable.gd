extends Node2D

@onready var line = $Line2D

var port_a: Area2D
var port_b: Area2D

func configurar(a, b):
	port_a = a
	port_b = b

	a.registrar_conexion(self)
	b.registrar_conexion(self)

	actualizar()

func actualizar():
	if port_a and port_b:
		line.points = [
			port_a.global_position,
			port_b.global_position
		]

func _process(delta):
	actualizar()

extends Node2D

@onready var b1 = $Fuent1
@onready var b2 = $Fuent2
@onready var b3 = $Fuent3

@onready var or_gate = $OR_Gate
@onready var not_gate = $NOT_Gate
@onready var and_gate = $AND_Gate

@onready var computadora = $PC

func _ready():

	# B1 y B2 → OR
	b1.salidas.append(Callable(or_gate, "recibir_energia_1"))
	b2.salidas.append(Callable(or_gate, "recibir_energia_2"))

	# OR → AND (entrada1)
	or_gate.salidas.append(Callable(and_gate, "recibir_energia_1"))

	# B3 → NOT
	b3.salidas.append(Callable(not_gate, "recibir_energia"))

	# NOT → AND (entrada2)
	not_gate.salidas.append(Callable(and_gate, "recibir_energia_2"))

	# AND → Computadora
	and_gate.salidas.append(Callable(computadora, "recibir_energia"))

	# victoria
	computadora.nivel_completado.connect(_on_win)

func _on_win():
	print("Nivel completado")
	await get_tree().create_timer(0.5).timeout
	call_deferred("_next")


func _next():
	get_tree().change_scene_to_file("res://Circuito_Log_Compu/circuit_nv_6.tscn")

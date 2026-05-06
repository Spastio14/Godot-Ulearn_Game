extends Node2D

@onready var fuente1 = $Fuent1
@onready var fuente2 = $Fuent2
@onready var and_gate = $AND_Gate
@onready var computadora = $PC

func _ready():

	# conectar entradas del AND
	fuente1.salidas.append(Callable(and_gate, "recibir_energia_1"))
	fuente2.salidas.append(Callable(and_gate, "recibir_energia_2"))

	# salida del AND a computadora
	and_gate.salidas.append(Callable(computadora, "recibir_energia"))

	# detectar victoria
	computadora.nivel_completado.connect(_on_win)


func _on_win():
	print("Nivel completado")
	await get_tree().create_timer(0.5).timeout
	GameManager.nivel_actual += 1
	GameManager.guardar_progreso()
	call_deferred("_cargar_siguiente")


func _cargar_siguiente():
	get_tree().change_scene_to_file("res://Circuito_Log_Compu/Circuit_nv_5.tscn")

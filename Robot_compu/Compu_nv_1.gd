extends Node2D
var instrucciones = []

@onready var robot = $Robot_player
@onready var meta = $Meta

func _ready():
	meta.nivel_completado.connect(cargar_siguiente_nivel)

func cargar_siguiente_nivel():
	await get_tree().create_timer(0.5).timeout
	GameManager.nivel_actual += 1
	GameManager.guardar_progreso()
	call_deferred("_cambiar_nivel")
	print("Cargando siguiente nivel")
	

func _cambiar_nivel():
	get_tree().change_scene_to_file("res://Robot_compu/Compu_nv_2.tscn")

func _agregar_instruccion(inst):
	instrucciones.append(inst)

func _ejecutar():
	robot.ejecutar_instrucciones(instrucciones)
	instrucciones.clear()

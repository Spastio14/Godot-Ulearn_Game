extends Node2D
var instrucciones = []

@onready var robot = $Robot_player
@onready var meta = $Meta
@onready var llave = $Llave
@onready var bloque = $BloqueCerrado

func _ready():
	meta.visible = false
	meta.monitoring = false
	
	llave.llave_recogida.connect(_desbloquear_meta)
	meta.nivel_completado.connect(_completar_nivel)

func _desbloquear_meta():

	print("Meta desbloqueada")

	# eliminar el bloque que simula el cierre
	bloque.queue_free()

	# activar la meta
	meta.visible = true
	meta.monitoring = true


func _completar_nivel():
	await get_tree().create_timer(0.5).timeout
	GameManager.nivel_actual += 1
	GameManager.guardar_progreso()
	call_deferred("_cambiar_nivel")

func agregar_instruccion(inst):
	instrucciones.append(inst)

func ejecutar():
	robot.ejecutar_instrucciones(instrucciones)
	instrucciones.clear()

func _cambiar_nivel():
	get_tree().change_scene_to_file("res://Circuito_Log_Compu/Circuit_nv_5.tscn")

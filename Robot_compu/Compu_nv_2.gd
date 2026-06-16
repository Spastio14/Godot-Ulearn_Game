extends Node2D
var instrucciones = []

@export var dialogo_intro: Resource
@export var titulo_dialogo_intro: String = "robot_nivel_2"

@onready var robot = $Robot_player
@onready var meta = $Meta

func _ready():
	LevelDialogueIntro.mostrar(self, dialogo_intro, titulo_dialogo_intro)
	print("Nivel iniciado")
	meta.nivel_completado.connect(cargar_siguiente_nivel)

func cargar_siguiente_nivel():
	await get_tree().create_timer(0.5).timeout
	await GameManager.completar_nivel()
	print("Nivel completado")

func agregar_instruccion(inst):
	instrucciones.append(inst)

func ejecutar():
	robot.ejecutar_instrucciones(instrucciones)
	instrucciones.clear()

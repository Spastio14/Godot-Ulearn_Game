extends Node2D

@export var dialogo_intro: Resource
@export var titulo_dialogo_intro: String = "circuito_nivel_6"

@onready var b1 = $Fuent1
@onready var b2 = $Fuent2
@onready var b3 = $Fuent3
@onready var b4 = $Fuent4

@onready var not1 = $NOT_Gate1
@onready var not2 = $NOT_Gate2
@onready var not3 = $NOT_Gate3

@onready var or1 = $OR_Gate1

@onready var and1 = $AND_Gate1
@onready var and2 = $AND_Gate2

@onready var comp = $PC

func _ready():
	LevelDialogueIntro.mostrar(self, dialogo_intro, titulo_dialogo_intro)
	
	#Fuente1 -> not1
	b1.salidas.append(Callable(not1, "recibir_energia"))
	#Funete3 -> not2
	b3.salidas.append(Callable(not2, "recibir_energia"))
	#Fuente4 -> not3
	b4.salidas.append(Callable(not3, "recibir_energia"))
	
	#not1 y not2 -> or1
	not1.salidas.append(Callable(or1, "recibir_energia_1"))
	not2.salidas.append(Callable(or1, "recibir_energia_2"))
	#Fuente2 y not3 -> and2
	b2.salidas.append(Callable(and2, "recibir_energia_1"))
	not3.salidas.append(Callable(and2, "recibir_energia_2"))
	
	#or1 y or2 -> and1
	or1.salidas.append(Callable(and1, "recibir_energia_1"))
	and2.salidas.append(Callable(and1, "recibir_energia_2"))
	
	#and1 -> PC
	and1.salidas.append(Callable(comp, "recibir_energia"))
	comp.nivel_completado.connect(_on_win)

func _on_win():
	print("Nivel completado")
	await get_tree().create_timer(0.5).timeout
	GameManager.nivel_actual += 1
	GameManager.guardar_progreso()
	call_deferred("_next")


func _next():
	get_tree().change_scene_to_file("res://BaseDatosNv/BD_nv_7.tscn")

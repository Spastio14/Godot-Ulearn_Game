extends Node2D

@export var tipo: String = "pc" # pc, router, server
@export var max_conexiones_nodo: int = 1

@onready var puertos = []
var cables_conectados: Array = []

func _ready():
	for child in get_children():
		if child is Area2D:
			puertos.append(child)

func puede_conectar() -> bool:
	return cables_conectados.size() < max_conexiones_nodo

func registrar_conexion(cable):
	cables_conectados.append(cable)

func remover_conexion(cable):
	cables_conectados.erase(cable)

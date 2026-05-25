extends Node2D

@export var tipo: String = "pc" # pc, router, server, firewall
@export var max_conexiones_nodo: int = 1
@export var network_id: String = "A"
@export var allowed_network_ids: PackedStringArray = ["A", "B", "C"]
@export var latency_cost: int = 0
@export var authorized: bool = true
@export var server_capacity: int = 99

@onready var puertos: Array = []
var cables_conectados: Array = []

func _ready() -> void:
	for child in get_children():
		if child is Area2D:
			puertos.append(child)

func puede_conectar() -> bool:
	return cables_conectados.size() < max_conexiones_nodo

func registrar_conexion(cable: Node) -> void:
	cables_conectados.append(cable)

func remover_conexion(cable: Node) -> void:
	cables_conectados.erase(cable)

func permite_segmento(other: Node2D) -> bool:
	if tipo == "router" or other.tipo == "router":
		return true
	return network_id == other.network_id

func permite_acceso_a(other: Node2D) -> bool:
	if tipo == "firewall":
		return other.network_id in allowed_network_ids
	if other.tipo == "firewall":
		return network_id in other.allowed_network_ids
	return true

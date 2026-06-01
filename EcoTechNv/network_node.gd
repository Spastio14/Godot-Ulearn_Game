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

	_crear_label_info()

func _crear_label_info() -> void:
	var info_label = Label.new()
	info_label.name = "InfoLabel"
	add_child(info_label)

	var text_parts: Array[String] = []
	text_parts.append("%s (%s)" % [name, _tipo_visible()])

	if _muestra_red():
		text_parts.append("Red: %s" % network_id)

	if tipo == "router":
		text_parts.append("Conexiones: %d" % max_conexiones_nodo)
	elif tipo == "server":
		text_parts.append("Puertos: %d" % max_conexiones_nodo)
		if server_capacity < 99:
			text_parts.append("Capacidad: %d PC" % server_capacity)
	elif tipo == "pc":
		text_parts.append("Puertos: %d" % max_conexiones_nodo)

	if latency_cost > 0:
		text_parts.append("Latencia: +%d" % latency_cost)

	if not authorized:
		text_parts.append("No autorizado")
		info_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))

	if tipo == "firewall":
		text_parts.append("Permite: %s" % _unir_textos(allowed_network_ids, ", "))

	info_label.text = _unir_textos(text_parts, "\n")
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	info_label.position = Vector2(-115, 34)
	info_label.size = Vector2(230, 56)
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	info_label.add_theme_font_size_override("font_size", 11)
	info_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	info_label.add_theme_constant_override("outline_size", 3)

func _tipo_visible() -> String:
	if tipo == "pc":
		return "PC"
	if tipo == "router":
		return "Router"
	if tipo == "server":
		return "Servidor"
	if tipo == "firewall":
		return "Firewall"
	return tipo.capitalize()

func _muestra_red() -> bool:
	return tipo == "pc" or tipo == "server" or tipo == "firewall"

func _unir_textos(partes, separador: String) -> String:
	var resultado := ""
	for i in range(partes.size()):
		if i > 0:
			resultado += separador
		resultado += str(partes[i])
	return resultado

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

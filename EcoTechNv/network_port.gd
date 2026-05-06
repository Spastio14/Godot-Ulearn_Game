extends Area2D

@export var node_owner: Node2D
@export var port_id: String = ""

func _ready():
	input_pickable = true

func puede_conectar() -> bool:
	if node_owner and node_owner.has_method("puede_conectar"):
		return node_owner.puede_conectar()
	return false

func registrar_conexion(cable):
	if node_owner and node_owner.has_method("registrar_conexion"):
		node_owner.registrar_conexion(cable)

func remover_conexion(cable):
	if node_owner and node_owner.has_method("remover_conexion"):
		node_owner.remover_conexion(cable)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			get_tree().get_first_node_in_group("network_manager").seleccionar_puerto(self)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			get_tree().get_first_node_in_group("network_manager").eliminar_conexiones_de_puerto(self)

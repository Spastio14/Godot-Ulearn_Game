extends Node
class_name LevelDialogueIntro

const DEFAULT_DIALOGUE_PATH := "res://Dialogos/introducciones_niveles.dialogue"
const DEFAULT_TITLE := "plantilla"

static func mostrar(level_node: Node, dialogo_intro: Resource = null, titulo_dialogo: String = "", extra_game_states: Array = [], pausar_juego: bool = true) -> Node:
	var resource := dialogo_intro
	if resource == null:
		resource = load(DEFAULT_DIALOGUE_PATH)

	if resource == null:
		push_warning("No se pudo cargar el recurso de diálogo: %s" % DEFAULT_DIALOGUE_PATH)
		return null

	var title := titulo_dialogo.strip_edges()
	if title.is_empty():
		title = _crear_titulo_desde_escena(level_node)
	if title.is_empty():
		title = DEFAULT_TITLE

	var balloon := DialogueManager.show_dialogue_balloon(resource, title, extra_game_states)
	if pausar_juego and level_node != null:
		_pausar_hasta_fin_del_dialogo(level_node, resource, balloon)
	return balloon

static func _pausar_hasta_fin_del_dialogo(level_node: Node, _resource: Resource, balloon: Node) -> void:
	balloon.process_mode = Node.PROCESS_MODE_ALWAYS
	var tree := level_node.get_tree()
	tree.paused = true

	var al_finalizar_dialogo := func(_ended_resource: Resource) -> void:
		tree.paused = false

	DialogueManager.dialogue_ended.connect(al_finalizar_dialogo, CONNECT_ONE_SHOT)

static func _crear_titulo_desde_escena(level_node: Node) -> String:
	if level_node == null:
		return ""

	var scene_path := level_node.scene_file_path
	if scene_path.is_empty() and level_node.owner != null:
		scene_path = level_node.owner.scene_file_path
	if scene_path.is_empty():
		return ""

	return scene_path.get_file().get_basename().to_snake_case()

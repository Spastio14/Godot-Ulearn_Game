extends Node2D

signal connection_refused(reason: String)
signal network_state_changed(valid: bool, message: String)

enum LevelMode {
	BASIC,
	ROUTER_SATURATION,
	NETWORK_SEGMENTATION,
	REDUNDANT_INFRASTRUCTURE,
	INFRASTRUCTURE_OPTIMIZATION,
	NETWORK_LATENCY,
	FIREWALL_SECURITY,
	DISTRIBUTED_SERVERS,
	NETWORK_TOPOLOGIES
}

@export var max_cables: int = 5
@export var level_mode: LevelMode = LevelMode.BASIC
@export var optimize_target_cables: int = 0
@export var latency_threshold: int = 20
@export var required_topology: String = "star" # star, ring, bus

var cable_scene = preload("res://EcoTechNv/cable.tscn")
var conexiones: Array[Dictionary] = []
var seleccion_actual: Area2D = null

var label_cables: Label
var label_sugerencia: Label
var btn_reiniciar: Button
var label_estado: Label

@export var dialogo_intro: Resource
@export var titulo_dialogo_intro: String = "redes_nivel_4_1"

var cable_fantasma: Line2D

func _ready() -> void:
	var ui_node = get_node_or_null("UI")
	if ui_node == null:
		var ui_scene = load("res://EcoTechNv/network_ui.tscn")
		if ui_scene:
			ui_node = ui_scene.instantiate()
			ui_node.name = "UI"
			add_child(ui_node)
	
	if ui_node:
		label_cables = ui_node.get_node_or_null("LabelCables")
		label_sugerencia = ui_node.get_node_or_null("LabelSugerencia")
		btn_reiniciar = ui_node.get_node_or_null("BtnReiniciar")
		label_estado = ui_node.get_node_or_null("LabelEstado")

	actualizar_ui()
	LevelDialogueIntro.mostrar(self, dialogo_intro, titulo_dialogo_intro)
	if btn_reiniciar and not btn_reiniciar.pressed.is_connected(_on_btn_reiniciar_pressed):
		btn_reiniciar.pressed.connect(_on_btn_reiniciar_pressed)
	cable_fantasma = Line2D.new()
	cable_fantasma.width = 4.0
	cable_fantasma.default_color = Color(1, 1, 1, 0.5)
	add_child(cable_fantasma)
	cable_fantasma.visible = false

func _process(_delta: float) -> void:
	if seleccion_actual != null:
		cable_fantasma.visible = true
		cable_fantasma.points = [seleccion_actual.global_position, get_global_mouse_position()]
	else:
		cable_fantasma.visible = false

func _on_btn_reiniciar_pressed() -> void:
	get_tree().reload_current_scene()

func seleccionar_puerto(port: Area2D) -> void:
	if not port.puede_conectar():
		emit_connection_refusal("Puerto o nodo sin capacidad disponible.")
		return
	if seleccion_actual == null:
		seleccion_actual = port
		return
	if seleccion_actual == port:
		seleccion_actual = null
		return
	crear_conexion(seleccion_actual, port)
	seleccion_actual = null

func crear_conexion(a: Area2D, b: Area2D) -> void:
	if conexiones.size() >= max_cables:
		emit_connection_refusal("Límite de cables alcanzado")
		return
	if not _conexion_permitida(a.node_owner, b.node_owner):
		return
	var cable = cable_scene.instantiate()
	add_child(cable)
	cable.configurar(a, b)
	conexiones.append({"a": a, "b": b, "cable": cable, "active": true})
	actualizar_ui()
	validar_red()

func _conexion_permitida(a_node, b_node) -> bool:
	if level_mode == LevelMode.NETWORK_SEGMENTATION:
		if not a_node.permite_segmento(b_node) or not b_node.permite_segmento(a_node):
			emit_connection_refusal("Conexión entre segmentos no permitida.")
			return false
	if level_mode == LevelMode.FIREWALL_SECURITY:
		if not a_node.permite_acceso_a(b_node) or not b_node.permite_acceso_a(a_node):
			emit_connection_refusal("Firewall bloqueó una conexión no autorizada.")
			return false
	return true

func actualizar_ui() -> void:
	if label_cables:
		label_cables.text = "Cables: %d / %d" % [conexiones.size(), max_cables]
	if label_estado:
		label_estado.text = _estado_nodos()

func _estado_nodos() -> String:
	var parts: Array[String] = []
	for n in obtener_nodos():
		if n.tipo == "router" or n.tipo == "server":
			parts.append("%s %d/%d" % [n.name, n.cables_conectados.size(), n.max_conexiones_nodo])
	return " | ".join(parts)

func emit_connection_refusal(reason: String) -> void:
	if label_sugerencia:
		label_sugerencia.text = "Advertencia: " + reason
	emit_signal("connection_refused", reason)

func eliminar_conexiones_de_puerto(port: Area2D) -> void:
	if seleccion_actual == port:
		seleccion_actual = null
		return
	var conexiones_a_eliminar: Array[Dictionary] = []
	for c in conexiones:
		if c["a"] == port or c["b"] == port:
			conexiones_a_eliminar.append(c)
	for c in conexiones_a_eliminar:
		c["a"].node_owner.remover_conexion(c["cable"])
		c["b"].node_owner.remover_conexion(c["cable"])
		if is_instance_valid(c["cable"]):
			c["cable"].queue_free()
		conexiones.erase(c)
	if conexiones_a_eliminar.size() > 0:
		actualizar_ui()
		validar_red()

func validar_red() -> void:
	var nodos = obtener_nodos()
	var servers = _obtener_por_tipo(nodos, "server")
	var pcs = _obtener_por_tipo(nodos, "pc")
	if servers.is_empty() or pcs.is_empty():
		return
	for pc in pcs:
		# En modo Firewall, los PCs no autorizados no deben recibir servicio
		if level_mode == LevelMode.FIREWALL_SECURITY and not pc.authorized:
			continue
		var conectado := false
		for server in servers:
			if hay_camino(pc, server):
				conectado = true
				break
		if not conectado:
			emit_signal("network_state_changed", false, "Todavía hay equipos sin servicio.")
			return
	var extra_check := _validaciones_avanzadas(pcs, servers, nodos)
	if not extra_check["ok"]:
		emit_signal("network_state_changed", false, extra_check["message"])
		if label_sugerencia:
			label_sugerencia.text = extra_check["message"]
		return
	var msg: String = "¡VICTORIA! " + str(extra_check["message"])
	if label_sugerencia:
		label_sugerencia.text = msg
	emit_signal("network_state_changed", true, msg)
	await get_tree().create_timer(1.2).timeout
	GameManager.nivel_actual += 1
	GameManager.guardar_progreso()
	
	# Transición automática al siguiente nivel
	var current_scene_path = get_tree().current_scene.scene_file_path
	var next_scene_path = "res://Meu_UI/menu_ui.tscn"
	
	if "nivel_4_" in current_scene_path:
		var scene_name = current_scene_path.get_file().get_basename()
		var parts = scene_name.split("_")
		if parts.size() >= 4:
			var current_num = int(parts[2])
			var current_index = int(parts[3])
			
			var next_level_num = current_num + 1
			var next_level_index = current_index + 1
			
			var possible_next_path = "res://EcoTechNv/nivel_4_" + str(next_level_num) + "_" + str(next_level_index) + ".tscn"
			if ResourceLoader.exists(possible_next_path):
				next_scene_path = possible_next_path
	
	get_tree().change_scene_to_file(next_scene_path)

func _validaciones_avanzadas(pcs: Array, servers: Array, nodos: Array) -> Dictionary:
	match level_mode:
		LevelMode.ROUTER_SATURATION:
			for n in nodos:
				if n.tipo == "router" and n.cables_conectados.size() > n.max_conexiones_nodo:
					return {"ok": false, "message": "Router saturado."}
			return {"ok": true, "message": "Capacidad de routers respetada."}
		LevelMode.REDUNDANT_INFRASTRUCTURE:
			if not _validar_redundancia(pcs, servers):
				return {"ok": false, "message": "Falta ruta de respaldo ante fallos."}
			return {"ok": true, "message": "La infraestructura tolera un fallo de cable."}
		LevelMode.INFRASTRUCTURE_OPTIMIZATION:
			if optimize_target_cables > 0 and conexiones.size() > optimize_target_cables:
				return {"ok": false, "message": "Superaste el objetivo óptimo de cables."}
			return {"ok": true, "message": "Topología optimizada correctamente."}
		LevelMode.NETWORK_LATENCY:
			var total_latency := _calcular_latencia_total(pcs, servers)
			if total_latency > latency_threshold:
				return {"ok": false, "message": "Latencia total %d excede umbral %d." % [total_latency, latency_threshold]}
			return {"ok": true, "message": "Latencia total %d dentro del umbral." % total_latency}
		LevelMode.FIREWALL_SECURITY:
			if _hay_acceso_no_autorizado(pcs, servers):
				return {"ok": false, "message": "Acceso no autorizado detectado."}
			return {"ok": true, "message": "Políticas de seguridad cumplidas."}
		LevelMode.DISTRIBUTED_SERVERS:
			if not _validar_balanceo(servers):
				return {"ok": false, "message": "Balanceo/capacidad de servidores inválido."}
			return {"ok": true, "message": "Carga distribuida correctamente."}
		LevelMode.NETWORK_TOPOLOGIES:
			if not _validar_topologia(required_topology, nodos):
				return {"ok": false, "message": "No cumple topología requerida: %s." % required_topology}
			return {"ok": true, "message": "Topología %s válida." % required_topology}
		_:
			return {"ok": true, "message": "Red conectada."}

func obtener_nodos() -> Array:
	var resultado: Array = []
	for child in get_children():
		if "tipo" in child:
			resultado.append(child)
	return resultado

func _obtener_por_tipo(nodos: Array, tipo_buscado: String) -> Array:
	var r: Array = []
	for n in nodos:
		if n.tipo == tipo_buscado:
			r.append(n)
	return r

func hay_camino(origen: Node2D, destino: Node2D) -> bool:
	var visitados: Array = []
	var cola: Array = [origen]
	while cola.size() > 0:
		var actual = cola.pop_front()
		if actual == destino:
			return true
		if actual in visitados:
			continue
		visitados.append(actual)
		for vecino in obtener_vecinos(actual):
			cola.append(vecino)
	return false

func obtener_vecinos(nodo: Node2D) -> Array:
	var vecinos: Array = []
	for conexion in conexiones:
		if not conexion.get("active", true):
			continue
		var a = conexion["a"].node_owner
		var b = conexion["b"].node_owner
		if a == nodo:
			vecinos.append(b)
		if b == nodo:
			vecinos.append(a)
	return vecinos

func _validar_redundancia(pcs: Array, servers: Array) -> bool:
	for c in conexiones:
		c["active"] = false
		for pc in pcs:
			var conectado := false
			for s in servers:
				if hay_camino(pc, s):
					conectado = true
					break
			if not conectado:
				c["active"] = true
				return false
		c["active"] = true
	return true

func _calcular_latencia_total(pcs: Array, servers: Array) -> int:
	var total := 0
	for pc in pcs:
		var mejor := INF
		for s in servers:
			mejor = min(mejor, _dijkstra(pc, s))
		total += int(mejor)
	return total

func _dijkstra(origen: Node2D, destino: Node2D) -> float:
	var dist := {origen: 0.0}
	var pendientes: Array = [origen]
	while not pendientes.is_empty():
		pendientes.sort_custom(func(a, b): return dist.get(a, INF) < dist.get(b, INF))
		var actual = pendientes.pop_front()
		if actual == destino:
			return dist[actual]
		for vecino in obtener_vecinos(actual):
			var peso = 1.0 + float(actual.latency_cost) + float(vecino.latency_cost)
			var nueva = dist[actual] + peso
			if nueva < dist.get(vecino, INF):
				dist[vecino] = nueva
				if vecino not in pendientes:
					pendientes.append(vecino)
	return INF

func _hay_acceso_no_autorizado(pcs: Array, servers: Array) -> bool:
	for pc in pcs:
		if pc.authorized:
			continue
		for s in servers:
			if hay_camino(pc, s):
				return true
	return false

func _validar_balanceo(servers: Array) -> bool:
	for s in servers:
		var carga := 0
		for c in conexiones:
			var a = c["a"].node_owner
			var b = c["b"].node_owner
			if (a.tipo == "pc" and b == s) or (b.tipo == "pc" and a == s):
				carga += 1
		if carga > s.server_capacity:
			return false
	return true

func _validar_topologia(objetivo: String, nodos: Array) -> bool:
	var grados: Array[int] = []
	for n in nodos:
		grados.append(obtener_vecinos(n).size())
	match objetivo:
		"star":
			return grados.count(1) >= 3 and grados.max() >= 3
		"ring":
			for g in grados:
				if g != 2:
					return false
			return true
		"bus":
			return grados.count(1) == 2 and grados.count(2) >= 1
		_:
			return false

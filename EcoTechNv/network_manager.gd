extends Node2D

@export var max_cables: int = 5

var cable_scene = preload("res://EcoTechNv/cable.tscn")

var conexiones = []
var seleccion_actual: Area2D = null

@onready var label_cables = $UI/LabelCables
@onready var label_sugerencia = $UI/LabelSugerencia
@onready var btn_reiniciar = $UI/BtnReiniciar

@export var dialogo_intro: Resource
@export var titulo_dialogo_intro: String = "redes_nivel_4_1"

var cable_fantasma: Line2D

func _ready():
	actualizar_ui()
	LevelDialogueIntro.mostrar(self, dialogo_intro, titulo_dialogo_intro)
	if btn_reiniciar:
		btn_reiniciar.pressed.connect(_on_btn_reiniciar_pressed)
		
	# Configurar cable fantasma para visualización en tiempo real
	cable_fantasma = Line2D.new()
	cable_fantasma.width = 4.0
	cable_fantasma.default_color = Color(1, 1, 1, 0.5) # Blanco semitransparente
	add_child(cable_fantasma)
	cable_fantasma.visible = false

func _process(delta):
	if seleccion_actual != null:
		cable_fantasma.visible = true
		cable_fantasma.points = [seleccion_actual.global_position, get_global_mouse_position()]
	else:
		cable_fantasma.visible = false

func _on_btn_reiniciar_pressed():
	get_tree().reload_current_scene()

func seleccionar_puerto(port):

	if not port.puede_conectar():
		return

	if seleccion_actual == null:
		seleccion_actual = port
		return

	if seleccion_actual == port:
		seleccion_actual = null
		return

	crear_conexion(seleccion_actual, port)
	seleccion_actual = null

func crear_conexion(a, b):

	if conexiones.size() >= max_cables:
		print("Límite de cables alcanzado")
		return

	var cable = cable_scene.instantiate()
	add_child(cable)

	cable.configurar(a, b)

	conexiones.append({
		"a": a,
		"b": b,
		"cable": cable
	})

	actualizar_ui()
	
	var tipo_a = a.node_owner.tipo
	var tipo_b = b.node_owner.tipo
	evaluar_sugerencia(tipo_a, tipo_b)
	
	validar_red()

func actualizar_ui():
	if label_cables:
		label_cables.text = "Cables: %d / %d" % [conexiones.size(), max_cables]

func evaluar_sugerencia(tipo_a: String, tipo_b: String):
	if label_sugerencia == null:
		return
		
	var sugerencia = ""
	
	if (tipo_a == "pc" and tipo_b == "server") or (tipo_b == "pc" and tipo_a == "server"):
		sugerencia = "Sugerencia: PC conectada directo al Servidor. Es correcto, pero consume muchos cables si hay varias PCs. Considera usar un Router."
	elif (tipo_a == "pc" and tipo_b == "pc"):
		sugerencia = "Sugerencia: PC a PC. Físicamente posible, pero recuerda que el objetivo del nivel es comunicar todas las PCs al Servidor."
	elif (tipo_a == "router" and tipo_b == "router"):
		sugerencia = "Sugerencia: Router a Router. Estás extendiendo la red troncal. Buena estrategia para alcanzar distancias largas."
	elif (tipo_a == "pc" and tipo_b == "router") or (tipo_b == "pc" and tipo_a == "router"):
		sugerencia = "Sugerencia: PC a Router. ¡Excelente! Así se agrupan las señales para ahorrar cables hacia el Servidor."
	elif (tipo_a == "router" and tipo_b == "server") or (tipo_b == "router" and tipo_a == "server"):
		sugerencia = "Sugerencia: Router a Servidor. Muy bien, el Router canalizará el tráfico de toda su red local hacia el Servidor."
	elif (tipo_a == tipo_b):
		sugerencia = "Sugerencia: Conectaste dos dispositivos del mismo tipo."
	else:
		sugerencia = "Sugerencia: Conexión establecida."

	label_sugerencia.text = sugerencia

func eliminar_conexiones_de_puerto(port):
	# Si estábamos arrastrando un cable desde aquí, lo cancelamos
	if seleccion_actual == port:
		seleccion_actual = null
		return
		
	var conexiones_a_eliminar = []
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
		if label_sugerencia:
			label_sugerencia.text = "Sugerencia: Conexiones eliminadas."
		# Al eliminar, la red ya no está completa, por lo que no validamos victoria aquí

# =========================
# VALIDACIÓN DE RED
# =========================

func validar_red():

	var nodos = obtener_nodos()
	var server = null
	var cantidad_pcs = 0

	for n in nodos:
		if n.tipo == "server":
			server = n
		elif n.tipo == "pc":
			cantidad_pcs += 1

	if server == null:
		return

	for n in nodos:
		if n.tipo == "pc":
			if not hay_camino(n, server):
				return

	print("Red completa")
	
	# Validación de Ruta Óptima
	var min_cables_posibles = cantidad_pcs # La forma más directa es cada PC directo al servidor
	if conexiones.size() == min_cables_posibles:
		label_sugerencia.text = "¡VICTORIA! Conexión Exitosa con RUTA ÓPTIMA (" + str(conexiones.size()) + " cables usados)."
	else:
		label_sugerencia.text = "¡VICTORIA! Red conectada, pero usaste " + str(conexiones.size()) + " cables. (La ruta más óptima usa " + str(min_cables_posibles) + ")."
	
	await get_tree().create_timer(1.5).timeout
	GameManager.nivel_actual += 1
	GameManager.guardar_progreso()
	#call_deferred("_cargar_siguiente")

func obtener_nodos():
	var resultado = []
	for child in get_children():
		if child.has_method("_ready") and "tipo" in child:
			resultado.append(child)
	return resultado

# BFS
func hay_camino(origen, destino):

	var visitados = []
	var cola = [origen]

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

func obtener_vecinos(nodo):

	var vecinos = []

	for conexion in conexiones:

		var a = conexion["a"].node_owner
		var b = conexion["b"].node_owner

		if a == nodo:
			vecinos.append(b)

		if b == nodo:
			vecinos.append(a)

	return vecinos

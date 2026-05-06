extends Control

# Referencias a los nodos principales (Ajusta las rutas si tu Scene Tree es diferente)
@onready var contenedor_datos = $ContenedorDatos
@onready var tabla_usuarios = $ContenedorTablas/TablaUsuarios
@onready var tabla_contacto = $ContenedorTablas/TablaContacto
@onready var btn_validar = $BtnValidar

# Variable para llevar el estado del nivel
var nivel_terminado = false

func _ready():
	# Borrar cualquier hijo que esté previamente en la escena (opcional, para evitar duplicados)
	for child in contenedor_datos.get_children():
		child.queue_free()
		
	# Hacemos que el contenedor principal también pueda recibir los items de vuelta
	var drop_script = GDScript.new()
	drop_script.source_code = """
extends Control
func _can_drop_data(_at_position, data):
	return typeof(data) == TYPE_DICTIONARY and data.has("nodo")
func _drop_data(_at_position, data):
	var nodo_origen = data["nodo"]
	if is_instance_valid(nodo_origen):
		var parent = nodo_origen.get_parent()
		if parent: parent.remove_child(nodo_origen)
		add_child(nodo_origen)
		if nodo_origen.has_node("Label"):
			nodo_origen.get_node("Label").add_theme_color_override("font_color", Color.WHITE)
"""
	drop_script.reload()
	contenedor_datos.set_script(drop_script)
	contenedor_datos.mouse_filter = Control.MOUSE_FILTER_PASS
		
	inicializar_datos()
	
	# Conectar el botón de validación si existe
	if btn_validar:
		btn_validar.pressed.connect(validar)

func inicializar_datos():
	# Generamos los datos dinámicamente y los barajamos
	var datos_a_crear = [
		{"texto": "Nombre", "tipo": "nombre"},
		{"texto": "Edad", "tipo": "edad"},
		{"texto": "Correo", "tipo": "correo"},
		{"texto": "Dirección", "tipo": "direccion"}
	]
	
	datos_a_crear.shuffle() # Desordenar para que el puzzle sea más dinámico
	
	for dato in datos_a_crear:
		crear_item(dato["texto"], dato["tipo"])

func crear_item(texto, tipo):
	# Cargar la escena de DatoArrastrable
	var item_scene = preload("res://BaseDatosNv/item_dato.tscn")
	var item = item_scene.instantiate()
	
	# Configurar el item antes de agregarlo al árbol
	item.tipo = tipo
	item.texto_mostrar = texto # El nodo en su _ready debería aplicar esto o lo hacemos aquí:
	
	# Agregarlo al contenedor en la interfaz
	contenedor_datos.add_child(item)
	
	# Forzar la actualización del label por si acaso
	if item.has_node("Label"):
		item.get_node("Label").text = texto

# =========================
# VALIDACIÓN DEL NIVEL
# =========================
func validar():
	if nivel_terminado: return
	
	# Llamamos a validar_tabla() que pintará de verde o rojo según sea correcto
	var error_usuarios = tabla_usuarios.validar_tabla()
	var error_contacto = tabla_contacto.validar_tabla()
	
	var hay_errores = error_usuarios or error_contacto
	
	var datos_usuarios = tabla_usuarios.get_datos_recibidos()
	var datos_contacto = tabla_contacto.get_datos_recibidos()
	
	# Comprobar que tengan los datos necesarios
	var usuarios_completo = ("nombre" in datos_usuarios and "edad" in datos_usuarios)
	var contacto_completo = ("correo" in datos_contacto and "direccion" in datos_contacto)
	
	# Si además hay elementos sueltos en el contenedor original, entonces no hemos terminado
	var faltan_datos = contenedor_datos.get_child_count() > 0
	
	# 3. Validar si todo es correcto
	if usuarios_completo and contacto_completo and not hay_errores and not faltan_datos:
		print("¡Nivel completado! Todos los datos están en sus tablas correspondientes.")
		nivel_terminado = true
		GameManager.completar_nivel()
		# Aquí podrías mostrar una pantalla de victoria
	else:
		if hay_errores:
			print("¡Incorrecto! Hay datos en las tablas equivocadas. Corrígelos.")
		elif faltan_datos:
			print("Aún faltan datos por clasificar.")
		else:
			print("Faltan datos en las tablas correctas.")

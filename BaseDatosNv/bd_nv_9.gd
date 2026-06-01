extends Control

@export var dialogo_intro: Resource
@export var titulo_dialogo_intro: String = "bd_nivel_9"

@export_category("Imágenes de Tablas")
@export var imagen_tabla_usuarios: Texture2D
@export var imagen_tabla_empleados: Texture2D

@onready var contenedor_datos = $FondoDatos/ScrollDatos/ContenedorDatos
@onready var tabla_usuarios_contenedor = $ContenedorTablas/TablaUsuariosContenedor
@onready var tabla_empleados_contenedor = $ContenedorTablas/TablaEmpleadosContenedor

# Columnas Tabla Usuarios
@onready var usr_nombre = $ContenedorTablas/TablaUsuariosContenedor/VBoxContainer/Columnas/TablaNombreUsr
@onready var usr_edad = $ContenedorTablas/TablaUsuariosContenedor/VBoxContainer/Columnas/TablaEdadUsr
@onready var usr_altura = $ContenedorTablas/TablaUsuariosContenedor/VBoxContainer/Columnas/TablaAlturaUsr

# Columnas Tabla Empleados
@onready var emp_nombre = $ContenedorTablas/TablaEmpleadosContenedor/VBoxContainer/Columnas/TablaNombreEmp
@onready var emp_cargo = $ContenedorTablas/TablaEmpleadosContenedor/VBoxContainer/Columnas/TablaCargoEmp
@onready var emp_salario = $ContenedorTablas/TablaEmpleadosContenedor/VBoxContainer/Columnas/TablaSalarioEmp

# Colores para identificar a qué tabla pertenecen
var color_usuarios = Color(0.3, 0.6, 1.0, 1.0) # Azul
var color_empleados = Color(1.0, 0.6, 0.3, 1.0) # Naranja

func _ready():
	LevelDialogueIntro.mostrar(self, dialogo_intro, titulo_dialogo_intro)
	
	# Aplicar imágenes personalizadas de fondo a las tablas si están seleccionadas
	if imagen_tabla_usuarios != null:
		var style_box = StyleBoxTexture.new()
		style_box.texture = imagen_tabla_usuarios
		style_box.texture_margin_left = 10
		style_box.texture_margin_top = 10
		style_box.texture_margin_right = 10
		style_box.texture_margin_bottom = 10
		tabla_usuarios_contenedor.add_theme_stylebox_override("panel", style_box)
		
	if imagen_tabla_empleados != null:
		var style_box = StyleBoxTexture.new()
		style_box.texture = imagen_tabla_empleados
		style_box.texture_margin_left = 10
		style_box.texture_margin_top = 10
		style_box.texture_margin_right = 10
		style_box.texture_margin_bottom = 10
		tabla_empleados_contenedor.add_theme_stylebox_override("panel", style_box)

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

func inicializar_datos():
	# Datos para Usuarios (Azul)
	crear_item("Roger", "usr_nombre", color_usuarios)
	crear_item("18", "usr_edad", color_usuarios)
	crear_item("1.75m", "usr_altura", color_usuarios)
	crear_item("María", "usr_nombre", color_usuarios)
	crear_item("22", "usr_edad", color_usuarios)
	
	# Datos para Empleados (Naranja)
	crear_item("Alice", "emp_nombre", color_empleados)
	crear_item("Gerente", "emp_cargo", color_empleados)
	crear_item("$5000", "emp_salario", color_empleados)
	crear_item("Bob", "emp_nombre", color_empleados)
	crear_item("Cajero", "emp_cargo", color_empleados)


func crear_item(texto, tipo, color):
	var item_scene = preload("res://BaseDatosNv/item_dato.tscn")
	var item = item_scene.instantiate()

	item.tipo = tipo
	item.get_node("Label").text = texto
	
	# Cambiamos el color de fondo del item para que coincida con el color de la tabla
	item.modulate = color

	contenedor_datos.add_child(item)

# =========================
# VALIDACIÓN DEL NIVEL
# =========================

func validar():
	var tablas = [usr_nombre, usr_edad, usr_altura, emp_nombre, emp_cargo, emp_salario]
	var hay_errores = false
	
	for t in tablas:
		# validar_tabla ya pinta de rojo/verde si está mal o bien
		if t.validar_tabla():
			hay_errores = true
			
	var faltan_datos = contenedor_datos.get_child_count() > 0

	if not hay_errores and not faltan_datos:
		print("Nivel completado")
		await get_tree().create_timer(0.5).timeout
		GameManager.completar_nivel()
		call_deferred("_cargar_siguiente")
	else:
		GameManager.registrar_fallo_validacion()
		if hay_errores:
			print("Incorrecto - Hay datos equivocados de tabla o columna")
		elif faltan_datos:
			print("Incorrecto - Faltan datos por clasificar")

func _cargar_siguiente():
	#Puedes redirigir a un menú de victoria o al siguiente nivel si lo creas
	get_tree().change_scene_to_file("res://EcoTechNv/nivel_4_1_10.tscn")
	pass

func _on_btn_validar_pressed() -> void:
	validar()

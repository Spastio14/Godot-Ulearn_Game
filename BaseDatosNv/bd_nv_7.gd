extends Control

@export var dialogo_intro: Resource
@export var titulo_dialogo_intro: String = "bd_nivel_7"

@onready var tabla_usuarios = $ContenedorTablas/TablaUsuarios
@onready var tabla_contacto = $ContenedorTablas/TablaContacto
@onready var contenedor_datos = $FondoDatos/ScrollDatos/ContenedorDatos


func _ready():
	LevelDialogueIntro.mostrar(self, dialogo_intro, titulo_dialogo_intro)
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

	crear_item("Roger", "nombre")
	crear_item("Steven", "nombre")
	crear_item("Israel", "nombre")
	crear_item("Jonathan", "nombre")
	crear_item("15", "edad")
	crear_item("18", "edad")
	crear_item("20", "edad")
	crear_item("25", "edad")
	crear_item("Correo", "correo")
	crear_item("Dirección", "direccion")


func crear_item(texto, tipo):

	var item_scene = preload("res://BaseDatosNv/item_dato.tscn")
	var item = item_scene.instantiate()

	item.tipo = tipo
	item.get_node("Label").text = texto
	contenedor_datos.add_child(item)


# =========================
# VALIDACIÓN DEL NIVEL
# =========================

func validar():
	# Llamamos a validar_tabla() que pintará de verde o rojo según sea correcto
	var error_usuarios = tabla_usuarios.validar_tabla()
	var error_contacto = tabla_contacto.validar_tabla()
	
	var hay_errores = error_usuarios or error_contacto
	
	var datos_usuarios = tabla_usuarios.get_datos_recibidos()
	var datos_contacto = tabla_contacto.get_datos_recibidos()

	var usuarios_correcto = (
		"nombre" in datos_usuarios and
		"edad" in datos_usuarios
	)

	var contacto_correcto = (
		"correo" in datos_contacto and
		"direccion" in datos_contacto
	)

	# Si además hay elementos sueltos en el contenedor original, entonces no hemos terminado
	var faltan_datos = contenedor_datos.get_child_count() > 0

	if usuarios_correcto and contacto_correcto and not hay_errores and not faltan_datos:
		print("Nivel completado")
		await get_tree().create_timer(0.5).timeout
		GameManager.nivel_actual += 1
		GameManager.guardar_progreso()
		call_deferred("_cargar_siguiente")
	else:
		if hay_errores:
			print("Incorrecto - Hay datos equivocados")
		elif faltan_datos:
			print("Incorrecto - Faltan datos por clasificar")
		else:
			print("Incorrecto - Faltan datos necesarios")

func _cargar_siguiente():
	get_tree().change_scene_to_file("res://BaseDatosNv/BD_nv_8.tscn")

func _on_btn_validar_pressed() -> void:
	validar()

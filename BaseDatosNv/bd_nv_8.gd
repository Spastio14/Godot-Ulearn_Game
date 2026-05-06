extends Control

@onready var tabla_dba = $ContenedorTablas/TablaDBA
@onready var tabla_usuario = $ContenedorTablas/TablaUsuario
@onready var contenedor_datos = $FondoDatos/ScrollDatos/ContenedorDatos

func _ready():
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
	# Datos de DBA (Administrador de Base de Datos)
	crear_item("Crear Base de Datos", "dba")
	crear_item("Eliminar Tablas", "dba")
	crear_item("Asignar Permisos", "dba")
	crear_item("Hacer Backups", "dba")
	
	# Datos de Usuario Básico / Aplicación
	crear_item("Leer Datos", "usuario")
	crear_item("Actualizar Perfil", "usuario")
	crear_item("Insertar Registro", "usuario")


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
	var error_dba = tabla_dba.validar_tabla()
	var error_usuario = tabla_usuario.validar_tabla()
	
	var hay_errores = error_dba or error_usuario
	
	var datos_dba = tabla_dba.get_datos_recibidos()
	var datos_usuario = tabla_usuario.get_datos_recibidos()

	var dba_correcto = (
		"dba" in datos_dba
	)

	var usuario_correcto = (
		"usuario" in datos_usuario
	)

	# Si además hay elementos sueltos en el contenedor original, entonces no hemos terminado
	var faltan_datos = contenedor_datos.get_child_count() > 0

	# Para ser correcto, todos los datos deben estar clasificados
	# Y no debe haber mezclados, esto lo garantiza que no haya errores
	if dba_correcto and usuario_correcto and not hay_errores and not faltan_datos:
		print("Nivel completado")
		await get_tree().create_timer(0.5).timeout
		GameManager.nivel_actual += 1
		GameManager.guardar_progreso()
		call_deferred("_cargar_siguiente")
	else:
		if hay_errores:
			print("Incorrecto - Hay permisos equivocados")
		elif faltan_datos:
			print("Incorrecto - Faltan asignar permisos")
		else:
			print("Incorrecto - Faltan datos necesarios")

func _cargar_siguiente():
	get_tree().change_scene_to_file("res://BaseDatosNv/BD_nv_9.tscn")

func _on_btn_validar_pressed() -> void:
	validar()

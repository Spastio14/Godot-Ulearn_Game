extends Control

@onready var tabla_usuarios = $ContenedorTablas/TablaUsuarios
@onready var tabla_contacto = $ContenedorTablas/TablaContacto

func _ready():
	inicializar_datos()


func inicializar_datos():

	crear_item("Roger", "nombre")
	crear_item("Steven", "nombre")
	crear_item("Edad", "edad")
	crear_item("Correo", "correo")
	crear_item("Dirección", "direccion")


func crear_item(texto, tipo):

	var item_scene = preload("res://BaseDatosNv/item_dato.tscn")
	var item = item_scene.instantiate()

	item.tipo = tipo
	item.get_node("Label").text = texto

	$ContenedorDatos.add_child(item)


# =========================
# VALIDACIÓN DEL NIVEL
# =========================

func validar():

	var usuarios_correcto = (
		"nombre" in tabla_usuarios.datos_recibidos and
		"edad" in tabla_usuarios.datos_recibidos
	)

	var contacto_correcto = (
		"correo" in tabla_contacto.datos_recibidos and
		"direccion" in tabla_contacto.datos_recibidos
	)

	if usuarios_correcto and contacto_correcto:
		print("Nivel completado")
		GameManager.completar_nivel()
	else:
		print("Incorrecto")

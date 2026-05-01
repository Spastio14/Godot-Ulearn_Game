extends Panel

@export var nombre_tabla: String = ""
@export var tipos_validos: Array[String] = []

@onready var lista = $VBoxContainer

var datos_recibidos: Array = []

func _can_drop_data(at_position, data):

	if typeof(data) == TYPE_DICTIONARY and data.has("tipo"):
		return true

	return false


func _drop_data(at_position, data):

	var tipo = data["tipo"]
	var texto = data["texto"]

	datos_recibidos.append(tipo)

	var label = Label.new()
	label.text = texto
	lista.add_child(label)

	print("Insertado en",nombre_tabla, ":", tipo)

extends Panel

@export var nombre_tabla: String = ""
@export var tipos_validos: Array[String] = []

@onready var lista = $VBoxContainer
@onready var label_titulo = $LabelTitulo

# Usamos una señal para avisar al nivel principal que se agregó un dato
signal dato_agregado(tipo_agregado)

var datos_recibidos: Array = []

func _ready():
	if nombre_tabla != "":
		label_titulo.text = nombre_tabla
	# Asegurarnos de que el panel reciba el drop
	mouse_filter = Control.MOUSE_FILTER_PASS

func _can_drop_data(_at_position, data):
	# Verificar si los datos que estamos arrastrando son un diccionario y tienen "tipo"
	if typeof(data) == TYPE_DICTIONARY and data.has("tipo"):
		# Solo permitimos soltar si el tipo pertenece a esta tabla (Validación inmediata)
		# Si quieres que el usuario se equivoque y luego validar todo al final, 
		# podrías retornar 'true' siempre. 
		# En este caso retornaremos true siempre para que pueda equivocarse o acertar.
		return true
	return false

func _drop_data(_at_position, data):
	var tipo = data["tipo"]
	var texto = data["texto"]
	var nodo_origen = data["nodo"]

	# Agregar a nuestros datos
	datos_recibidos.append(tipo)

	# Crear un elemento visual dentro de la tabla
	var label = Label.new()
	label.text = texto
	label.add_theme_color_override("font_color", Color(0, 1, 0) if tipo in tipos_validos else Color(1, 0, 0)) # Verde si es correcto, rojo si no (Opcional)
	lista.add_child(label)

	# Eliminar el nodo original para que no pueda arrastrarlo dos veces
	if is_instance_valid(nodo_origen):
		nodo_origen.queue_free()


		print("Dato insertado en ", nombre_tabla, ": ", tipo)
		
		# Avisar al controlador del nivel
		dato_agregado.emit(tipo)

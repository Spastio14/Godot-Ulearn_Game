extends Panel

@export var nombre_tabla: String = ""
@export var tipos_validos: Array[String] = []

@export_group("Estilo del Texto")
@export var color_correcto: Color = Color(0.0, 0.506, 0.794, 1.0) # Un verde más agradable
@export var color_incorrecto: Color = Color(0.8, 0.2, 0.2) # Un rojo más agradable
@export var tamano_fuente: int = 22
@export var fuente_personalizada: Font

@onready var lista = $ScrollLista/VBoxContainer
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

	if is_instance_valid(nodo_origen):
		var padre_actual = nodo_origen.get_parent()
		if padre_actual:
			padre_actual.remove_child(nodo_origen)
		
		lista.add_child(nodo_origen)
		
		# Aplicar los estilos configurados (pero el color lo hará el botón Validar)
		if nodo_origen.has_node("Label"):
			var label = nodo_origen.get_node("Label")
			label.add_theme_font_size_override("font_size", tamano_fuente)
			if fuente_personalizada != null:
				label.add_theme_font_override("font", fuente_personalizada)
			# Ponemos un color neutral al soltar
			label.add_theme_color_override("font_color", Color.WHITE)

	print("Dato insertado en ", nombre_tabla, ": ", tipo)
	# Avisar al controlador del nivel
	dato_agregado.emit(tipo)

func get_datos_recibidos() -> Array:
	var arr = []
	for child in lista.get_children():
		if "tipo" in child:
			arr.append(child.tipo)
	return arr

# Esta función la llamará el botón de Validar en el Manager
func validar_tabla() -> bool:
	var hay_errores = false
	for child in lista.get_children():
		if "tipo" in child:
			var label = child.get_node_or_null("Label")
			if child.tipo in tipos_validos:
				if label: label.add_theme_color_override("font_color", color_correcto)
			else:
				if label: label.add_theme_color_override("font_color", color_incorrecto)
				hay_errores = true
	return hay_errores

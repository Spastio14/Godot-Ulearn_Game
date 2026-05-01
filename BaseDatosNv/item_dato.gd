extends Panel

@export var tipo: String = ""  # Ej: "nombre", "edad", "correo", "direccion"
@export var texto_mostrar: String = ""

@onready var label = $Label

func _ready():
	# Asegurar que reciba los eventos del mouse
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Si se instanció por código, usar la variable texto_mostrar
	if texto_mostrar != "":
		label.text = texto_mostrar

func _get_drag_data(_at_position):
	# Crear el elemento visual que seguirá al cursor
	var drag_preview = Label.new()
	drag_preview.text = label.text
	drag_preview.add_theme_font_size_override("font_size", 20)
	
	# Usar un Control como contenedor para centrar el arrastre
	var preview_container = Control.new()
	preview_container.add_child(drag_preview)
	drag_preview.position = -drag_preview.get_minimum_size() / 2 # Centrar bajo el cursor
	
	set_drag_preview(preview_container)
	
	# Ocultar visualmente este panel mientras se arrastra (opcional)
	modulate.a = 0.5 
	
	return {
		"nodo": self,
		"tipo": tipo,
		"texto": label.text
	}

# Opcional: restaurar la opacidad si el drop falla o termina
func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		modulate.a = 1.0

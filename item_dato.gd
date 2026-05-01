extends Panel

@export var tipo: String = ""  # nombre, edad, correo, direccion

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP

func _get_drag_data(at_position):

	var preview = Label.new()
	preview.text = $Label.text
	set_drag_preview(preview)

	return {
		"nodo": self,
		"tipo": tipo,
		"texto": $Label.text
	}

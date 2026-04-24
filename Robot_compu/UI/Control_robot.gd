extends Control

var instrucciones = []

var font = load("res://Fonts/pixeldown.ttf")
@onready var robot = get_tree().get_first_node_in_group("robot")
@onready var lista_ui = $ScrollContainer/ListaInstrucciones

func agregar_instruccion(inst):
	instrucciones.append(inst)
	
	# crear elemento visual
	var label = Label.new()
	label.text = inst
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", 18)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	lista_ui.add_child(label)
	print(instrucciones)

func ejecutar():
	robot.ejecutar_instrucciones(instrucciones)
	# limpiar lista lógica
	instrucciones.clear()

	# limpiar lista visual
	for child in lista_ui.get_children():
		child.queue_free()

func _on_button_der_pressed():
	agregar_instruccion("derecha")

func _on_button_izq_pressed():
	agregar_instruccion("izquierda")

func _on_button_salt_pressed():
	agregar_instruccion("saltar")

func _on_button_eject_pressed():
	ejecutar()

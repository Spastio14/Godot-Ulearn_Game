extends Control

func _ready():

	GameManager.cargar_progreso()

func empezar_juego():
	var ruta
	var nivel = GameManager.nivel_actual
	
	if nivel <= 3:
		ruta = "res://Robot_compu/Compu_nv_" + str(nivel) + ".tscn"
	elif nivel >=4 and nivel <= 6:
		ruta = "res://Circuito_Log_Compu/Circuit_nv_" + str(nivel) + ".tscn"
	elif nivel >=7:
		ruta = "res://BaseDatosNv/BD_nv_" + str(nivel) + ".tscn"
	
	get_tree().change_scene_to_file(ruta)


func _on_button_pressed():
	empezar_juego()

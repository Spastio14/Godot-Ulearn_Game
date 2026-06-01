extends Control

func _ready() -> void:
	GameManager.cargar_progreso()

func empezar_juego() -> void:
	var total_niveles := GameManager.obtener_total_niveles()
	if GameManager.nivel_actual > total_niveles:
		GameManager.mostrar_resultados_finales()
		return
	var nivel := int(clamp(GameManager.nivel_actual, 1, total_niveles))
	var ruta := GameManager.obtener_ruta_nivel(nivel)
	if ruta.is_empty():
		GameManager.mostrar_resultados_finales()
		return
	get_tree().change_scene_to_file(ruta)

func _on_button_pressed() -> void:
	empezar_juego()

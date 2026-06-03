extends Control

@onready var boton_jugar: Button = $VBoxContainer/Button

func _ready() -> void:
	if not GameManager.estadisticas_actualizadas.is_connected(_on_estadisticas_actualizadas):
		GameManager.estadisticas_actualizadas.connect(_on_estadisticas_actualizadas)
	GameManager.cargar_progreso()
	_actualizar_boton_jugar()

func empezar_juego() -> void:
	var total_niveles := GameManager.obtener_total_niveles()
	if GameManager.nivel_actual > total_niveles:
		GameManager.reiniciar_progreso()
	var nivel := int(clamp(GameManager.nivel_actual, 1, total_niveles))
	var ruta := GameManager.obtener_ruta_nivel(nivel)
	if ruta.is_empty():
		GameManager.mostrar_resultados_finales()
		return
	get_tree().change_scene_to_file(ruta)

func _actualizar_boton_jugar() -> void:
	if GameManager.nivel_actual > GameManager.obtener_total_niveles():
		boton_jugar.text = "Jugar de nuevo"
	else:
		boton_jugar.text = "Jugar"

func _on_button_pressed() -> void:
	empezar_juego()

func _on_estadisticas_actualizadas(_resumen_global: Dictionary) -> void:
	_actualizar_boton_jugar()

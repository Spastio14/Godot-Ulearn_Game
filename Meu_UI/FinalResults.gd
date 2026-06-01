extends Control

@onready var etiqueta_titulo: Label = $PanelPrincipal/Margen/Contenido/EtiquetaTitulo
@onready var resumen_jugador: GridContainer = $PanelPrincipal/Margen/Contenido/Scroll/Secciones/ResumenJugador/GridResumen
@onready var tabla_fases: GridContainer = $PanelPrincipal/Margen/Contenido/Scroll/Secciones/TablaFases/GridFases
@onready var tabla_niveles: GridContainer = $PanelPrincipal/Margen/Contenido/Scroll/Secciones/TablaNiveles/GridNiveles
@onready var resultados_globales: GridContainer = $PanelPrincipal/Margen/Contenido/Scroll/Secciones/ResultadosGlobales/GridGlobal
@onready var boton_menu: Button = $PanelPrincipal/Margen/Contenido/BotonMenu

func _ready() -> void:
	boton_menu.pressed.connect(_on_boton_menu_pressed)
	construir_pantalla_resultados()

func construir_pantalla_resultados() -> void:
	var resultados: Dictionary = GameManager.obtener_resumen_resultados()
	var global: Dictionary = resultados.get("global", {})
	etiqueta_titulo.text = "Resultados finales de %s" % str(resultados.get("usuario", "Jugador"))
	_limpiar_grid(resumen_jugador)
	_agregar_fila(resumen_jugador, "Tiempo total", GameManager.formatear_tiempo(float(global.get("tiempo_total", 0.0))))
	_agregar_fila(resumen_jugador, "Errores totales", str(global.get("errores_totales", 0)))
	_agregar_fila(resumen_jugador, "Intentos totales", str(global.get("intentos_totales", 0)))
	_agregar_fila(resumen_jugador, "Niveles completados", "%s / %s" % [global.get("niveles_completados", 0), global.get("niveles_totales", 0)])
	_agregar_fila(resumen_jugador, "Fases completadas", "%s / %s" % [global.get("fases_completadas", 0), global.get("fases_totales", 0)])
	_construir_tabla_fases(resultados.get("fases", {}))
	_construir_tabla_niveles(resultados.get("niveles", {}))
	_limpiar_grid(resultados_globales)
	_agregar_fila(resultados_globales, "Promedio de niveles", "%.2f%%" % float(global.get("puntaje_promedio_niveles", 0.0)))
	_agregar_fila(resultados_globales, "Promedio de fases", "%.2f%%" % float(global.get("puntaje_promedio_fases", 0.0)))
	_agregar_fila(resultados_globales, "Porcentaje final", "%.2f%%" % float(global.get("porcentaje_final", 0.0)))
	_agregar_fila(resultados_globales, "Rango final", str(global.get("rango_final", "Sin rango")))

func _construir_tabla_fases(fases: Dictionary) -> void:
	_limpiar_grid(tabla_fases)
	_agregar_encabezado(tabla_fases, ["Fase", "Niveles", "Promedio", "Errores", "Tiempo", "Completado"])
	var claves := fases.keys()
	claves.sort_custom(func(a, b): return int(a) < int(b))
	for clave in claves:
		var fase: Dictionary = fases[clave]
		_agregar_celdas(tabla_fases, [
			"Fase %s" % clave,
			"%s / %s" % [fase.get("niveles_completados", 0), fase.get("niveles_totales", 0)],
			"%.2f%%" % float(fase.get("puntaje_promedio", 0.0)),
			str(fase.get("errores_totales", 0)),
			GameManager.formatear_tiempo(float(fase.get("tiempo_total", 0.0))),
			"%.2f%%" % float(fase.get("porcentaje_completado", 0.0))
		])

func _construir_tabla_niveles(niveles: Dictionary) -> void:
	_limpiar_grid(tabla_niveles)
	_agregar_encabezado(tabla_niveles, ["Nivel", "Fase", "Puntaje", "Tiempo", "Errores", "Eficiencia"])
	var claves := niveles.keys()
	claves.sort_custom(func(a, b): return int(a) < int(b))
	for clave in claves:
		var nivel: Dictionary = niveles[clave]
		_agregar_celdas(tabla_niveles, [
			str(nivel.get("nombre_nivel", "Nivel %s" % clave)),
			str(nivel.get("fase", "-")),
			"%.2f%%" % float(nivel.get("porcentaje", 0.0)),
			GameManager.formatear_tiempo(float(nivel.get("duracion", 0.0))),
			str(nivel.get("errores", 0)),
			"%.2f%%" % float(nivel.get("eficiencia", 0.0))
		])

func _limpiar_grid(grid: GridContainer) -> void:
	for child in grid.get_children():
		child.queue_free()

func _agregar_fila(grid: GridContainer, etiqueta: String, valor: String) -> void:
	_agregar_celda(grid, etiqueta, true)
	_agregar_celda(grid, valor, false)

func _agregar_encabezado(grid: GridContainer, textos: Array[String]) -> void:
	for texto in textos:
		_agregar_celda(grid, texto, true)

func _agregar_celdas(grid: GridContainer, textos: Array) -> void:
	for texto in textos:
		_agregar_celda(grid, str(texto), false)

func _agregar_celda(grid: GridContainer, texto: String, destacado: bool) -> void:
	var label := Label.new()
	label.text = texto
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(130, 28)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if destacado:
		label.add_theme_color_override("font_color", Color(0.31, 0.83, 1.0))
		label.add_theme_font_size_override("font_size", 18)
	else:
		label.add_theme_font_size_override("font_size", 16)
	grid.add_child(label)

func _on_boton_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Meu_UI/menu_ui.tscn")

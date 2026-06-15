extends Node

signal seguimiento_nivel_iniciado(datos_nivel: Dictionary)
signal seguimiento_nivel_finalizado(resultado_nivel: Dictionary)
signal estadisticas_actualizadas(resumen_global: Dictionary)

const RUTA_GUARDADO_LOCAL: String = "user://progreso_rendimiento.json"
const RUTA_RESULTADOS_FINALES: String = "res://Meu_UI/final_results.tscn"
const PUNTAJE_MAXIMO: float = 100.0
const PENALIZACION_ERROR: float = 6.0
const PENALIZACION_INTENTO: float = 8.0
const PENALIZACION_REINICIO: float = 10.0
const PENALIZACION_VALIDACION: float = 5.0
const PENALIZACION_PISTA: float = 2.0
const PENALIZACION_ACCION_INCORRECTA: float = 4.0

const SUPABASE_URL: String = "https://serbkvicxxkhasufhcim.supabase.co"
const SUPABASE_KEY: String = "sb_publishable_pqZwOcmSN-YLBl8-rIe74w_upz5b4OR"

var usuario: String = "Usuario"
var user_id: String = ""
var carrera_id: String = "computacion"
var nivel_actual: int = 1
var fase_actual: int = 1

var niveles_config: Dictionary = {
	1: {"id": "robot_1", "nombre": "Robot - Secuencia básica", "fase": 1, "ruta": "res://Robot_compu/Compu_nv_1.tscn", "tiempo_objetivo": 45.0},
	2: {"id": "robot_2", "nombre": "Robot - Ruta extendida", "fase": 1, "ruta": "res://Robot_compu/Compu_nv_2.tscn", "tiempo_objetivo": 55.0},
	3: {"id": "robot_3", "nombre": "Robot - Llave y meta", "fase": 1, "ruta": "res://Robot_compu/Compu_nv_3.tscn", "tiempo_objetivo": 70.0},
	4: {"id": "circuito_4", "nombre": "Circuitos - Compuerta AND", "fase": 2, "ruta": "res://Circuito_Log_Compu/Circuit_nv_4.tscn", "tiempo_objetivo": 50.0},
	5: {"id": "circuito_5", "nombre": "Circuitos - Combinación lógica", "fase": 2, "ruta": "res://Circuito_Log_Compu/Circuit_nv_5.tscn", "tiempo_objetivo": 70.0},
	6: {"id": "circuito_6", "nombre": "Circuitos - Validación avanzada", "fase": 2, "ruta": "res://Circuito_Log_Compu/circuit_nv_6.tscn", "tiempo_objetivo": 90.0},
	7: {"id": "bd_7", "nombre": "Base de datos - Clasificación", "fase": 3, "ruta": "res://BaseDatosNv/BD_nv_7.tscn", "tiempo_objetivo": 85.0},
	8: {"id": "bd_8", "nombre": "Base de datos - Roles", "fase": 3, "ruta": "res://BaseDatosNv/BD_nv_8.tscn", "tiempo_objetivo": 90.0},
	9: {"id": "bd_9", "nombre": "Base de datos - Tablas relacionadas", "fase": 3, "ruta": "res://BaseDatosNv/BD_nv_9.tscn", "tiempo_objetivo": 110.0},
	10: {"id": "redes_10", "nombre": "Redes - Conectividad básica", "fase": 4, "ruta": "res://EcoTechNv/nivel_4_1_10.tscn", "tiempo_objetivo": 80.0},
	11: {"id": "redes_11", "nombre": "Redes - Saturación y segmentación", "fase": 4, "ruta": "res://EcoTechNv/nivel_4_2_11.tscn", "rutas_adicionales": ["res://EcoTechNv/nivel_4_11.tscn"], "tiempo_objetivo": 100.0},
	12: {"id": "redes_12", "nombre": "Redes - Infraestructura redundante", "fase": 4, "ruta": "res://EcoTechNv/nivel_4_3_12.tscn", "tiempo_objetivo": 120.0},
	13: {"id": "redes_13", "nombre": "Redes - Optimización", "fase": 4, "ruta": "res://EcoTechNv/nivel_4_4_13.tscn", "tiempo_objetivo": 120.0},
	14: {"id": "redes_14", "nombre": "Redes - Evaluación final", "fase": 4, "ruta": "res://EcoTechNv/nivel_4_5_14.tscn", "tiempo_objetivo": 140.0}
}

var datos_rendimiento: Dictionary = {
	"usuario": usuario,
	"fase_actual": fase_actual,
	"nivel_actual": nivel_actual,
	"niveles": {},
	"fases": {},
	"global": {}
}

var seguimiento_activo: bool = false
var nivel_en_seguimiento: int = 0
var metricas_nivel_actual: Dictionary = {}
var ultima_escena_detectada: String = ""
var ignorar_respuestas_remotas: bool = false

func _ready() -> void:
	_obtener_usuario_desde_web()
	cargar_guardado_local()
	get_tree().node_added.connect(_on_node_added)

func _process(_delta: float) -> void:
	var escena := get_tree().current_scene
	if escena == null:
		return
	var ruta := escena.scene_file_path
	if ruta != ultima_escena_detectada:
		ultima_escena_detectada = ruta
		_iniciar_seguimiento_por_escena_actual()

func _on_node_added(node: Node) -> void:
	if node == get_tree().current_scene:
		call_deferred("_iniciar_seguimiento_por_escena_actual")

func _iniciar_seguimiento_por_escena_actual() -> void:
	var escena := get_tree().current_scene
	if escena == null:
		return
	var ruta := escena.scene_file_path
	var numero_nivel := obtener_nivel_por_ruta(ruta)
	if numero_nivel > 0:
		start_level_tracking(numero_nivel)

func _obtener_usuario_desde_web() -> void:
	if OS.has_feature("web"):
		var session_json = JavaScriptBridge.eval("localStorage.getItem('ulearn_session')")
		if session_json and session_json != "undefined" and session_json != "null":
			var datos = JSON.parse_string(session_json)
			if datos is Dictionary:
				usuario = datos.get("name", "Usuario")
				user_id = datos.get("id", "")
				print("Usuario detectado desde localStorage: ", usuario, " (", user_id, ")")

func obtener_nivel_por_ruta(ruta: String) -> int:
	for numero in niveles_config.keys():
		var config: Dictionary = niveles_config[numero]
		if str(config.get("ruta", "")) == ruta:
			return int(numero)
		for ruta_adicional in config.get("rutas_adicionales", []):
			if str(ruta_adicional) == ruta:
				return int(numero)
	return 0

func obtener_ruta_nivel(numero_nivel: int) -> String:
	if niveles_config.has(numero_nivel):
		return str(niveles_config[numero_nivel].get("ruta", ""))
	return ""

func obtener_siguiente_ruta_nivel(numero_nivel: int) -> String:
	return obtener_ruta_nivel(numero_nivel + 1)

func obtener_total_niveles() -> int:
	return niveles_config.size()

func start_level_tracking(numero_nivel: int = nivel_actual) -> void:
	if not niveles_config.has(numero_nivel):
		push_warning("No existe configuración de rendimiento para el nivel %d." % numero_nivel)
		return
	if seguimiento_activo and nivel_en_seguimiento == numero_nivel:
		return
	var config: Dictionary = niveles_config[numero_nivel]
	nivel_en_seguimiento = numero_nivel
	fase_actual = int(config.get("fase", fase_actual))
	metricas_nivel_actual = {
		"numero_nivel": numero_nivel,
		"nivel_id": str(config.get("id", "nivel_%d" % numero_nivel)),
		"nombre_nivel": str(config.get("nombre", "Nivel %d" % numero_nivel)),
		"fase": fase_actual,
		"inicio_unix": Time.get_unix_time_from_system(),
		"fin_unix": 0.0,
		"duracion": 0.0,
		"intentos_fallidos": 0,
		"acciones_incorrectas": 0,
		"reinicios": 0,
		"fallos_validacion": 0,
		"pistas_usadas": 0,
		"errores": 0,
		"aciertos": 0,
		"completado": false,
		"porcentaje": 0.0,
		"eficiencia": 0.0,
		"tasa_exito": 0.0,
		"puntaje_general": 0.0
	}
	seguimiento_activo = true
	seguimiento_nivel_iniciado.emit(metricas_nivel_actual.duplicate(true))

func finish_level_tracking(completado: bool = true) -> Dictionary:
	if not seguimiento_activo:
		start_level_tracking(nivel_actual)
	if metricas_nivel_actual.is_empty():
		return {}
	metricas_nivel_actual["fin_unix"] = Time.get_unix_time_from_system()
	metricas_nivel_actual["duracion"] = max(0.0, float(metricas_nivel_actual["fin_unix"]) - float(metricas_nivel_actual["inicio_unix"]))
	metricas_nivel_actual["completado"] = completado
	var resultado := calculate_level_score(metricas_nivel_actual)
	for clave in resultado.keys():
		metricas_nivel_actual[clave] = resultado[clave]
	_guardar_resultado_nivel(metricas_nivel_actual)
	
	if completado:
		nivel_actual = max(nivel_actual, int(metricas_nivel_actual.get("numero_nivel", nivel_actual)) + 1)
		fase_actual = int(niveles_config.get(min(nivel_actual, obtener_total_niveles()), {}).get("fase", fase_actual))
		mostrar_mensaje_felicitacion(resultado)

	seguimiento_activo = false
	seguimiento_nivel_finalizado.emit(metricas_nivel_actual.duplicate(true))
	estadisticas_actualizadas.emit(calculate_global_score())
	guardar_progreso()
	return metricas_nivel_actual.duplicate(true)

func mostrar_mensaje_felicitacion(resultado: Dictionary) -> void:
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	get_tree().root.add_child(canvas_layer)

	var color_rect = ColorRect.new()
	color_rect.color = Color(0, 0, 0, 0.5)
	color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(color_rect)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	canvas_layer.add_child(vbox)

	var label_main = Label.new()
	label_main.text = "¡NIVEL COMPLETADO!"
	label_main.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_main.add_theme_font_size_override("font_size", 50)
	vbox.add_child(label_main)

	var label_user = Label.new()
	label_user.text = "Buen trabajo, " + usuario
	label_user.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_user.add_theme_font_size_override("font_size", 24)
	vbox.add_child(label_user)

	var label_score = Label.new()
	label_score.text = "Puntaje: " + str(resultado.get("porcentaje", 0)) + " / 100"
	label_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_score.add_theme_font_size_override("font_size", 36)
	label_score.modulate = Color.GOLD
	vbox.add_child(label_score)

	var label_extra = Label.new()
	label_extra.text = "Eficiencia: %d%% | Tasa de éxito: %d%%" % [resultado.get("eficiencia", 0), resultado.get("tasa_exito", 0)]
	label_extra.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label_extra)

	var label_rank = Label.new()
	label_rank.text = resultado.get("clasificacion", "")
	label_rank.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_rank.add_theme_font_size_override("font_size", 28)
	vbox.add_child(label_rank)

	var timer = get_tree().create_timer(4.0)
	timer.timeout.connect(func(): canvas_layer.queue_free())

func registrar_acierto(cantidad: int = 1) -> void:
	_asegurar_seguimiento_actual()
	metricas_nivel_actual["aciertos"] = int(metricas_nivel_actual.get("aciertos", 0)) + cantidad

func register_error(cantidad: int = 1, tipo: String = "error") -> void:
	_asegurar_seguimiento_actual()
	metricas_nivel_actual["errores"] = int(metricas_nivel_actual.get("errores", 0)) + cantidad
	match tipo:
		"accion_incorrecta":
			metricas_nivel_actual["acciones_incorrectas"] = int(metricas_nivel_actual.get("acciones_incorrectas", 0)) + cantidad
		"validacion":
			metricas_nivel_actual["fallos_validacion"] = int(metricas_nivel_actual.get("fallos_validacion", 0)) + cantidad
		"pista":
			metricas_nivel_actual["pistas_usadas"] = int(metricas_nivel_actual.get("pistas_usadas", 0)) + cantidad

func register_retry(cantidad: int = 1) -> void:
	_asegurar_seguimiento_actual()
	metricas_nivel_actual["intentos_fallidos"] = int(metricas_nivel_actual.get("intentos_fallidos", 0)) + cantidad

func registrar_reinicio(cantidad: int = 1) -> void:
	_asegurar_seguimiento_actual()
	metricas_nivel_actual["reinicios"] = int(metricas_nivel_actual.get("reinicios", 0)) + cantidad
	register_retry(cantidad)

func registrar_fallo_validacion(cantidad: int = 1) -> void:
	register_error(cantidad, "validacion")
	register_retry(cantidad)

func registrar_accion_incorrecta(cantidad: int = 1) -> void:
	register_error(cantidad, "accion_incorrecta")

func registrar_pista_usada(cantidad: int = 1) -> void:
	register_error(cantidad, "pista")

func calculate_level_score(metricas: Dictionary) -> Dictionary:
	var numero_nivel := int(metricas.get("numero_nivel", nivel_en_seguimiento))
	var config: Dictionary = niveles_config.get(numero_nivel, {})
	var tiempo_objetivo: float = maxf(1.0, float(config.get("tiempo_objetivo", 90.0)))
	var duracion: float = maxf(0.0, float(metricas.get("duracion", 0.0)))
	var eficiencia: float = clampf(tiempo_objetivo / maxf(tiempo_objetivo, duracion), 0.0, 1.0)
	var penalizacion_tiempo: float = (1.0 - eficiencia) * 25.0
	var penalizacion_errores: float = float(metricas.get("errores", 0)) * PENALIZACION_ERROR
	penalizacion_errores += float(metricas.get("acciones_incorrectas", 0)) * PENALIZACION_ACCION_INCORRECTA
	penalizacion_errores += float(metricas.get("fallos_validacion", 0)) * PENALIZACION_VALIDACION
	penalizacion_errores += float(metricas.get("pistas_usadas", 0)) * PENALIZACION_PISTA
	var penalizacion_reintentos: float = float(metricas.get("intentos_fallidos", 0)) * PENALIZACION_INTENTO
	penalizacion_reintentos += float(metricas.get("reinicios", 0)) * PENALIZACION_REINICIO
	var puntaje: float = clampf(PUNTAJE_MAXIMO - penalizacion_tiempo - penalizacion_errores - penalizacion_reintentos, 0.0, PUNTAJE_MAXIMO)
	var total_intentos: int = maxi(1, int(metricas.get("intentos_fallidos", 0)) + 1)
	var tasa_exito: float = clampf(1.0 / float(total_intentos), 0.0, 1.0)
	return {
		"porcentaje": snapped(puntaje, 0.01),
		"puntaje_general": snapped(puntaje, 0.01),
		"eficiencia": snapped(eficiencia * 100.0, 0.01),
		"tasa_exito": snapped(tasa_exito * 100.0, 0.01),
		"clasificacion": obtener_clasificacion_porcentaje(puntaje)
	}

func calculate_phase_score(numero_fase: int) -> Dictionary:
	var niveles_fase: Array = []
	for clave in datos_rendimiento["niveles"].keys():
		var nivel: Dictionary = datos_rendimiento["niveles"][clave]
		if int(nivel.get("fase", 0)) == numero_fase:
			niveles_fase.append(nivel)
	var total_niveles_fase: int = _contar_niveles_config_por_fase(numero_fase)
	var total_score: float = 0.0
	var total_errores: int = 0
	var total_tiempo: float = 0.0
	var completados: int = 0
	for nivel in niveles_fase:
		if bool(nivel.get("completado", false)):
			completados += 1
		total_score += float(nivel.get("porcentaje", 0.0))
		total_errores += int(nivel.get("errores", 0))
		total_tiempo += float(nivel.get("duracion", 0.0))
	var promedio: float = 0.0 if niveles_fase.is_empty() else total_score / float(niveles_fase.size())
	var completion: float = 0.0 if total_niveles_fase == 0 else (float(completados) / float(total_niveles_fase)) * 100.0
	return {
		"fase": numero_fase,
		"niveles_completados": completados,
		"niveles_totales": total_niveles_fase,
		"puntaje_promedio": snapped(promedio, 0.01),
		"errores_totales": total_errores,
		"tiempo_total": snapped(total_tiempo, 0.01),
		"porcentaje_completado": snapped(completion, 0.01)
	}

func calculate_global_score() -> Dictionary:
	var niveles: Array = datos_rendimiento["niveles"].values()
	var fases: Array[int] = []
	for config in niveles_config.values():
		var fase: int = int(config.get("fase", 0))
		if fase > 0 and fase not in fases:
			fases.append(fase)
	fases.sort()
	var total_score: float = 0.0
	var total_errores: int = 0
	var total_tiempo: float = 0.0
	var total_intentos: int = 0
	var completados: int = 0
	for nivel in niveles:
		if bool(nivel.get("completado", false)):
			completados += 1
		total_score += float(nivel.get("porcentaje", 0.0))
		total_errores += int(nivel.get("errores", 0))
		total_tiempo += float(nivel.get("duracion", 0.0))
		total_intentos += int(nivel.get("intentos_fallidos", 0)) + 1
	var promedio_niveles: float = 0.0 if niveles.is_empty() else total_score / float(niveles.size())
	var suma_fases: float = 0.0
	var fases_completadas: int = 0
	for fase in fases:
		var resumen_fase: Dictionary = calculate_phase_score(fase)
		datos_rendimiento["fases"][str(fase)] = resumen_fase
		if int(resumen_fase.get("niveles_completados", 0)) > 0:
			suma_fases += float(resumen_fase.get("puntaje_promedio", 0.0))
		if float(resumen_fase.get("porcentaje_completado", 0.0)) >= 100.0:
			fases_completadas += 1
	var promedio_fases: float = 0.0 if fases.is_empty() else suma_fases / float(maxi(1, fases.size()))
	var porcentaje_final: float = snapped((promedio_niveles * 0.7) + (promedio_fases * 0.3), 0.01)
	var global: Dictionary = {
		"tiempo_total": snapped(total_tiempo, 0.01),
		"errores_totales": total_errores,
		"intentos_totales": total_intentos,
		"niveles_completados": completados,
		"niveles_totales": obtener_total_niveles(),
		"fases_completadas": fases_completadas,
		"fases_totales": fases.size(),
		"puntaje_promedio_niveles": snapped(promedio_niveles, 0.01),
		"puntaje_promedio_fases": snapped(promedio_fases, 0.01),
		"porcentaje_final": porcentaje_final,
		"rango_final": obtener_rango_final(porcentaje_final)
	}
	datos_rendimiento["global"] = global
	return global

func completar_nivel(ruta_siguiente: String = "") -> Dictionary:
	if not seguimiento_activo and bool(metricas_nivel_actual.get("completado", false)):
		return metricas_nivel_actual.duplicate(true)
	var resultado := finish_level_tracking(true)
	if resultado.is_empty():
		return resultado
	if not ruta_siguiente.is_empty():
		get_tree().change_scene_to_file(ruta_siguiente)
	return resultado

func completar_nivel_y_cambiar(ruta_siguiente: String) -> void:
	completar_nivel(ruta_siguiente)

func mostrar_resultados_finales() -> void:
	calculate_global_score()
	guardar_progreso()
	get_tree().change_scene_to_file(RUTA_RESULTADOS_FINALES)

func configurar_usuario(nombre_usuario: String, nueva_carrera_id: String = "") -> void:
	var nombre_limpio := nombre_usuario.strip_edges()
	if nombre_limpio.is_empty():
		return
	usuario = nombre_limpio
	if not nueva_carrera_id.strip_edges().is_empty():
		carrera_id = nueva_carrera_id.strip_edges()
	datos_rendimiento["usuario"] = usuario
	guardar_progreso()

func reiniciar_progreso() -> void:
	ignorar_respuestas_remotas = true
	nivel_actual = 1
	fase_actual = int(niveles_config.get(nivel_actual, {}).get("fase", 1))
	seguimiento_activo = false
	nivel_en_seguimiento = 0
	metricas_nivel_actual = {}
	datos_rendimiento = {
		"usuario": usuario,
		"fase_actual": fase_actual,
		"nivel_actual": nivel_actual,
		"niveles": {},
		"fases": {},
		"global": {}
	}
	calculate_global_score()
	estadisticas_actualizadas.emit(datos_rendimiento["global"].duplicate(true))
	guardar_progreso()

func guardar_progreso() -> void:
	datos_rendimiento["usuario" ] = usuario
	datos_rendimiento["fase_actual"] = fase_actual
	datos_rendimiento["nivel_actual"] = nivel_actual
	_guardar_archivo_local()
	_guardar_progreso_remoto()

func cargar_progreso() -> void:
	cargar_guardado_local()
	estadisticas_actualizadas.emit(calculate_global_score())
	
	_obtener_usuario_desde_web()
	
	var http_request := HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_progreso_recibido.bind(http_request))
	
	# Consultamos directamente a Supabase
	var url = SUPABASE_URL + "/rest/v1/game_performance?username=eq." + usuario.uri_encode() + "&order=id.desc&limit=1"

	var cabeceras: PackedStringArray = [
		"Content-Type: application/json",
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY
	]

	var error := http_request.request(url, cabeceras, HTTPClient.METHOD_GET)
	if error != OK:
		push_warning("No se pudo solicitar el progreso remoto de Supabase. Código: %s" % error)
		http_request.queue_free()

func cargar_guardado_local() -> void:
	if not FileAccess.file_exists(RUTA_GUARDADO_LOCAL):
		return
	var archivo := FileAccess.open(RUTA_GUARDADO_LOCAL, FileAccess.READ)
	if archivo == null:
		return
	var texto := archivo.get_as_text()
	var datos = JSON.parse_string(texto)
	if datos is Dictionary:
		_fusionar_guardado(datos)

func obtener_resumen_resultados() -> Dictionary:
	calculate_global_score()
	return datos_rendimiento.duplicate(true)

func obtener_clasificacion_porcentaje(porcentaje: float) -> String:
	if porcentaje >= 95.0:
		return "Ejecución perfecta"
	if porcentaje >= 90.0:
		return "Errores menores"
	if porcentaje >= 80.0:
		return "Rendimiento aceptable"
	if porcentaje >= 70.0:
		return "Múltiples errores"
	if porcentaje >= 60.0:
		return "Errores excesivos"
	return "Rendimiento bajo"

func obtener_rango_final(porcentaje: float) -> String:
	if porcentaje >= 95.0:
		return "Experto"
	if porcentaje >= 85.0:
		return "Avanzado"
	if porcentaje >= 70.0:
		return "Intermedio"
	if porcentaje >= 60.0:
		return "Principiante"
	return "Necesita mejorar"

func formatear_tiempo(segundos: float) -> String:
	var total := int(round(segundos))
	var minutos := total / 60
	var seg := total % 60
	return "%02d:%02d" % [minutos, seg]

func _asegurar_seguimiento_actual() -> void:
	if not seguimiento_activo:
		start_level_tracking(nivel_actual)

func _guardar_resultado_nivel(resultado: Dictionary) -> void:
	var clave: String = str(resultado.get("numero_nivel", nivel_en_seguimiento))
	datos_rendimiento["niveles"][clave] = resultado.duplicate(true)
	calculate_global_score()

func _guardar_archivo_local() -> void:
	var archivo := FileAccess.open(RUTA_GUARDADO_LOCAL, FileAccess.WRITE)
	if archivo == null:
		push_warning("No se pudo abrir el archivo de guardado local de rendimiento.")
		return
	archivo.store_string(JSON.stringify(datos_rendimiento, "\t"))

func _guardar_progreso_remoto() -> void:
	var http_request := HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(func(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
		if response_code >= 200 and response_code < 300:
			print("Progreso guardado exitosamente en Supabase.")
		else:
			push_warning("Error al guardar progreso en Supabase. Código: %d" % response_code)
			print("Respuesta: ", body.get_string_from_utf8())
		http_request.queue_free()
		)

	var global = calculate_global_score()
	# Adaptar payload para que coincida con la tabla game_performance de Supabase
	var payload: Dictionary = {
			"username": usuario,
			"carrera_id": carrera_id,
			"nivel_actual": nivel_actual,
			"fase_actual": fase_actual,
			"tiempo_total": global.get("tiempo_total", 0.0),
			"errores_totales": global.get("errores_totales", 0),
			"intentos_totales": global.get("intentos_totales", 0),
			"niveles_completados": global.get("niveles_completados", 0),
			"fases_completadas": global.get("fases_completadas", 0),
			"puntaje_promedio_niveles": global.get("puntaje_promedio_niveles", 0.0),
			"puntaje_promedio_fases": global.get("puntaje_promedio_fases", 0.0),
			"porcentaje_final": global.get("porcentaje_final", 0.0),
			"rango_final": global.get("rango_final", "N/A"),
			"raw_rendimiento": datos_rendimiento
		}
	
	if not user_id.is_empty():
		payload["user_id"] = user_id

	var cuerpo_json: String = JSON.stringify(payload)
	var cabeceras: PackedStringArray = [
		"Content-Type: application/json",
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY,
		"Prefer: return=minimal"
	]

	var url = SUPABASE_URL + "/rest/v1/game_performance"
	var error: Error = http_request.request(url, cabeceras, HTTPClient.METHOD_POST, cuerpo_json)
	if error != OK:
		push_warning("No se pudo iniciar la petición a Supabase. Código: %s" % error)
		http_request.queue_free()

func _on_progreso_recibido(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, http_request: HTTPRequest) -> void:
	http_request.queue_free()
	if ignorar_respuestas_remotas:
		return
	var texto: String = body.get_string_from_utf8()
	if response_code != 200 or texto.strip_edges().is_empty() or texto == "[]":
		return

	var datos_recibidos = JSON.parse_string(texto)
	if datos_recibidos is Dictionary:
		_fusionar_guardado(datos_recibidos)
		estadisticas_actualizadas.emit(calculate_global_score())
		print("Progreso cargado desde el Backend. Nivel actual: ", nivel_actual)
	elif datos_recibidos is Array and datos_recibidos.size() > 0:
		var primer_dato = datos_recibidos[0]
		if primer_dato is Dictionary:
			_fusionar_guardado(primer_dato)
			estadisticas_actualizadas.emit(calculate_global_score())
			print("Progreso cargado desde el Backend (array). Nivel actual: ", nivel_actual)

func _fusionar_guardado(datos: Dictionary) -> void:
	var usuario_principal := usuario
	if datos.has("nivel_actual"):
		nivel_actual = int(datos["nivel_actual"])
	elif datos.has("nivel"):
		nivel_actual = int(datos["nivel"])
	if datos.has("fase_actual"):
		fase_actual = int(datos["fase_actual"])
	if datos.has("raw_rendimiento") and datos["raw_rendimiento"] is Dictionary:
		_fusionar_guardado(datos["raw_rendimiento"])
	elif datos.has("rendimiento") and datos["rendimiento" ] is Dictionary:
		_fusionar_guardado(datos["rendimiento"])
	
	usuario = usuario_principal
	if datos.has("niveles") and datos["niveles"] is Dictionary:
		for clave in datos["niveles"].keys():
			datos_rendimiento["niveles"][str(clave)] = datos["niveles"][clave]
	if datos.has("fases") and datos["fases"] is Dictionary:
		for clave in datos["fases"].keys():
			datos_rendimiento["fases"][str(clave)] = datos["fases"][clave]
	if datos.has("global") and datos["global"] is Dictionary:
		datos_rendimiento["global"] = datos["global"]
	datos_rendimiento["usuario"] = usuario
	datos_rendimiento["nivel_actual"] = nivel_actual
	datos_rendimiento["fase_actual"] = fase_actual
	calculate_global_score()

func _contar_niveles_config_por_fase(numero_fase: int) -> int:
	var total := 0
	for config in niveles_config.values():
		if int(config.get("fase", 0)) == numero_fase:
			total += 1
	return total

func get_usuario_logueado() -> String:
	return usuario

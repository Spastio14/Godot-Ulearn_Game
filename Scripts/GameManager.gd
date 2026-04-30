extends Node

var usuario: String = "nose"
var nivel_actual: int = 4
var servidor: String = "http://10.239.148.115:8000/backend/"

func guardar_progreso() -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)

	var datos_a_enviar = {
		"usuario": usuario,
		"nivel": nivel_actual
	}

	var cuerpo_json = JSON.stringify(datos_a_enviar)
	var cabeceras = ["Content-Type: application/json"]

	http_request.request(
		servidor + "guardar_progreso.php",
		cabeceras,
		HTTPClient.METHOD_POST,
		cuerpo_json
	)

func cargar_progreso() -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	http_request.request_completed.connect(_on_progreso_recibido)

	var url = servidor + "obtener_progreso.php?usuario=" + usuario
	http_request.request(url)

func _on_progreso_recibido(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var texto = body.get_string_from_utf8()
	
	# Imprimimos la respuesta cruda para ver qué está devolviendo realmente el servidor
	print("Respuesta cruda del servidor: ", texto)
	print("Código de respuesta HTTP: ", _response_code)
	
	if _response_code != 200:
		print("Error: El servidor no respondió con éxito.")
		return
		
	if texto.strip_edges() == "":
		print("Error: El servidor devolvió una respuesta vacía.")
		return

	# Ahora intentamos parsear el JSON
	var datos_recibidos = JSON.parse_string(texto)

	if datos_recibidos != null and datos_recibidos is Dictionary:
		if datos_recibidos.has("nivel_actual"):
			nivel_actual = int(datos_recibidos["nivel_actual"])
			print("Progreso cargado. Nivel actual: ", nivel_actual)
	else:
		print("Error: No se pudo procesar la respuesta del servidor o el JSON es inválido.")

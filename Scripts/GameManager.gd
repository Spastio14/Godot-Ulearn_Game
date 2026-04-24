extends Node

var usuario = "roger"
var nivel_actual = 1
var servidor = "http://localhost:3001/"

func guardar_progreso():

	var http = HTTPRequest.new()
	add_child(http)

	var datos = {
		"usuario": usuario,
		"nivel": nivel_actual
	}

	var json = JSON.stringify(datos)

	http.request(
		servidor + "guardar_progreso.php",
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		json
	)


func cargar_progreso():

	var http = HTTPRequest.new()
	add_child(http)

	var url = servidor + "obtener_progreso.php?usuario=" + usuario

	http.request(url)

	http.request_completed.connect(_on_progreso_recibido)


func _on_progreso_recibido(result, response_code, headers, body):

	var texto = body.get_string_from_utf8()

	var datos = JSON.parse_string(texto)

	if datos != null:
		nivel_actual = datos["nivel_actual"]

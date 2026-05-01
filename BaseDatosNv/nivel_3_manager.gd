extends Control

# Referencias a los nodos principales (Ajusta las rutas si tu Scene Tree es diferente)
@onready var contenedor_datos = $ContenedorDatos
@onready var tabla_usuarios = $ContenedorTablas/TablaUsuarios
@onready var tabla_contacto = $ContenedorTablas/TablaContacto
@onready var btn_validar = $BtnValidar

# Variable para llevar el estado del nivel
var nivel_terminado = false

func _ready():
	# Borrar cualquier hijo que esté previamente en la escena (opcional, para evitar duplicados)
	for child in contenedor_datos.get_children():
		child.queue_free()
		
	inicializar_datos()
	
	# Conectar el botón de validación si existe
	if btn_validar:
		btn_validar.pressed.connect(validar)
	
	# Conectar las señales de las tablas por si queremos validar automáticamente
	tabla_usuarios.dato_agregado.connect(_on_dato_agregado)
	tabla_contacto.dato_agregado.connect(_on_dato_agregado)

func inicializar_datos():
	# Generamos los datos dinámicamente y los barajamos
	var datos_a_crear = [
		{"texto": "Nombre", "tipo": "nombre"},
		{"texto": "Edad", "tipo": "edad"},
		{"texto": "Correo", "tipo": "correo"},
		{"texto": "Dirección", "tipo": "direccion"}
	]
	
	datos_a_crear.shuffle() # Desordenar para que el puzzle sea más dinámico
	
	for dato in datos_a_crear:
		crear_item(dato["texto"], dato["tipo"])

func crear_item(texto, tipo):
	# Cargar la escena de DatoArrastrable
	var item_scene = preload("res://BaseDatosNv/item_dato.tscn")
	var item = item_scene.instantiate()
	
	# Configurar el item antes de agregarlo al árbol
	item.tipo = tipo
	item.texto_mostrar = texto
	
	# Agregarlo al contenedor en la interfaz
	contenedor_datos.add_child(item)

func _on_dato_agregado(_tipo):
	# Opcional: Podrías contar cuántos datos faltan y hacer la validación automática
	# cuando no queden más datos en el ContenedorDatos.
	if contenedor_datos.get_child_count() <= 1: # 1 porque el queue_free tarda un frame en limpiar el nodo
		call_deferred("validar")

# =========================
# VALIDACIÓN DEL NIVEL
# =========================
func validar():
	if nivel_terminado: return
	
	var todos_los_datos_procesados = true
	var hay_errores = false
	
	# 1. Validar Tabla Usuarios
	for dato in tabla_usuarios.datos_recibidos:
		if not dato in tabla_usuarios.tipos_validos:
			hay_errores = true
	
	# Comprobar que tengan los datos necesarios y no falte ninguno
	var usuarios_completo = ("nombre" in tabla_usuarios.datos_recibidos and "edad" in tabla_usuarios.datos_recibidos)
	
	# 2. Validar Tabla Contacto
	for dato in tabla_contacto.datos_recibidos:
		if not dato in tabla_contacto.tipos_validos:
			hay_errores = true
			
	var contacto_completo = ("correo" in tabla_contacto.datos_recibidos and "direccion" in tabla_contacto.datos_recibidos)
	
	# 3. Validar si todo es correcto
	if usuarios_completo and contacto_completo and not hay_errores:
		print("¡Nivel completado! Todos los datos están en sus tablas correspondientes.")
		nivel_terminado = true
		GameManager.completar_nivel()
		# Aquí podrías mostrar una pantalla de victoria o cargar el siguiente nivel
	else:
		if hay_errores:
			print("¡Incorrecto! Hay datos en las tablas equivocadas.")
		else:
			print("Aún faltan datos por clasificar.")

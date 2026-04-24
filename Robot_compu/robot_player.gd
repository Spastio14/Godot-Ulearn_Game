extends CharacterBody2D

const SPEED = 200
const JUMP_FORCE = -495
const GRAVITY = 900

var instrucciones = []
var ejecutando = false
var indice = 0
var tiempo_accion = 0.0

func _physics_process(delta):

	# gravedad
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# ejecutar instrucciones
	if ejecutando:

		tiempo_accion -= delta

		if tiempo_accion <= 0:
			siguiente_instruccion()

	move_and_slide()


func ejecutar_instrucciones(lista):

	instrucciones = lista.duplicate()
	indice = 0
	ejecutando = true

	siguiente_instruccion()


func siguiente_instruccion():

	if indice >= instrucciones.size():

		ejecutando = false
		velocity.x = 0
		return

	var inst = instrucciones[indice]

	if inst == "derecha":
		velocity.x = SPEED
		tiempo_accion = 0.4

	elif inst == "izquierda":
		velocity.x = -SPEED
		tiempo_accion = 0.4

	elif inst == "saltar":
		if is_on_floor():
			velocity.y = JUMP_FORCE
		tiempo_accion = 0.4

	indice += 1

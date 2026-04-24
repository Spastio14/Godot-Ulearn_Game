extends Area2D

signal nivel_completado

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("robot"):
		print("Algo entró:", body.name)
	
	if body.is_in_group("robot"):
		print("Robot detectado")
		print("Nivel completado")
		nivel_completado.emit()

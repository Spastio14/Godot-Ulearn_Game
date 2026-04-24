extends Area2D

signal llave_recogida

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):

	if body.is_in_group("robot"):
		llave_recogida.emit()
		queue_free()

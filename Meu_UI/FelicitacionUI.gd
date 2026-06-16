extends CanvasLayer

signal cerrada

@onready var panel_container: PanelContainer = $Control/PanelContainer
@onready var overlay: ColorRect = $Control/ColorRect
@onready var label_main: Label = $Control/PanelContainer/MarginContainer/VBoxContainer/LabelMain
@onready var label_user: Label = $Control/PanelContainer/MarginContainer/VBoxContainer/LabelUser
@onready var label_score: Label = $Control/PanelContainer/MarginContainer/VBoxContainer/LabelScore
@onready var label_extra: Label = $Control/PanelContainer/MarginContainer/VBoxContainer/LabelExtra
@onready var label_rank: Label = $Control/PanelContainer/MarginContainer/VBoxContainer/LabelRank
@onready var button_close: Button = $Control/ButtonClose

func _ready() -> void:
	# Inicializar invisible y escalado pequeño
	panel_container.scale = Vector2(0.7, 0.7)
	panel_container.modulate.a = 0
	overlay.color.a = 0
	
	# Conectar señal de botón
	button_close.pressed.connect(_on_button_close_pressed)

func configurar(resultado: Dictionary, usuario: String) -> void:
	label_user.text = "BUEN TRABAJO, " + usuario.to_upper()
	label_score.text = "Puntaje: " + str(resultado.get("porcentaje", 0)) + " / 100"
	label_extra.text = "Eficiencia: %d%% | Tasa de éxito: %d%%" % [resultado.get("eficiencia", 0), resultado.get("tasa_exito", 0)]
	label_rank.text = resultado.get("clasificacion", "")
	
	# Animación de entrada
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(overlay, "color:a", 0.7, 0.4)
	tween.tween_property(panel_container, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel_container, "modulate:a", 1.0, 0.3)

func _on_button_close_pressed() -> void:
	cerrar()

func cerrar() -> void:
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(overlay, "color:a", 0.0, 0.3)
	tween.tween_property(panel_container, "scale", Vector2(0.7, 0.7), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(panel_container, "modulate:a", 0.0, 0.2)
	await tween.finished
	cerrada.emit()
	queue_free()

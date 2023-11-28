extends Control

@onready var sensislider:HSlider = $Panel/GeneralOptions/SensiSlider
@onready var defaultEnvi:Environment = load("res://enviroments/Default.tres")
@onready var blankEnvi:Environment = load("res://enviroments/BLANK.tres")
var blackenvi:bool = false

func _ready():
	sensislider.value = Settings.MOUSE_SENSITIVITY

func _on_close_button_pressed():
	Settings.MOUSE_SENSITIVITY = sensislider.value
	queue_free()

func _on_black_envi_button_pressed():
	get_tree().current_scene.get_node("WorldEnvironment").environment = blankEnvi

func _on_default_envi_button_pressed():
	get_tree().current_scene.get_node("WorldEnvironment").environment = defaultEnvi

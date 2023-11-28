extends Control

@onready var options_packed:PackedScene = preload("res://controls/ui_options.tscn")

func _ready():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_resume_button_pressed():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	queue_free()

func _on_quit_button_pressed():
	get_tree().quit(0)

func _on_options_button_pressed():
	var op = options_packed.instantiate()
	add_child(op)

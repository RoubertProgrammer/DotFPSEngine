extends CharacterBody3D

var speed:float = 3.0

@onready var player:CharacterBody3D = get_tree().current_scene.get_node("Player")
@onready var nav_agent:NavigationAgent3D = $NavAgent

func _ready():
	nav_agent.get_navigation_map()

func _physics_process(_delta):
	update_target_location(player)
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized()
	
	velocity = new_velocity * speed
	
	move_and_slide()

func update_target_location(target:Node):
	nav_agent.set_target_position(target.global_transform.origin)
	

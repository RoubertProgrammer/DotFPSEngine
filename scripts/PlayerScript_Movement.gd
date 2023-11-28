extends CharacterBody3D


const JUMP_VELOCITY:float = 4.5
const DEACCEL:float = 0.15
const CROUCH_SPEED:float = 0.3

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var SPEED:float = 5.0
var fvalue:int = 0
var findex:int = 0
var fspeed:int = 40
var is_crouching:bool = Input.is_action_pressed("crouch")
var is_running:bool = Input.is_action_pressed("run") or is_crouching

@onready var crouch_ray:RayCast3D = $Crouch
@onready var flashlight:SpotLight3D = $ViewYAxis/EyesPlayer/FlashLight
@onready var pcontrol_packed:PackedScene = preload("res://controls/ui_pause.tscn")
@onready var gscontrol_packed:PackedScene = preload("res://controls/gui_stats.tscn")
@onready var faudio:AudioStreamPlayer3D = $footsteps
@onready var view_y_axis:Node3D = $ViewYAxis
@onready var eyes:Camera3D = $ViewYAxis/EyesPlayer
@onready var fconcrete:Array = [
	load("res://sounds/concrete1.wav"),
	load("res://sounds/concrete2.wav"),
	load("res://sounds/concrete3.wav"),
	load("res://sounds/concrete4.wav")
]

func _ready():
	if not GameStats.is_alive:
		return
	var gs = gscontrol_packed.instantiate()
	get_tree().current_scene.add_child.call_deferred(gs)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if not GameStats.is_alive:
		return
	if event is InputEventMouseMotion:
		view_y_axis.rotate_y(-(event.relative.x * Settings.MOUSE_SENSITIVITY))
		eyes.rotate_x(-(event.relative.y * Settings.MOUSE_SENSITIVITY))
		eyes.rotation.x = clamp(eyes.rotation.x,deg_to_rad(-90),deg_to_rad(90))
	pass

func _physics_process(delta):
	if not GameStats.is_alive:
		velocity.y = JUMP_VELOCITY
		death(delta)
		return
	is_crouching = Input.is_action_pressed("crouch") or crouch_ray.is_colliding()
	is_running = Input.is_action_pressed("run") or is_crouching
	
	if not is_on_floor():
		# SPEED += DEACCEL
		velocity.y -= gravity * delta
	else:
		if is_running:
			SPEED = 5.0
			fspeed = 40
		else:
			SPEED = 10.0
			fspeed = 25
	
	if (fvalue % fspeed) == 1 and (is_on_floor() and not is_on_wall()):
		footstep()
	
	if Input.is_action_pressed("jump") and (is_on_floor() and not is_crouching):
		velocity.y = JUMP_VELOCITY
	
	if is_crouching:
		$Collision.scale.y = 0.25
	else:
		$Collision.scale.y = 1
	
	if Input.is_action_just_pressed("pause"):
		var a = pcontrol_packed.instantiate()
		get_tree().current_scene.add_child(a)
	
	if Input.is_action_just_pressed("flashlight"):
		flashlight.visible = !flashlight.visible
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (view_y_axis.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	eyes.rotation.z = deg_to_rad(lerpf(eyes.rotation_degrees.z,-4 * input_dir.x,0.075))
	
	if direction:
		fvalue += 1
		velocity.x = lerpf(velocity.x, direction.x * SPEED, DEACCEL)
		velocity.z = lerpf(velocity.z, direction.z * SPEED, DEACCEL)
	else:
		fvalue = 0
		velocity.x = lerpf(velocity.x, 0, DEACCEL)
		velocity.z = lerpf(velocity.z, 0, DEACCEL)

	move_and_slide()

func footstep():
	$footsteps.pitch_scale = randf_range(1.0,1.25)
	$footsteps.stream = fconcrete[findex]
	$footsteps.play()
	if findex >= 3:
		findex = 0
	else:
		findex += 1

func death(dt:float):
	rotation.z = deg_to_rad(90)
	if Input.is_action_just_pressed("use"):
		GameStats.revive_player()
		get_tree().reload_current_scene()


func _on_player_area_entered(area):
	if area.name == "DeathArea":
		GameStats.health = 0

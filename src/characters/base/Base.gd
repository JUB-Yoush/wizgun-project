extends KinematicBody2D

export var speed:float = 300.0
export var jump_str:float = 500.0
export (float,0,1.0) var friction = 0.2
export (float,0,1.0) var acceleration = 0.2
export var gravity:float = 25
const MAX_GRAVITY = 2000
const UP = Vector2.UP

enum Staes {
	IDLE,
	RUNNING,
	IN_AIR
	}

var dir = Vector2.ZERO
var velocity = Vector2.ZERO
var _state = Staes.IDLE

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	update_dir()
	jump()
	move(delta)
	
	
	
	
func move(delta):
	if dir.x != 0:
		velocity.x = lerp(velocity.x, dir.x * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0,friction)
		
	velocity.y = min(velocity.y + gravity,MAX_GRAVITY)
	velocity = move_and_slide(velocity,UP)
	
func update_dir():
	dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	dir.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	

func jump():
	var is_jumping:= is_on_floor() and Input.is_action_just_pressed("jump")
	if is_jumping:
		velocity.y = -jump_str
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = lerp(velocity.y, 0, 0.5)

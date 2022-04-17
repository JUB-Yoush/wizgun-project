extends KinematicBody2D

var speed:float = 350.0
var jump_str:float = 750.0
var gravity:float = 30
const MAX_GRAVITY = 2000


var dir = Vector2.ZERO
var velocity = Vector2.ZERO
const UP = Vector2.UP

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	update_dir()
	jump()
	print(velocity.y)
	velocity.x = dir.x * speed
	velocity.y += gravity
	if velocity.y >= MAX_GRAVITY:
		velocity.y = MAX_GRAVITY
	velocity = move_and_slide(velocity,UP)
	
	
	

func update_dir():
	dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	dir.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	

func jump():
	var is_jumping:= is_on_floor() and Input.is_action_pressed("jump")
	if is_jumping:
		velocity.y = -jump_str
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = lerp(velocity.y, 0, 0.5)

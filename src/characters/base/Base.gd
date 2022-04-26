extends KinematicBody2D

export var speed:float = 300.0
export var jump_str:float = 500.0
export (float,0,1.0) var friction = 0.2
export (float,0,1.0) var acceleration = 0.2
export var gravity:float = 25
export var slash_speed:float = 200
const MAX_GRAVITY = 2000
const UP = Vector2.UP

enum States {
	ON_GROUND,
	SLIDING,
	SLASHING,
	SHOOTING,
	IN_AIR,
	AIRDODGE
	}
func on_ground(delta):
	jump()
	move(delta)

func sliding(delta):
	pass

func slashing(delta):
	pass

func shooting(delta):
	pass

func in_air(delta):
	move(delta)
	if is_on_floor():
		_state = States.ON_GROUND

var dir = Vector2.ZERO
var velocity = Vector2.ZERO
var _state = States.ON_GROUND

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	update_dir()
	match _state:
		States.ON_GROUND:
			on_ground(delta)
		States.SLIDING:
			sliding(delta)
		States.IN_AIR:
			in_air(delta)
		States.SHOOTING:
			shooting(delta)
		States.SLASHING:
			shooting(delta)
	
	print(_state)
			
	
	
	
func move(delta):
	if dir.x != 0:
		velocity.x = lerp(velocity.x, dir.x * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0,friction)
		
	velocity.y = min(velocity.y + gravity,MAX_GRAVITY)
	velocity = move_and_slide(velocity,UP)
	
func update_dir():
	dir.x = Input.get_action_strength("p1_right") - Input.get_action_strength("p1_left")
	dir.y = Input.get_action_strength("p1_down") - Input.get_action_strength("p1_up")
	

func jump():
	var is_jumping:bool = Input.is_action_just_pressed("p1_jump") and dir.y <= 0
	if is_jumping:
		velocity.y = -jump_str
		_state = States.IN_AIR
		
	if Input.is_action_just_released("p1_jump") and velocity.y < 0:
		velocity.y = lerp(velocity.y, 0, 0.5)

func slide():
	if Input.is_action_just_pressed("p1_jump") and dir.y > 0:
		pass #slide


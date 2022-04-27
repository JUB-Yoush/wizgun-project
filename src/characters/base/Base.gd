extends KinematicBody2D

export var speed:float = 300.0
export var jump_str:float = 500.0
export (float,0,1.0) var friction = 0.2
export (float,0,1.0) var acceleration = 0.2
export var gravity:float = 25
export var slash_speed:float = 200

export var slide_speed:float = 600
var slide_velocity:Vector2 = Vector2.ZERO
export var slide_friction:float = 20



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


var dir = Vector2.ZERO
var last_dir = Vector2.ZERO
var velocity = Vector2.ZERO
var _state = States.ON_GROUND

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	match _state:
		States.ON_GROUND:
			on_ground(delta)
		States.SLIDING:
			var dir_at_press = last_dir
			sliding(delta,dir_at_press)
		States.IN_AIR:
			in_air(delta)
		States.SHOOTING:
			shooting(delta)
		States.SLASHING:
			slashing(delta)
	
	#print(_state)
			
	
# STATES ---------------------------------------------------------
func on_ground(delta):
	update_dir()
	jump()
	move(delta)
	slide()

func sliding(delta:float,passed_in_dir:Vector2):
	velocity.x = slide_velocity.x 
	slide_velocity.x = abs(slide_velocity.x - slide_friction) 
	velocity.y = min(velocity.y + gravity,MAX_GRAVITY)
	velocity.x = velocity.x * passed_in_dir.x
	velocity = move_and_slide(velocity,UP)
	if slide_velocity.x == 0:
		_state = States.ON_GROUND
	
	
	
func slashing(delta):
	pass

func shooting(delta):
	pass

func in_air(delta):
	update_dir()
	move(delta)
	if is_on_floor():
		_state = States.ON_GROUND


# COMPONENTS ---------------------------------------------------------

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
	if dir.x != 0:
		last_dir.x = dir.x
	
	

func jump():
	#print(dir.y)
	var is_jumping:bool = Input.is_action_just_pressed("p1_jump") and dir.y <= 0
	if is_jumping:
		velocity.y = -jump_str
		_state = States.IN_AIR
		
	if Input.is_action_just_released("p1_jump") and velocity.y < 0:
		velocity.y = lerp(velocity.y, 0, 0.5)

func slide():
	if Input.is_action_just_pressed("p1_jump") and dir.y == 1:
		slide_velocity.x = slide_speed
		_state = States.SLIDING


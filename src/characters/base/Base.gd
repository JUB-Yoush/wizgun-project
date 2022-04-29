extends KinematicBody2D
# MOVEMENT ----------------------------------------
export var speed:float = 300.0
export var max_speed:Vector2 = Vector2(1500,1500)
export var jump_str:float = 500.0
export (float,0,1.0) var friction = 0.2
export (float,0,1.0) var acceleration = 0.2
export var gravity:float = 25
const MAX_GRAVITY = 2000
const UP = Vector2.UP


# SLIDING --------------------------------
export var slide_speed:float = 600
var slide_velocity:Vector2 = Vector2.ZERO
export var slide_friction:float = 20
export var slide_stop_speed:float = 30


#SHOOTING ------------------------------
export var gun_recoil:Vector2 = Vector2(500,500)


#SLASHING -----------------------------
export var slash_speed:float = 200


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
	#universal speed cap
	
	match _state:
		States.ON_GROUND:
			state_on_ground(delta)
		States.SLIDING:
			var dir_at_press = last_dir
			state_sliding(delta,dir_at_press)
		States.IN_AIR:
			state_in_air(delta)
		States.SHOOTING:
			var dir_at_press = last_dir
			state_shooting(delta,dir_at_press)
		States.SLASHING:
			state_slashing(delta)
	
	#print(_state)
			
	
# STATES ---------------------------------------------------------
func state_on_ground(delta):
	update_dir()
	jump()
	move(delta)
	slide()
	shoot()

func state_sliding(delta:float,passed_in_dir:Vector2):
	velocity.x = slide_velocity.x 
	slide_velocity.x = abs(slide_velocity.x - slide_friction) 
	velocity.y = min(velocity.y + gravity,MAX_GRAVITY)
	velocity.x = velocity.x * passed_in_dir.x
	velocity = move_and_slide(velocity,UP)
	if slide_velocity.x <= slide_stop_speed:
		print("--ground--")
		_state = States.ON_GROUND
	
	
	
func state_slashing(delta):
	pass

func state_shooting(delta:float,dir_at_press:Vector2):
	# make it fire a projectile (easy part)
	
	#prioritize up and down aiming over left and right
	var aiming_dir:Vector2 = Vector2.ZERO
	if dir.y == 0:
		aiming_dir.x = dir.x
	else:
		aiming_dir.y = dir.y
	print(gun_recoil * -dir)
	velocity += gun_recoil * -aiming_dir
	_state = States.ON_GROUND
	pass

func state_in_air(delta):
	update_dir()
	move(delta)
	shoot()
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
		print("--slide--")
		slide_velocity.x = slide_speed
		_state = States.SLIDING

func shoot():
	if Input.is_action_just_pressed("p1_gun"):
		_state = States.SHOOTING
		

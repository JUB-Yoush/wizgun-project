extends KinematicBody2D
class_name CharacterBase

# CONTROLS ----------------------------------------
var input_left:String
var input_right:String
var input_up:String
var input_down:String

var input_jump:String
var input_gun:String
var input_sword:String

var player_tag:String

# MOVEMENT ----------------------------------------
export var speed:float = 300.0
export var max_speed:Vector2 = Vector2(1500,1500)
export var jump_str:float = 500.0
export (float,0,1.0) var friction = 0.2
export (float,0,1.0) var air_friction = 0.02
export (float,0,1.0) var acceleration = 0.2
export var gravity:float = 25
const MAX_GRAVITY = 1000
const UP = Vector2.UP

# SLIDING --------------------------------
export var slide_speed:float = 650
var slide_velocity:Vector2 = Vector2.ZERO
export var slide_friction:float = 25
export var slide_stop_speed:float = 100


#SHOOTING ------------------------------
export var Projectile:PackedScene = preload("res://src/characters/base/Projectile.tscn")
export var gun_recoil:Vector2 = Vector2(500,500)
onready var gunCooldown = $GunCooldown
export var ammo = 99
var gun_cool_time:float = 0.3
var gun_cooling = false

#SLASHING -----------------------------
export var slash_speed:Vector2 = Vector2(1000,750)
var velocity_at_press:Vector2 = Vector2.ZERO
export var slash_time:int = 0
export var slash_active_frames:int = 6
var slashed_in_jump:bool = false

# SLASH ENDLAG
export var slash_recovery_frames:int = 15

# states for state machine
enum States {
	ON_GROUND,
	SLIDING,
	SLASHING,
	SHOOTING,
	IN_AIR,
	SLASH_ENDLAG
	}


var dir = Vector2.ZERO
var last_dir = Vector2.ZERO
var velocity = Vector2.ZERO
var _state = States.ON_GROUND

func _ready():
	gunCooldown.connect("timeout",self,"on_gunCooldown_timeout")
	

func _physics_process(delta):
	#print(_state)
	#Finite state machine
	match _state:
		States.ON_GROUND:
			state_on_ground(delta)
		States.SLIDING:
			state_sliding(delta,last_dir)
		States.IN_AIR:
			state_in_air(delta)
		States.SHOOTING:
			state_shooting(delta,last_dir)
		States.SLASHING:
			state_slashing(delta,last_dir)
		States.SLASH_ENDLAG:
			state_slash_endlag()
	
	#print(_state)
			
	
# STATES ---------------------------------------------------------
func state_on_ground(delta):
	slashed_in_jump = false
	if is_on_floor() == false: _state = States.IN_AIR
	update_dir()
	jump()
	move(delta)
	slide()
	shoot()
	slash()
	
	
	
func state_sliding(delta:float, passed_in_dir:Vector2):
	if is_on_floor() == false: _state = States.IN_AIR
	#set to slide then set back to on ground when min speed reached
	velocity.x = slide_velocity.x 
	slide_velocity.x = abs(slide_velocity.x - slide_friction) 
	velocity.y = min(velocity.y + gravity,MAX_GRAVITY)
	velocity.x = velocity.x * passed_in_dir.x
	velocity = move_and_slide(velocity,UP)
	if slide_velocity.x <= slide_stop_speed:
		_state = States.ON_GROUND
	
	
	
func state_slashing(delta,dir_at_press:Vector2):
	#get cardinal dir
	var slashing_dir:Vector2 = Vector2.ZERO
	if dir_at_press.y == 0:
		slashing_dir.x = dir_at_press.x
	else:
		slashing_dir.y = dir_at_press.y
	velocity = slashing_dir * slash_speed
	velocity = move_and_slide(velocity,UP)

	slash_time += 1
	if slash_time >= slash_active_frames:
		slash_time = 0
		_state = States.SLASH_ENDLAG
	
func state_slash_endlag():
	slash_time += 1
	if slash_time >= slash_recovery_frames:
		slash_time = 0
		velocity = Vector2.ZERO
		reset_state()
	
	

func state_shooting(delta:float,dir_at_press:Vector2):
	ammo -= 1
	#prioritize up and down aiming over left and right
	var aiming_dir:Vector2 = Vector2.ZERO
	if dir_at_press.y == 0:
		aiming_dir.x = dir_at_press.x
	else:
		aiming_dir.y = dir_at_press.y
	velocity = gun_recoil * -aiming_dir
	
	# make bullet
	var proj = Projectile.instance()
	proj.dir = aiming_dir
	proj.position = position
	
	match player_tag:
		"p1":
			proj.parent_enum = proj.PARENTS.P1
		"p2":
			proj.parent_enum = proj.PARENTS.P2
			
	get_parent().add_child(proj)
	
	reset_state()

func on_gunCooldown_timeout():
	gun_cooling = false

func state_in_air(delta):
	update_dir()
	move(delta)
	shoot()
	slash()
	if is_on_floor():
		_state = States.ON_GROUND


func reset_state():
	if is_on_floor():
		_state = States.ON_GROUND
	elif !is_on_floor():
		_state = States.IN_AIR

# STATE COMPONENTS (the stuff the player can do, each state has some of each) ---------------------------------------------------------
func update_dir():
	#checks what direction the player is holding, last_dir checks where they're facing.
	dir.x = Input.get_action_strength(input_right) - Input.get_action_strength(input_left)
	dir.y = Input.get_action_strength(input_down) - Input.get_action_strength(input_up)
	if dir.x != 0:
		last_dir.x = dir.x
	last_dir.y = dir.y

func move(delta):
	if dir.x != 0:
		velocity.x = lerp(velocity.x, dir.x * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0,friction)
		
	velocity.y = min(velocity.y + gravity,MAX_GRAVITY)
	velocity = move_and_slide(velocity,UP)

func jump():
	var is_jumping:bool = Input.is_action_just_pressed(input_jump) and dir.y <= 0
	if is_jumping:
		velocity.y = -jump_str
		_state = States.IN_AIR
		
	if Input.is_action_just_released(input_jump) and velocity.y < 0:
		velocity.y = lerp(velocity.y, 0, 0.5)

func slide():
	if Input.is_action_just_pressed(input_jump) and dir.y == 1:
		slide_velocity.x = slide_speed
		_state = States.SLIDING

func shoot():
	if Input.is_action_just_pressed(input_gun) and ammo > 0 and gun_cooling == false:
		gunCooldown.start(gun_cool_time)
		gun_cooling = true
		_state = States.SHOOTING
		
func slash():
	if Input.is_action_just_pressed(input_sword) and slashed_in_jump == false:
		slashed_in_jump = true
		_state = States.SLASHING

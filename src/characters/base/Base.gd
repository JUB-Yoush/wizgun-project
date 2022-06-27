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

# CHILD NODES ---------------------------------------
onready var hitbox := $Hitbox
onready var sprite := $Sprite
onready var gun := $Gun
onready var gunSprite := $Gun/GunSprite
onready var gunFlashSprite := $Gun/GunSprite/GunFlash
onready var animPlayer := $AnimationPlayer
onready var area := $Area2D
onready var slashBox = $Slashbox


# RESPAWNING ---------------------------------------	 
var is_alive:bool = true
var respawn_time:float = 2

# MOVEMENT ----------------------------------------

export var speed:float = 200.0
export var max_speed:Vector2 = Vector2(1500,1500)
export var jump_str:float = 425.0
export (float,0,1.0) var friction = 0.2
export (float,0,1.0) var air_friction = 0.02
export (float,0,1.0) var acceleration = 0.2
export var gravity:float = 25
const MAX_GRAVITY = 1000
const UP = Vector2.UP

# SLIDING --------------------------------
export var slide_speed:float = 350
var slide_velocity:Vector2 = Vector2.ZERO
export var slide_friction:float = 15
export var slide_stop_speed:float = 75
var slidingHitbox := load("res://src/characters/base/SlidingHitbox.tres")
var standingHitbox := load("res://src/characters/base/StandingHitbox.tres")

#SHOOTING ------------------------------
export var Projectile:PackedScene = preload("res://src/characters/base/Projectile.tscn")
export var gun_recoil:Vector2 = Vector2(400,400)
#onready var gunCooldown = $GunCooldown
export var ammo = 99
var has_gun := true
var gun_cool_time:float = 0.3
var gun_cooling := false

#SLASHING -----------------------------
export var slash_speed:Vector2 = Vector2(700,500)
var velocity_at_press:Vector2 = Vector2.ZERO
var slash_time:int = 0
export var slash_active_frames:int = 5
export var slash_active_time:float = (59/60)
#onready var slashActiveTimer: = get_tree().create_timer(slash_active_time)
var sat_timer_started = false
var slashed_in_jump:bool = false

# SLASH ENDLAG --------------------------------
export var slash_recovery_frames:int = 20
export var slash_recovery_time:float = 15/60
onready var slashRecoveryTimer: = get_tree().create_timer(slash_recovery_time)
var srt_timer_started = false

# SLASH BOUCEBACK --------------------------------
export var slash_bb_frames:int = 5
export var slash_bb_speed:Vector2 = Vector2(700,500)


# HITSTOP ----------------------------------------
var time_scale = 0.03
var duration = 0.7
signal start_hitstop(time_scale, duration)

# COLLISIONS -------------------------------------


# states for state machine
enum States {
	ON_GROUND,
	SLIDING,
	SLASHING,
	SHOOTING,
	IN_AIR,
	SLASH_ENDLAG,
	RESPAWNING,
	SLASH_BOUCEBACK,
	HITSTOP	
	}


var dir = Vector2.ZERO
var last_dir = Vector2.ZERO
var velocity = Vector2.ZERO
var _state = States.ON_GROUND

func _ready():
	#gunCooldown.connect("timeout",self,"on_gunCooldown_timeout")
	#respawnTimer.connect("timeout",self,"on_respawnTimer_timeout")
	connect("start_hitstop",get_parent(),"make_hitstop")
	area.connect("area_entered",self,"on_area_entered")
	slashBox.connect("area_entered",self,"on_area_entered")
	#area.connect("area_entered",self,"on_area_entered")
	

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
		States.RESPAWNING:
			state_respawning()
		States.HITSTOP:
			state_hitstop()
		States.SLASH_BOUCEBACK:
			state_slash_bouceback(delta,last_dir)
		
	
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
	animPlayer.play("slide")
	#set to slide then set back to on ground when min speed reached
	hitbox.shape = slidingHitbox
	hitbox.position.y = 6
	velocity.x = slide_velocity.x 
	slide_velocity.x = abs(slide_velocity.x - slide_friction) 
	velocity.y = min(velocity.y + gravity,MAX_GRAVITY)
	velocity.x = velocity.x * passed_in_dir.x
	velocity = move_and_slide(velocity,UP)
	if slide_velocity.x <= slide_stop_speed:
		hitbox.shape = standingHitbox
		hitbox.position.y = 0
		_state = States.ON_GROUND
	
	
	
func state_slashing(delta,dir_at_press:Vector2):
	#get cardinal dir
	slashBox.monitoring = true
	slashBox.monitorable = true
	animPlayer.play("slash")
	var slashing_dir:Vector2 = Vector2.ZERO
	if dir_at_press.y == 0:
		slashing_dir.x = dir_at_press.x
	else:
		slashing_dir.y = dir_at_press.y
	velocity = slashing_dir * slash_speed
	velocity = move_and_slide(velocity,UP)
	
	# var slashActiveTimer: = get_tree().create_timer(slash_active_time)
	#yield(get_tree().create_timer(slash_active_time), "timeout")
	
	slash_time += 1
	if slash_time >= slash_active_frames:
		slash_time = 0
		slashBox.monitoring = false
		slashBox.monitorable = false
		_state = States.SLASH_ENDLAG
	

func state_slash_endlag():
	animPlayer.play("slash_endlag")
	slash_time += 1
	if slash_time >= slash_recovery_frames:
		slash_time = 0
		velocity = Vector2.ZERO
		reset_state()
	
	

func state_shooting(delta:float,dir_at_press:Vector2):
	gun_cooling = true
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
			proj.parent_tag = proj.PARENTS[0]
		"p2":
			proj.parent_tag = proj.PARENTS[1]
			
	get_parent().add_child(proj)
	
	reset_state()



func state_in_air(delta):
	update_dir()
	move(delta)
	shoot()
	slash()
	
	if is_on_floor():
		_state = States.ON_GROUND
		
	if velocity.y < 0:
		animPlayer.play("air_rise")
	elif velocity.y > 0:
		animPlayer.play("air_fall")

func state_respawning():
	#set_visible(true)
	animPlayer.play("death")
	hitbox.disabled = true
	area.monitoring = false


func reset_state():
	if is_on_floor():
		_state = States.ON_GROUND
	elif !is_on_floor():
		_state = States.IN_AIR

func state_hitstop():
	pass

func state_slash_bouceback(delta,dir_at_press:Vector2):
	animPlayer.play("slash_endlag")
	var opposite_dir = dir_at_press
	if dir_at_press.y == 0:
		opposite_dir.x = dir_at_press.x
	else:
		opposite_dir.y = dir_at_press.y
	opposite_dir = opposite_dir * -1
	
	velocity = opposite_dir * slash_bb_speed
	velocity = move_and_slide(velocity,UP)
	slash_time += 1
	if slash_time >= slash_bb_frames:
		slash_time == 0
		_state = States.SLASH_ENDLAG
	
	
	


# STATE COMPONENTS ---------------------------------------------------------
func update_dir():
	#checks what direction the player is holding, last_dir checks where they're facing.
	dir.x = Input.get_action_strength(input_right) - Input.get_action_strength(input_left)
	dir.y = Input.get_action_strength(input_down) - Input.get_action_strength(input_up)
	if dir.x != 0:
		last_dir.x = dir.x
	last_dir.y = dir.y
	
	turn_char(dir)

func move(delta):
	if dir.x != 0:
		velocity.x = lerp(velocity.x, dir.x * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0,friction)
		
	velocity.y = min(velocity.y + gravity,MAX_GRAVITY)
	velocity = move_and_slide(velocity,UP)
	if velocity.x != 0:
		animPlayer.play("run")
	else:
		animPlayer.play("idle")

func jump():
	var is_jumping:bool = Input.is_action_just_pressed(input_jump) and dir.y <= 0
	if is_jumping:
		velocity.y = -jump_str
		#_state = States.IN_AIR
		
	if Input.is_action_just_released(input_jump) and velocity.y < 0:
		velocity.y = lerp(velocity.y, 0, 0.5)

func slide():
	if Input.is_action_just_pressed(input_jump) and dir.y == 1:
		slide_velocity.x = slide_speed
		_state = States.SLIDING

func shoot():
	if Input.is_action_just_pressed(input_gun) and ammo > 0 and gun_cooling == false:
		#gunCooldown.start(gun_cool_time)
		_state = States.SHOOTING
		yield(get_tree().create_timer(gun_cool_time), "timeout")
		gun_cooling = false
		
func slash():
	if Input.is_action_just_pressed(input_sword) and slashed_in_jump == false:
		slashed_in_jump = true
		_state = States.SLASHING
		
func on_player_defeat():
	is_alive = false
	_state = States.RESPAWNING
	yield(get_tree().create_timer(respawn_time), "timeout")
	#---after timer---
	is_alive = true
	var respawnPosition = get_parent().get_respawn_position()
	position = respawnPosition.position
	set_visible(true)
	hitbox.disabled = false
	area.monitoring = true
	reset_state()
	pass
#---------------------------------------------------------------------------------

func temp_hitstop_state(last_state):
	_state = States.HITSTOP
	emit_signal("start_hitstop",time_scale,duration)
	yield(get_parent(),"hitstop_over")
	_state = last_state

# COLLISIONS--------------------------------------------
func on_area_entered(area:Area2D):
	var body = area.get_parent()
	if body == null:
		pass
		
	if body.is_in_group("player") and body.player_tag != player_tag:
		
		
		if _state == States.SLASHING:
			if body._state != States.SLASHING:
				body.on_player_defeat()
			if body._state == States.SLASHING:
				slashBox.monitoring = false
				slashBox.monitorable = false
				slash_time = 0
				body.slash_time = 0
				body.slashBox.monitoring = false
				body.slashBox.monitorable = false
				_state = States.SLASH_BOUCEBACK 
				body._state = States.SLASH_BOUCEBACK 
				print('bouceback')
				pass
				

# ANIMATION --------------------------------------------
func turn_char(dir):
	if dir.x < 0:
		sprite.flip_h = true
		gunSprite.flip_h = true
		gun.rotation_degrees = 180
		#gunSprite.flip_h = true
		#gunSprite.flip_v = true
		gunFlashSprite.flip_v = true
		
	elif dir.x > 0:
		sprite.flip_h = false
		gunSprite.flip_h = false
		gun.rotation_degrees = 0
		#gunSprite.flip_v = false
		#gunFlashSprite.flip_v = false
		
	if dir.y > 0 :
		gun.rotation_degrees = 90
	elif dir.y < 0:
		gun.rotation_degrees = -90
	elif dir.y == 0:
		gun.rotation_degrees = 0
# reposition bullet spawn based on dir held

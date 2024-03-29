class_name CharacterBase
extends CharacterBody2D

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
@onready var hitbox := $Hitbox
@onready var sprite := $Sprite2D
@onready var gun := $Gun
@onready var gunSprite := $Gun/GunSprite
@onready var gunFlashSprite := $Gun/GunSprite/GunFlash
@onready var animPlayer := $AnimationPlayer
@onready var bodyArea := $BodyArea
@onready var bodyAreaHitbox := $BodyArea/AreaHitbox
@onready var slashArea = $SlashArea
@onready var timer = $Timer

@onready var wallRayR:RayCast2D = $WallRayR
@onready var wallRayL:RayCast2D = $WallRayL


# RESPAWNING ---------------------------------------	 
var is_alive:bool = true
var respawn_time:float = 2

# MOVEMENT ----------------------------------------

@export var speed:float = 125.0
@export var max_speed:Vector2 = Vector2(1500,1500)
@export var jump_str:float = 380.0
@export var ground_friction :float = 0.2
@export var air_friction:float = 0.1
@export var acceleration :float= 0.2
@export var gravity:float = 23
const MAX_GRAVITY = 500
const UP = Vector2.UP

# falling thru platforms

# SLIDING --------------------------------
@export var slide_speed:float = 350
var slide_velocity:Vector2 = Vector2.ZERO
@export var slide_friction:float = 15
@export var slide_stop_speed:float = 75
var slidingHitbox := load("res://src/characters/base/SlidingHitbox.tres")
var standingHitbox := load("res://src/characters/base/StandingHitbox.tres")

#SHOOTING ------------------------------
@export var Projectile:PackedScene = preload("res://src/characters/base/Projectile.tscn")
@export var gun_recoil:Vector2 = Vector2(300,400)
#onready var gunCooldown = $GunCooldown
@export var ammo = 99
var has_gun := true
var gun_cool_time:float = 0.3
var gun_cooling := false

#SLASHING -----------------------------
@export var slash_speed:Vector2 = Vector2(700,500)
var velocity_at_press:Vector2 = Vector2.ZERO
var slash_time:float  = 0
@export var slash_active_time:float = 1.0
var slash_frame_time := 10.0
var slashed_in_jump:bool = false
var slash_succeeded:bool = false

# SLASH ENDLAG --------------------------------
@export var slash_recovery_time:float = 5.0 

# SLASH BOUCEBACK --------------------------------
@export var slash_bb_frames:float = 5
@export var slash_bb_speed:Vector2 = Vector2(700,500)


# HITSTOP ----------------------------------------
var time_scale = 0.03
var duration = 0.7
signal start_hitstop(time_scale, duration)

#WALL JUMP ----------------------------------------------
@onready var wall_slide_speed:float = 15
@onready var wall_jump_str:Vector2 = Vector2(-400,250)
var wall_dir:Vector2 = Vector2.ZERO
@onready var MAX_WALL_SLIDE_SPEED = 40
var jumped_on_this_wall:bool = false
var last_wall_dir:Vector2

# GAMEPLAY LOOP STUFF -----------------------
var targets_scored := 0
var targets_held := 0


# COLLISIONS -------------------------------------

# DEBUG -----------------------------------------
var old_state 

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
	HITSTOP,	
	WALL_SLIDE
	}


var dir = Vector2.ZERO
var last_dir = Vector2.ZERO
var _state = States.ON_GROUND

func _ready():
	print('aha')
	start_hitstop.connect(get_parent().make_hitstop)
	bodyArea.area_entered.connect(on_area_entered)
	slashArea.area_entered.connect(on_slashArea_entered)
	timer.timeout.connect(_on_timer_timeout)

	#connect("start_hitstop",Callable(get_parent(),"make_hitstop"))
	#bodyArea.connect("area_entered",Callable(self,"on_area_entered"))
	#slashArea.connect("area_entered",Callable(self,"on_slashArea_entered"))

func _on_timer_timeout():
	print('imtasdflj')	

func _physics_process(delta: float) -> void:
	#print(velocity)
#	if old_state != _state:
#		print(str(player_tag) + "state:" +str(_state))
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
			state_slash_endlag(delta)
		States.RESPAWNING:
			state_respawning()
		States.HITSTOP:
			state_hitstop()
		States.SLASH_BOUCEBACK:
			state_slash_bouceback(delta,last_dir)
		States.WALL_SLIDE:
			state_wall_slide(delta,wall_dir)
		
	old_state = _state
			
	
func change_state(new_state:States):
	match _state:
		States.ON_GROUND:
			pass
		States.SLIDING:
			bodyAreaHitbox.shape = standingHitbox
			bodyAreaHitbox.position.y = 0
			hitbox.shape = standingHitbox
			hitbox.position.y = 0
		States.IN_AIR:
			pass
		States.SHOOTING:
			pass
		States.SLASHING:
			pass
		States.SLASH_ENDLAG:
			pass
		States.RESPAWNING:
			pass
		States.HITSTOP:
			pass
		States.SLASH_BOUCEBACK:
			pass
		States.WALL_SLIDE:
			pass
	_state = new_state

# STATES ---------------------------------------------------------
func state_on_ground(delta):
	slashed_in_jump = false
	jumped_on_this_wall = false
	if is_on_floor() == false: change_state(States.IN_AIR)
	update_dir()
	jump()
	move(delta,ground_friction)
	slide()
	shoot()
	slash()
	
	
	
func state_sliding(delta:float, passed_in_dir:Vector2):
	
	animPlayer.play("slide")
	#set to slide then set back to on ground when min speed reached
	bodyAreaHitbox.shape = slidingHitbox
	bodyAreaHitbox.position.y = 6
	hitbox.shape = slidingHitbox
	hitbox.position.y = 6
	velocity.x = slide_velocity.x 
	slide_velocity.x = abs(slide_velocity.x - slide_friction) 
	velocity.y = min(velocity.y + gravity,MAX_GRAVITY)
	velocity.x = velocity.x * passed_in_dir.x
	set_velocity(velocity)
	set_up_direction(UP)
	move_and_slide()
	velocity = velocity
	
	if is_on_floor() == false: 
		bodyAreaHitbox.shape = standingHitbox
		bodyAreaHitbox.position.y = 0
		hitbox.shape = standingHitbox
		hitbox.position.y = 0
		change_state(States.IN_AIR)
		
	if slide_velocity.x <= slide_stop_speed:
		bodyAreaHitbox.shape = standingHitbox
		bodyAreaHitbox.position.y = 0
		hitbox.shape = standingHitbox
		hitbox.position.y = 0
		change_state(States.ON_GROUND)
	
	
	
func state_slashing(delta,dir_at_press:Vector2):
	var slashing_dir:Vector2 = Vector2.ZERO
	# aim slash in cardial direction
	if dir_at_press.y == 0:
		slashing_dir.x = dir_at_press.x
	else:
		slashing_dir.y = dir_at_press.y
	match slashing_dir:
		Vector2(1,0):
			slashArea.rotation_degrees = 0
		Vector2(-1,0):
			slashArea.rotation_degrees = 180
		Vector2(0,-1):
			slashArea.rotation_degrees = 270
		Vector2(0,1):
			slashArea.rotation_degrees = 90
	
	toggle_area(slashArea,true)
	toggle_area(bodyArea,false)
	
	animPlayer.play("slash")
	
	velocity = slashing_dir * slash_speed
	set_velocity(velocity)
	set_up_direction(UP)
	move_and_slide()
	velocity = velocity
	
	slash_time += delta * slash_frame_time
	if slash_time >= slash_active_time:
		slash_time = 0
		toggle_area(slashArea,false)
		toggle_area(bodyArea,true)
		if slash_succeeded == true:
			slash_succeeded = false
			reset_state()
		else:
			change_state(States.SLASH_ENDLAG)
	

func state_slash_endlag(delta:float):
	animPlayer.play("slash_endlag")
	slash_time += delta * slash_frame_time
	if slash_time >= slash_recovery_time:
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
	var proj = Projectile.instantiate()
	proj.dir = aiming_dir
	proj.position = position
	
	match player_tag:
		"p1":
			proj.parent_tag = proj.PARENTS[0]
		"p2":
			proj.parent_tag = proj.PARENTS[1]
			
	get_parent().add_child(proj)
	
	#animPlayer.play("gun_flash")
	
	
	
	reset_state()



func state_in_air(delta):
	update_dir()
	move(delta,air_friction)
	shoot()
	slash()
	
	if is_on_floor():
		change_state(States.ON_GROUND)
		
	if velocity.y < 0:
		animPlayer.play("air_rise")
	elif velocity.y > 0:
		animPlayer.play("air_fall")
		
	if next_to_wall():
		if next_to_left_wall() and dir.x == -1 and not next_to_right_wall():
			wall_dir = Vector2.LEFT
			# if the last wall you touched was not the same direction
			if last_wall_dir != wall_dir:
				jumped_on_this_wall = false
			change_state(States.WALL_SLIDE)
			
		if next_to_right_wall() and dir.x == 1 and not next_to_left_wall():
			wall_dir = Vector2.RIGHT
			if last_wall_dir != wall_dir:
				jumped_on_this_wall = false
			change_state(States.WALL_SLIDE)

func state_respawning():
	#set_visible(true)
	velocity = Vector2.ZERO
	animPlayer.play("death")
	hitbox.disabled = true
	toggle_area(bodyArea,false)
	


func reset_state():
	if is_on_floor():
		change_state(States.ON_GROUND)
	elif !is_on_floor():
		change_state(States.IN_AIR)

func state_hitstop():
	pass

func state_slash_bouceback(delta,dir_at_press:Vector2):
	animPlayer.play("slash_endlag")
	var opposite_dir:Vector2 = Vector2.ZERO
	if dir_at_press.y == 0:
		opposite_dir.x = dir_at_press.x
	else:
		opposite_dir.y = dir_at_press.y
	opposite_dir = opposite_dir * -1
	
	velocity = opposite_dir * slash_bb_speed
	set_velocity(velocity)
	set_up_direction(UP)
	move_and_slide()
	velocity = velocity
	slash_time += 1
	if slash_time >= slash_bb_frames:
		slash_time = 0
		toggle_area(slashArea,false)
		toggle_area(bodyArea,true)
		change_state(States.SLASH_ENDLAG)
	
	
func state_wall_slide(delta:float,wall_dir:Vector2):
	update_dir()
	slash()
	last_wall_dir = wall_dir
	var is_jumping:bool = Input.is_action_just_pressed(input_jump) and dir.y <= 0
	if is_jumping and not jumped_on_this_wall:
		jumped_on_this_wall = true
		velocity += wall_jump_str
		velocity.y = -velocity.y
		velocity.x = velocity.x * wall_dir.x
		change_state(States.IN_AIR)
		
	
	if dir.x == wall_dir.x and !is_on_floor() and next_to_wall():
		velocity.y = min(velocity.y + wall_slide_speed,MAX_WALL_SLIDE_SPEED)
		set_velocity(velocity)
		set_up_direction(UP)
		move_and_slide()
		velocity = velocity
	else:
		#velocity.y += wall_slide_speed 
		change_state(States.IN_AIR)
		
	
	
	
	


# STATE COMPONENTS ---------------------------------------------------------
func update_dir():
	#checks what direction the player is holding, last_dir checks where they're facing.
	dir.x = Input.get_action_strength(input_right) - Input.get_action_strength(input_left)
	dir.y = Input.get_action_strength(input_down) - Input.get_action_strength(input_up)
	if dir.x != 0:
		last_dir.x = dir.x
	last_dir.y = dir.y
	
	turn_char(dir)

func move(delta,friction):
	if dir.x != 0:
		velocity.x = lerp(velocity.x, dir.x * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0,friction)
		
	velocity.y = min(velocity.y + gravity,MAX_GRAVITY)
	set_velocity(velocity)
	set_up_direction(UP)
	move_and_slide()
	velocity = velocity
	
	if velocity.x != 0:
		animPlayer.play("run")
	else:
		animPlayer.play("idle")

func jump():
	var is_jumping:bool = Input.is_action_just_pressed(input_jump) and dir.y <= 0
	if is_jumping:
		velocity.y = -jump_str
		#change_state(States.IN_AIR
		
	if Input.is_action_just_released(input_jump) and velocity.y < 0:
		velocity.y = lerp(velocity.y, 0.0, 0.5)

func slide():
	if Input.is_action_just_pressed(input_jump) and dir.y == 1:
		slide_velocity.x = slide_speed
		change_state(States.SLIDING)

func shoot():
	if Input.is_action_just_pressed(input_gun) and ammo > 0 and gun_cooling == false:
		#gunCooldown.start(gun_cool_time)
		change_state(States.SHOOTING)
		await get_tree().create_timer(gun_cool_time).timeout
		gun_cooling = false
		
func slash():
	if Input.is_action_just_pressed(input_sword) and slashed_in_jump == false:
		slashed_in_jump = true
		change_state(States.SLASHING)
		
func on_player_defeat():
	is_alive = false
	change_state(States.RESPAWNING)
	await get_tree().create_timer(respawn_time).timeout
	#---after timer---
	is_alive = true
	var respawnPosition = get_parent().get_respawn_position()
	position = respawnPosition.position
	set_visible(true)
	
	hitbox.disabled = false
	toggle_area(bodyArea,true)
	bodyArea.monitoring = true
	reset_state()
#---------------------------------------------------------------------------------

func temp_hitstop_state(last_state):
	change_state(States.HITSTOP)
	emit_signal("start_hitstop",time_scale,duration)
	await get_parent().hitstop_over
	change_state(last_state)

# COLLISIONS--------------------------------------------
func on_body_entered(body:PhysicsBody2D):
	print('body enter')
	if body.is_in_group("platform") and is_on_ceiling():
		print('hit head')


func on_area_entered(area:Area2D):
	print('func on_area_entered(area:Area2D):')
	var body = area.get_parent()
	
	if body == null:
		pass
		
	if body.is_in_group("player") and body.player_tag != player_tag:
		pass
		
		
func on_slashArea_entered(area:Area2D):
	print('slash area entered')
	var body = area.get_parent()
	if body.is_in_group("targets"):
		if area.is_in_group("target"):
			targets_held += 1
			slash_succeeded = true
			area.queue_free()
	
	if body == null:
		pass

	if body.is_in_group("player") and body.player_tag != player_tag:
	
		if _state == States.SLASHING:
				if body._state != States.SLASHING:
					body.on_player_defeat()
					temp_hitstop_state(_state)
					slash_succeeded = true
					
				if body._state == States.SLASHING:
					toggle_area(slashArea,false)
					slash_time = 0
					body.slash_time = 0
					body.toggle_area(slashArea,false)
					change_state(States.SLASH_BOUCEBACK)
					body.change_state(States.SLASH_BOUCEBACK) 
				
func next_to_wall():
	return next_to_right_wall() or next_to_left_wall()

func next_to_right_wall():
	if wallRayR.is_colliding():
		var collider: = wallRayR.get_collider()
		if collider.is_in_group("floor"):
			return true

func next_to_left_wall():
	if wallRayL.is_colliding():
		var collider: = wallRayL.get_collider()
		if collider.is_in_group("floor"):
			return true
	
# async functions -------------------
func scored_point():
	targets_scored+= 1
	# if at quota then win round
	pass
		
	

# ANIMATION --------------------------------------------
func turn_char(dir):
	if dir.x == 1:
		sprite.flip_h = false
		gun.rotation_degrees = 0
		gunSprite.flip_v = false
	
	if dir.x == -1:
		sprite.flip_h = true
		gun.rotation_degrees = 180
		gunSprite.flip_v = true
	
	if dir.y == 1:
		gun.rotation_degrees = 90
		
	if dir.y == -1:
		gun.rotation_degrees = 270
		
# reposition bullet spawn based on dir held

# HELPER FUNCTIONS ----------------------------------------------
func toggle_area(area:Area2D,state:bool):
	area.set_deferred("monitoring",state)
	area.set_deferred("monitorable",state)
	pass

extends Area2D

var time_scale = 0.03
var duration = 0.7

var dir:Vector2 = Vector2.ZERO
export var lifetime = 5
export var reflected_lifetime = 0.2
export var speed:float = 7
export var reflected_speed = 10
var velocity:Vector2
var reflected:bool = false
onready var visibilityNotif = $VisibilityNotifier2D
onready var lifespanTimer = $LifespanTimer

const PARENTS:Array = ["p1","p2"]
signal start_hitstop(caller,time_scale, duration)
signal hitstop_over
var parent_tag:String
# Called when the node enters the scene tree for the first time.
func _ready(): 
	connect("start_hitstop",get_parent(),"make_hitstop")
	#connect("body_entered",self,"on_body_entered")
	connect("area_entered",self,"on_area_entered")
	lifespanTimer.connect("timeout",self,"on_lifespan_timeout")
	lifespanTimer.start(lifetime)
	visibilityNotif.connect("screen_exited",self,"exited_screen")
	if parent_tag == PARENTS[0]:
		set_modulate("#1b22d3")
	elif parent_tag ==  PARENTS[1]:
		set_modulate("#d31b1b")
	
	match dir:
		Vector2(1,0):
			position.x += 25
			$Sprite.rotation_degrees = 0
			$CollisionShape2D.rotation_degrees = 0
			$Sprite.set_flip_h(false)
		Vector2(-1,0):
			position.x -= 25
			$Sprite.rotation_degrees = 0
			$CollisionShape2D.rotation_degrees = 0
			$Sprite.set_flip_h(true)
		Vector2(0,1):
			position.y += 25
			$Sprite.rotation_degrees = 90
			$CollisionShape2D.rotation_degrees = 90
		Vector2(0,-1):
			position.y -= 25
			$Sprite.rotation_degrees = 270
			$CollisionShape2D.rotation_degrees = 270
			
func _physics_process(delta):
	velocity = speed * dir
	position += velocity
	pass

func exited_screen():
	queue_free()

func on_lifespan_timeout():
	queue_free()
	

func on_area_entered(area:Area2D):
	print(area.name)
	if area.is_in_group("projectile"):
		if area.reflected == false:
			area.queue_free()
		if reflected == false:
			queue_free()
			
		
		
	var body = area.get_parent()
	if body == null:
		pass
	
	
	elif body.is_in_group("player"):
		print(body._state)
		if body._state == body.States.SLASHING:
				reflect(body)
				
		elif body.player_tag != parent_tag:
				body.on_player_defeat()
	
	
func reflect(body:KinematicBody2D):
	reflected = true
	dir = Vector2.ZERO
	set_modulate("#ffffff")
	body.temp_hitstop_state(body._state)
	emit_signal("start_hitstop",time_scale, duration)
	yield(get_parent(),"hitstop_over")
	set_modulate("#10940f")
	
	if parent_tag != body.player_tag:
		if parent_tag == PARENTS[1]: parent_tag = PARENTS[0]
		elif parent_tag ==  PARENTS[0]: parent_tag = PARENTS[1]
	dir = body.last_dir
	speed += reflected_speed
	lifespanTimer.start(reflected_lifetime)
	

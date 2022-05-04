extends Area2D

var time_scale = 0.03
var duration = 0.7

var dir:Vector2 = Vector2.ZERO
var lifetime = 5
export var speed:float = 10
export var reflected_speed = 5
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
	connect("body_entered",self,"on_body_entered")
	lifespanTimer.connect("timeout",self,"on_lifespan_timeout")
	lifespanTimer.start(lifetime)
	visibilityNotif.connect("screen_exited",self,"exited_screen")
	if parent_tag == PARENTS[0]:
		set_modulate("#1b22d3")
	elif parent_tag ==  PARENTS[1]:
		set_modulate("#d31b1b")
	
	match dir:
		Vector2(0,1):
			$Sprite.rotation_degrees = 0
			$CollisionShape2D.rotation_degrees = 0
			$Sprite.set_flip_h(false)
		Vector2(0,-1):
			$Sprite.rotation_degrees = 0
			$CollisionShape2D.rotation_degrees = 0
			$Sprite.set_flip_h(true)
		Vector2(1,0):
			$Sprite.rotation_degrees = 90
			$CollisionShape2D.rotation_degrees = 90
		Vector2(-1,0):
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
	

func on_body_entered(body:PhysicsBody2D):
	if body == null:
		pass
	else:
		if body.player_tag == parent_tag:

			pass
		elif body.player_tag != parent_tag:
			if body._state == body.States.SLASHING:
				reflect(body)
			else:
				body.on_player_defeat()
				
			
	
func on_area_entered(area:Area2D):
	print(area.name)
	
func reflect(body:KinematicBody2D):
	dir = Vector2.ZERO
	set_modulate("#ffffff")
	emit_signal("start_hitstop",self, time_scale, duration)
	#make_hitstop(time_scale, duration)
	yield(get_parent(),"hitstop_over")
	set_modulate("#10940f")
	if parent_tag == PARENTS[1]: parent_tag = PARENTS[0]
	elif parent_tag ==  PARENTS[0]: parent_tag = PARENTS[1]
	dir = body.last_dir
	speed += reflected_speed
	

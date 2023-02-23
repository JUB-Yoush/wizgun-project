extends Area2D

onready var timer := $Timer

var body_present:PhysicsBody2D = null
var delivery_time := 1.0
var two_bodies_present := false
func _ready() -> void:
	timer.wait_time = delivery_time
	connect("body_entered",self,"on_body_entered")
	connect("body_exited",self,"on_body_exited")


func on_body_entered(body):
	if body_present == null:
		body_present = body
		start_delivery()
	else:
		two_bodies_present = true
		timer.stop()

func on_body_exited(body):
	# if one body left then make it the active one, if no bodies then set to null
	if two_bodies_present:
		if get_overlapping_bodies()[0] != null:
			body_present = get_overlapping_bodies()[0]
		start_delivery()
	else:
		body_present = null
		timer.stop()

func start_delivery():
	timer.wait_time = delivery_time
	if timer.is_stopped():
		timer.start()

	
func _physics_process(delta: float) -> void:
	prints("basket time:",timer.time_left,timer.is_stopped(),two_bodies_present)

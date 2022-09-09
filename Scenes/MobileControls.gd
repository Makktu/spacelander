extends Node2D

signal swiped(direction)
signal swipe_cancel(start_position)

export(float, 1.0, 1.5) var MAX_DIAGONAL = 1.3

onready var timer = $Timer

var swipe_start_pos = Vector2()

func _input(event):
	if not event is InputEventScreenTouch:
		return
	if event.pressed:
		start_detection(event.position)
	elif not timer.is_stopped():
		end_detection(event.position)
		
func start_detection(position):
	swipe_start_pos = position
	timer.start()
	
func end_detection(position):
	timer.stop()
	var direction = (position - swipe_start_pos).normalized()
	if abs(direction.x) + abs(direction.y) >= MAX_DIAGONAL:
		return
		
	if abs(direction.x) > abs(direction.y):
		emit_signal("swiped", Vector2(-sign(direction.x), 0.0))
	else:
		emit_signal("swiped", Vector2(0.0, -sign(direction.x)))

func _on_Timer_timeout():
	emit_signal("swipe_cancel", swipe_start_pos)


func _on_MobileControls_swiped(direction):
#	print(direction.x, "___", direction.y)
	if (direction.x == 1):
		print("LEFT")
	if (direction.y == 1):
		print("UP")
	if (direction.x == -1):
		print("RIGHT")
	if (direction.y == -1):
		print("DOWN")
		
#  -1   0  ==  right
#   1   0  ==  left
#   0  -1  ==  down
#   0   1  ==  up
	
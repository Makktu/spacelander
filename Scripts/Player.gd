extends KinematicBody2D

onready var Swipe = $Camera2D/SwipeScreenButton

var just_starting = true
var shake_amount = 1
var down_thrust = 0
var camera_shake_toggle = true
var rocket_whoosh = false

# initialise swipe control variables
var swipe_up = false
var swipe_down = false
var swipe_left = false
var swipe_right = false

var swipe_down_released = false
var swipe_up_released = false
var swipe_left_released = false
var swipe_right_released = false
#####################################

var level_coords = [[665, -1182], [8045, -3239], [9858, 306]]

var input_dir = 0
var y_input_dir = 0

var FUEL = 3000
var FUEL_POD = 5000
var fuel_base_usage = 5
var fuel_alarm_threshold = 500
var fuel_alert_played = false

var gameOver = false
var middleOn = false
var no_fuel = false
var speed = 0
var constant_speed = 10

# THRUSTER VALUES:
var side_thrust = 10
var bottom_thrust = 20
var top_thrust = 10

# GLOBAL PHYSICS VALUES:
var acceleration = 1
var gravity = 0
var velocity = Vector2.ZERO
var friction = 0.0
var max_speed = 50



func game_over():
	gameOver = true
	$Light2D/AnimationPlayer.play("a_thousand-suns")
	$Camera2D.game_over_zoom_out()
	$ThrustersOther.stop()
	$Thrusters.stop()
	$TopThrusters.stop()
	$TopThrusters.visible = false
	$LeftThrusters.stop()
	$LeftThrusters.visible = false
	$RightThrusters.stop()
	$RightThrusters.visible = false
	$AnimatedSprite.stop()
	$AnimatedSprite.visible = false		
	$Boom.play()
	$Kaboom.visible = true
	$Kaboom.play()
	$Sprite.visible = false
	$GUI/Fuel.text = "LANDER\nDESTROYED!"
	$GUI/Fuel/Value.text = ""
#	if $"/root/Global".current_level == 1:
#		$Camera2D.game_over_zoom_out()				



func _on_Boom_finished() -> void:
	$"/root/Global".blank_screen(3)
	yield(get_tree().create_timer(1), "timeout")
	$"..".transfer_player()



func update_GUI():
	FUEL += FUEL_POD
	$GUI/Fuel.adjust(FUEL)
	


# warning-ignore:shadowed_variable
func camera_shake(shake_amount):
	$Camera2D.set_offset(Vector2( \
		rand_range(-3.0, 3.0) * shake_amount, \
		rand_range(-3.0, 3.0) * shake_amount \
	))
	

func fuel_alert_beep():
	for n in 7:
		yield(get_tree().create_timer(0.25), "timeout")
		$AlertBeep.play()
	

func get_input():
	if gameOver:
		return

	input_dir = 0
	y_input_dir = 0
	
	# developer cam
	if Input.is_action_pressed("ui_page_down"):
		$Camera2D.zoom_in_or_out("IN", 4, 0.1)
	if Input.is_action_pressed("ui_page_up"):
		$Camera2D.zoom_in_or_out("OUT", 4, 0.1)
	
	# UI LEFT
	if Input.is_action_pressed("ui_left") || swipe_right:
		down_thrust += 1
		if down_thrust > 60 and down_thrust < 110 and camera_shake_toggle == true and FUEL < 500:
			camera_shake(shake_amount)
		if just_starting:
			just_starting = false
		speed += constant_speed
		if speed > max_speed:
			speed = max_speed
		input_dir += side_thrust
		if input_dir >= max_speed:
			input_dir = max_speed
		FUEL -= fuel_base_usage / 2
		$GUI/Fuel.adjust(FUEL)
		$RightThrusters.visible = true
		$RightThrusters.play()
		if !$ThrustersOther.playing:
			$ThrustersOther.play()

	if Input.is_action_just_released("ui_left") || swipe_right_released:
		down_thrust = 0
		swipe_right_released = false
		$ThrustersOther.stop()
		$RightThrusters.stop()
		$RightThrusters.visible = false

################## UI RIGHT #
	
	if Input.is_action_pressed("ui_right") || swipe_left:
		down_thrust += 1
		if down_thrust > 60 and down_thrust < 110 and camera_shake_toggle == true and FUEL < 500:
			camera_shake(shake_amount)
		if just_starting:
			just_starting = false
		speed += constant_speed
		if speed > max_speed:
			speed = max_speed
		input_dir -= side_thrust
		FUEL -= fuel_base_usage / 2
		$GUI/Fuel.adjust(FUEL)	
		$LeftThrusters.visible = true
		$LeftThrusters.play()
		if !$ThrustersOther.playing:
			$ThrustersOther.play()

	if Input.is_action_just_released("ui_right") || swipe_left_released:
		down_thrust = 0
		swipe_left_released = false
		$ThrustersOther.stop()
		$LeftThrusters.stop()
		$LeftThrusters.visible = false
	
###################### UI DOWN #	
	
	if Input.is_action_pressed("ui_down") || swipe_up:
		down_thrust += 1
		$RocketWhoosh.volume_db = -15
		if down_thrust > 45 and down_thrust < 165 and camera_shake_toggle == true:
			if down_thrust > 45 and rocket_whoosh == false:
				$RocketWhoosh.play()
				$AnimatedSprite.scale.x = 0.26
				$AnimatedSprite.scale.y = 0.32
				fuel_base_usage = 10
				rocket_whoosh = true
			camera_shake(shake_amount)	
		if just_starting:
			just_starting = false
		speed += constant_speed
		if speed > max_speed:
			speed = max_speed
		y_input_dir -= bottom_thrust
		$AnimatedSprite.visible = true
		FUEL -= fuel_base_usage
		$GUI/Fuel.adjust(FUEL)

		if !$Thrusters.playing:
			$Thrusters.volume_db = -15
			$Thrusters.play()
		if middleOn:
			$AnimatedSprite.play("exhaustmiddle")
		else:
			$AnimatedSprite.play("exhaustend", true)
			middleOn = true
			
	if Input.is_action_just_released("ui_down") || swipe_up_released:
		$AnimatedSprite.play("exhaustend")		
		rocket_whoosh = false
		if $RocketWhoosh.playing and down_thrust < 70:
			$RocketWhoosh.volume_db = -50
		$AnimatedSprite.scale.y = 0.25
		$AnimatedSprite.scale.x = 0.25
		down_thrust = 0
		fuel_base_usage = 5
		$Thrusters.playing = false
		middleOn = false
		swipe_up_released = false
		if !$AnimatedSprite.is_playing():
			$AnimatedSprite.visible = false

			
######################### UI UP

	if Input.is_action_pressed("ui_up") || swipe_down:
		down_thrust += 1
		if down_thrust > 60 and down_thrust < 110 and camera_shake_toggle == true and FUEL < 500:
			camera_shake(shake_amount)
		if just_starting:
			just_starting = false
		speed += constant_speed
		if speed > max_speed:
			speed = max_speed
		y_input_dir += top_thrust
		FUEL -= fuel_base_usage / 2
		$GUI/Fuel.adjust(FUEL)
		$TopThrusters.visible = true
		$TopThrusters.play()
		if !$ThrustersOther.playing:
			$ThrustersOther.play()

	if Input.is_action_just_released("ui_up") || swipe_down_released:
		down_thrust = 0
		swipe_down_released = false
		$ThrustersOther.stop()
		$TopThrusters.stop()
		$TopThrusters.visible = false
	
	# initial Lander movement at start of level
	if just_starting and $"/root/Global".current_level != 3:
		velocity.y = move_toward(150, 0, friction)
	if just_starting and $"/root/Global".current_level == 3:
		velocity.y = move_toward(25, 0, friction)
		
		
	if input_dir != 0 or y_input_dir != 0:
		# accelerate when there's input
		if input_dir != 0:
			velocity.x = move_toward(velocity.x, input_dir * speed, acceleration)
		if y_input_dir != 0:
			velocity.y = move_toward(velocity.y, y_input_dir * speed, acceleration)			
	else:
		# slow down when there's no input (not applicable in zero-g)
		velocity.x = move_toward(velocity.x, 0, friction)
		velocity.y = move_toward(velocity.y, 0, friction)
		
	velocity.normalized()
		


func _physics_process(delta):
	if gameOver:
		return
		
	if FUEL <= 0 && !$"/root/Global".test_mode:
		 game_over()
		
	get_input()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)

	var input = Vector2()

	input.x += float(Input.is_action_pressed('ui_left'))
	input.x -= float(Input.is_action_pressed('ui_right'))
	input.y += float(Input.is_action_pressed('ui_up'))
	input.y -= float(Input.is_action_pressed('ui_down'))	
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name == "TileMap" && !$"/root/Global".test_mode:
			game_over()
			
	if FUEL < fuel_alarm_threshold:
		if !fuel_alert_played:
			$GUI/Fuel/Value.low_fuel()		 
			fuel_alert_played = true
			fuel_alert_beep()		


func _on_FuelPickup_body_entered(_body: Node) -> void:
	FUEL += FUEL_POD
	$GUI/Fuel/Value.pickup_fuel()
	fuel_alert_played = false


func _input(event):
	if event is InputEventScreenDrag:
		if Swipe.get_swipe_direction(event.relative, 5) == Vector2.UP:
			swipe_down = true
		if Swipe.get_swipe_direction(event.relative, 5) == Vector2.DOWN:
			swipe_up = true
		if Swipe.get_swipe_direction(event.relative, 5) == Vector2.LEFT:
			swipe_right = true
		if Swipe.get_swipe_direction(event.relative, 5) == Vector2.RIGHT:
			swipe_left = true
			
	if Swipe.on_area == false && swipe_down == true:
		swipe_down_released = true
		swipe_down = false
	if Swipe.on_area == false && swipe_up == true:
		swipe_up_released = true
		swipe_up = false
	if Swipe.on_area == false && swipe_left == true:
		swipe_left_released = true
		swipe_left = false
	if Swipe.on_area == false && swipe_right == true:
		swipe_right_released = true
		swipe_right = false	
		


func set_player_position():
	var x
	var y
	x = level_coords[$"/root/Global".current_level - 1][0]
	y = level_coords[$"/root/Global".current_level - 1][1]
	position.x = x
	position.y = y
	$Camera2D.starting_camera_zoom()
	$Sprite.visible = true
	$GUI.visible = true
	just_starting = true
	if !$"..".dev_transfer:
		$"..".dev_transfer = false
	$"..".complete_transfer()

	
		
func _ready():
	set_player_position()


# FINAL LANDING AREA
func _on_Area2D_body_entered(body):
	if body.name == "Player":
		print("WELCOME HOME, SPACELANDER...")


func _on_FinalLevelDetect_body_entered(_body):
	$"/root/Global".current_level = 3


func _on_OutOfBounds_body_entered(body):
	game_over()


func _on_OutOfBounds2_body_entered(body):
	game_over()


func _on_OutOfBounds3_body_entered(body):
	game_over()

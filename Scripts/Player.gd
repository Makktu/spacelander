extends KinematicBody2D


onready var Collision_Sound = $AudioStreamPlayer2D
onready var fuel_alert_beep = get_node("%Alert")

var input_dir = 0
var y_input_dir = 0
var swipe_dir = ""

#var SHIELDS = 100000
var FUEL = 2000
var FUEL_POD = 5000
var fuel_base_usage = 8
var fuel_alarm_threshold = FUEL / 10
var fuel_alert_played = false
#var PLAYER_SPEED = 200
var gameOver = false
var middleOn = false
var no_fuel = false
var speed = 0
var max_speed = 150
#var jump_speed = -1800
var gravity = 0
var velocity = Vector2.ZERO
var friction = 0.0
var acceleration = 0.2

var last_press = "none"
var last_constant_press = 0

var first_press = false

var constant_press = 0
var constant_speed = 3

var last_input_dir = 0

var side_thrust = 0.4
var bottom_thrust = 1
var top_thrust = 0.45
var dir_dir = 0


func game_over():
	gameOver = true
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
	
	if FUEL <= 0:
		# if reason for game over is fuel loss, permit drifting for short time...
		
		yield(get_tree().create_timer(0.5), "timeout")
		
	$Boom.play()
	$Kaboom.visible = true
	$Kaboom.play()
	$Sprite.visible = false
	$GUI/Fuel.text = "LANDER DESTROYED!"
	$GUI/Fuel/Value.text = ""
				

func _on_LaserBarrier_area_entered(area: Area2D) -> void:
	game_over()


func _on_Boom_finished() -> void:
	get_tree().change_scene("res://Scenes/Game Over.tscn")


func update_GUI():
	FUEL += FUEL_POD
	$GUI/Fuel.adjust(FUEL)
	

func get_input(swipe_dir):
	if gameOver:
		return

	input_dir = 0
	y_input_dir = 0
	
# UI LEFT
	if Input.is_action_pressed("ui_left") || swipe_dir == "left":
		if !first_press:
			first_press = true
		# fake semi-realistic spacecraft movement
#		if last_press == "left":
#			constant_press = last_constant_press 
#			last_press = "none"
#			speed = last_constant_press
#			input_dir = dir_dir
#		constant_press += constant_speed
#		if constant_press >= max_speed:
#			constant_press = max_speed
		speed += constant_speed
		input_dir += side_thrust
		dir_dir = input_dir
		print(speed, constant_press, input_dir)

		FUEL -= fuel_base_usage / 2
		$GUI/Fuel.adjust(FUEL)
		$RightThrusters.visible = true
		$RightThrusters.play()
		if !$ThrustersOther.playing:
			$ThrustersOther.play()

	if Input.is_action_just_released("ui_left"):
#		last_press = "left"
#		speed = 0
#		last_constant_press = constant_press
#		last_input_dir = input_dir
		$ThrustersOther.stop()
		$RightThrusters.stop()
		$RightThrusters.visible = false
#############################

################## UI RIGHT #
	
	if Input.is_action_pressed("ui_right"):
		if !first_press:
			first_press = true
#		constant_press += constant_speed
#		if constant_press >= max_speed:
#			constant_press = max_speed
		speed += constant_speed
		input_dir -= side_thrust
		FUEL -= fuel_base_usage / 2
		$GUI/Fuel.adjust(FUEL)	
		$LeftThrusters.visible = true
		$LeftThrusters.play()
		if !$ThrustersOther.playing:
			$ThrustersOther.play()

	if Input.is_action_just_released("ui_right"):
#		speed = -constant_press
#		constant_press = 0
		$ThrustersOther.stop()
		$LeftThrusters.stop()
		$LeftThrusters.visible = false
#############################
	
###################### UI DOWN #	
	
	if Input.is_action_pressed("ui_down"):
		if !first_press:
			first_press = true
#		constant_press += constant_speed
#		if constant_press >= max_speed:
#			constant_press = max_speed
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
			
	if Input.is_action_just_released("ui_down"):
#		speed = 50 - constant_press
#		constant_press = 0
		$AnimatedSprite.play("exhaustend")
		# always turn OFF Thruster sound
		$Thrusters.playing = false
		middleOn = false
		if !$AnimatedSprite.is_playing():
			$AnimatedSprite.visible = false
#########################################################			
			
######################### UI UP #########################
	if Input.is_action_pressed("ui_up"):
		if !first_press:
			first_press = true
#		constant_press += constant_speed
#		if constant_press >= max_speed:
#			constant_press = max_speed
		speed += constant_speed
		y_input_dir += top_thrust
		FUEL -= fuel_base_usage / 2
		$GUI/Fuel.adjust(FUEL)
		$TopThrusters.visible = true
		$TopThrusters.play()
		if !$ThrustersOther.playing:
			$ThrustersOther.play()

	if Input.is_action_just_released("ui_up"):
#		last_press = "up"
#		speed = 50 - constant_press
#		constant_press = 0
		$ThrustersOther.stop()
		$TopThrusters.stop()
		$TopThrusters.visible = false
#########################################################		

		
	if input_dir != 0 || y_input_dir != 0:
		# accelerate when there's input
		if input_dir != 0:
			velocity.x = lerp(velocity.x, input_dir * speed, acceleration)
		if y_input_dir != 0:
			velocity.y = lerp(velocity.y, y_input_dir * speed, acceleration)			
	else:
		# slow down when there's no input
		velocity.x = lerp(velocity.x, 0, friction)
		velocity.y = lerp(velocity.y, 0, friction)
		


func _physics_process(delta):
	swipe_dir = ""
	if !first_press:
		position.y += 2
	if gameOver:
		return
		
	if FUEL <= fuel_alarm_threshold && !fuel_alert_played:
		fuel_alert_beep.play_alert()
		$GUI/Fuel/Value.low_fuel()		 
		fuel_alert_played = true
		
	if FUEL <= 0:
		 game_over()
		
	get_input(null)
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	# my noob collision detection with surfaces	

	var input = Vector2()

	input.x += float(Input.is_action_pressed('ui_left'))
	input.x -= float(Input.is_action_pressed('ui_right'))
	input.y += float(Input.is_action_pressed('ui_up'))
	input.y -= float(Input.is_action_pressed('ui_down'))	

	move_and_slide(input * speed * delta)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		print(collision.collider.name)
		if collision.collider.name == "TileMap":
			Collision_Sound.play()
#			SHIELDS -= 1
#			print(SHIELDS)
#			if SHIELDS <= 0:
			game_over()
			

func _on_LaserBarrier_body_entered(body: Node) -> void:
	game_over()


func _on_FuelPickup_body_entered(body: Node) -> void:
	FUEL += 2000
	$GUI/Fuel/Value.pickup_fuel()
	fuel_alert_played = false


#func _on_MobileControls_swiped(direction):
#
#	if (direction.x == 1):
#		swipe_dir = "left"
#	if (direction.y == 1):
#		swipe_dir = "up"
#	if (direction.x == -1):
#		swipe_dir = "right"
#	if (direction.y == -1):
#		swipe_dir = "down"
#	get_input(swipe_dir)


func _on_MobileControls_swipe(swipe) -> void:
	print(swipe)

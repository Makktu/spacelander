extends Node2D

func play_alert():
#	$Timer.start()
	print("HERE")
	for n in 10:
		yield(get_tree().create_timer(0.5), "timeout")
		$AudioStreamPlayer2D.play()
		

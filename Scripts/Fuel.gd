extends Label

export (int) var paddingLength = 3


var value = 3000

func _ready() -> void:
	update()
	
func reset():
	value = 0
	update()
	
func adjust(adjustment):
	value = adjustment
	update()
	
func update():
	if value <= 0:
		$Value.text = "EMPTY"
		get_node("Value").add_color_override("red", Color(1,0,0,1))
		return
	$Value.text = ("%0*d" % [paddingLength, value])

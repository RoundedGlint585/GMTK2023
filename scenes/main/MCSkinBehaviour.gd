extends Sprite2D


var wolfSkin = preload("res://icon.svg")
var sheepSkin = preload("res://icon.svg")

enum State {WOLFSKIN, SHEEPSKIN}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func set_texture_by_state(state):
	if state == State.WOLFSKIN:
		set_texture(sheepSkin)
		modulate = Color(1.0, 0.0, 0.0)
	else:
		set_texture(wolfSkin)
		modulate = Color(0.0, 1.0, 0.0)

	

extends Sprite2D


@export var wolfSkin : Texture2D
@export var sheepSkin : Texture2D

enum State {WOLFSKIN, SHEEPSKIN}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func set_texture_by_state(state):
	if state == State.WOLFSKIN:
		set_texture(wolfSkin)
		modulate = Color(1.0, 0.0, 0.0)
	else:
		set_texture(sheepSkin)
		modulate = Color(0.0, 1.0, 0.0)

	

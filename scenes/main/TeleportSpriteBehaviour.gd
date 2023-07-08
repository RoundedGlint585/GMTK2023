extends Sprite2D

@onready 
var timer = Timer.new()

@export
var highlightPeriod = 2.0


var highlightEnabled = false
# Called when the node enters the scene tree for the first time.
func _ready():
	timer.one_shot = false
	add_child(timer);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var current_state = timer.time_left / highlightPeriod * 2 - 1 # gives range [-1:1]
	if not highlightEnabled:
		current_state = 0.0
	(material as ShaderMaterial).set_shader_parameter("strength", abs(current_state))
	
func enableHighlight():
	if highlightEnabled:
		return
	timer.start(highlightPeriod)
	highlightEnabled = true
	
func disableHighlight():
	if not highlightEnabled:
		return
	timer.stop()
	highlightEnabled = false
	

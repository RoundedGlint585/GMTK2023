extends Area2D

@onready 
var sprite = $"../Sprite2D"

@onready 
var timer = Timer.new()

@export
var time = 5.0

@onready var isActivated = false
# Called when the node enters the scene tree for the first time.
func _ready():
	timer.one_shot = true
	add_child(timer);
	body_entered.connect(on_enter)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not isActivated:
		return
	
	if timer.time_left == 0.0:
		isActivated = false
		#sprite.modulate = Color(1.0, 1.0, 1.0)
	pass
	
func on_enter(body:Node2D):
	if body.is_in_group("Sheep") or body.is_in_group("MainCharacter") and not isActivated:
		timer.start(time)
		isActivated = true
		#sprite.modulate = Color(1.0, 0.0, 0.0)

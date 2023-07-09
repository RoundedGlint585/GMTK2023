extends Area2D

var isActive = false

var randomAccumulator = 0


@onready 
var workingTimer = Timer.new()

@export
var workTime = 5.0

@export 
var threashold = 5.0

@export
var direction = Vector2(-1.0, 0.0)

@export
var windForce = 40000.0

var sheeps = []
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	workingTimer.one_shot = true
	add_child(workingTimer);
	
	body_entered.connect(on_enter)
	body_exited.connect(on_exit)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not isActive:
		randomAccumulator += randf()
		
	if randomAccumulator >= threashold and not isActive:
		isActive = true
		randomAccumulator = 0.0
		workingTimer.start(workTime)
	
	if isActive and workingTimer.time_left == 0.0:
		isActive = false
	
	pass
	
	
func on_enter(body:Node2D):
	if body.is_in_group("Sheep"):
		sheeps.append(body)
	
func on_exit(body):
	if body.is_in_group("Sheep"):
		sheeps.remove(body)

func _physics_process(delta):
	if not isActive:
		return
		
	for sheep in sheeps:
		sheep.apply_force(direction * delta * windForce)

	

extends Area2D

var isActive = false

var randomAccumulator = 0


@onready
var windPlayer = $windPlayer

@onready 
var workingTimer = Timer.new()

@onready
var cooldownTimer = Timer.new()

@export
var workTime = 3.0

@export 
var cooldown = 5.0

@export
var direction = Vector2(-1.0, 0.0)

@export
var windForce = 5000.0

var sheeps = []
# Called when the node enters the scene tree for the first time.
func _ready():
	workingTimer.one_shot = true
	add_child(workingTimer);
	
	cooldownTimer.one_shot = true
	add_child(cooldownTimer);
	cooldownTimer.start(cooldown)
	
	body_entered.connect(on_enter)
	body_exited.connect(on_exit)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if cooldownTimer.time_left == 0.0 and not isActive:
		isActive = true
		windPlayer.play()
		workingTimer.start(workTime)
		
	if workingTimer.time_left == 0.0 and isActive:
		isActive = false
		cooldownTimer.start(cooldown)
		windPlayer.stop()
	
	
func on_enter(body:Node2D):
	if body.is_in_group("Sheep"):
		sheeps.append(body)
	
func on_exit(body):
	if body.is_in_group("Sheep"):
		sheeps.erase(body)

func _physics_process(delta):
	if not isActive:
		return
		
	for sheep in sheeps:
		sheep.apply_force(direction * delta * windForce)

	

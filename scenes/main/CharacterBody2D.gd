extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


@export 
var skinChangeCooldown = 1.0
@export
var force = 100


@onready var timer = Timer.new()

enum State {WOLFSKIN, SHEEPSKIN}

@onready 
var currentState = State.WOLFSKIN

func _ready():
	timer.one_shot = true
	add_child(timer);
	timer.start(skinChangeCooldown)

func get_input():
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED;

func _physics_process(delta):
	get_input()
	
	var result = move_and_slide()
	
	if not result:
		return

	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		if col.get_collider() is RigidBody2D:
			col.get_collider().apply_force(col.get_normal() * -force)
	

func _process(delta):
	var timeLeft = timer.time_left
	if Input.is_key_pressed(KEY_SPACE) and timeLeft == 0.0:
		timer.one_shot = true
		timer.start(skinChangeCooldown)
		inverse_current_state()
		get_child(0).set_texture_by_state(currentState)
		
		
func inverse_current_state():
	if currentState == State.WOLFSKIN:
		currentState = State.SHEEPSKIN
	else:
		currentState = State.WOLFSKIN
		
func get_current_state():
	return currentState

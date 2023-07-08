extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")



@export 
var skinChangeCooldown = 1.0

@export
var teleportCooldown = 1.0

@export
var force = 100

@export
var teleportEffectiveDistance = 80;


@onready var timerSkinChange = Timer.new()

@onready var timerTeleport = Timer.new()

@onready var teleportsNode =  get_tree().get_first_node_in_group("Teleports")

enum State {WOLFSKIN, SHEEPSKIN}

@onready 
var currentState = State.WOLFSKIN

func _ready():
	#skin changer timer
	timerSkinChange.one_shot = true
	add_child(timerSkinChange);
	timerSkinChange.start(skinChangeCooldown)
	
	#teleport timer
	timerTeleport.one_shot = true
	add_child(timerTeleport);
	timerTeleport.start(teleportCooldown)
	

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
	if Input.is_key_pressed(KEY_SPACE) and timerSkinChange.time_left == 0.0:
		timerSkinChange.one_shot = true
		timerSkinChange.start(skinChangeCooldown)
		inverse_current_state()
		get_child(0).set_texture_by_state(currentState)
		
	if Input.is_key_pressed(KEY_ENTER) and timerTeleport.time_left == 0.0:
		timerTeleport.one_shot = true
		timerTeleport.start(teleportCooldown)
		position = getTeleportPosition()
		
		
		
func getTeleportPosition():
	for teleport in teleportsNode.get_children():
		if teleport.getDistanceToMC() > teleportEffectiveDistance:
			continue
		var teleportPoints = teleport.getSortedByDistance()
		return teleportPoints[1].position
			
		
func inverse_current_state():
	if currentState == State.WOLFSKIN:
		currentState = State.SHEEPSKIN
	else:
		currentState = State.WOLFSKIN
		
func get_current_state():
	return currentState

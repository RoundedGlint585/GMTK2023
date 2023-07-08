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

@onready var skin = $Skin

enum State {WOLFSKIN, SHEEPSKIN}

@onready 
var currentState = State.SHEEPSKIN

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
	resolve_collisions()


func resolve_collisions():
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		
		if not col.get_collider() is RigidBody2D:
			continue
		
		col.get_collider().apply_force(col.get_normal() * -force)

func _process(delta):
	if Input.is_key_pressed(KEY_SPACE) and timerSkinChange.time_left == 0.0:
		timerSkinChange.one_shot = true
		timerSkinChange.start(skinChangeCooldown)
		inverse_current_state()
		get_child(0).set_texture_by_state(currentState)
		
	if Input.is_key_pressed(KEY_ENTER) and timerTeleport.time_left == 0.0:
		var newPosition = get_teleport_position()
		if newPosition == Vector2(-1, -1):
			return
		position = newPosition
		timerTeleport.one_shot = true
		timerTeleport.start(teleportCooldown)
		
	
	flip_sprite_with_direction()
		

func flip_sprite_with_direction():
	if velocity.x > 0:  # sprite direction
		skin.scale.x = -abs(skin.scale.x)
	elif velocity.x < 0:
		skin.scale.x = abs(skin.scale.x)



func get_teleport_position():
	for teleport in teleportsNode.get_children():
		if teleport.get_distance_to_mc() > teleportEffectiveDistance:
			continue
		var teleportPoints = teleport.get_sorted_by_distance()
		return teleportPoints[1].position
	return Vector2(-1, -1)
		
func inverse_current_state():
	if currentState == State.WOLFSKIN:
		currentState = State.SHEEPSKIN
	else:
		currentState = State.WOLFSKIN
		
func get_current_state():
	return currentState

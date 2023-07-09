extends CharacterBody2D


const SPEED = 250.0


enum TeleportState {NONACTIVE, ENTRY, MOVING, EXIT}
enum State {WOLFSKIN, SHEEPSKIN}


@export 
var skinChangeCooldown = 0.6


@export
var allergyCooldown = 2.0

@export
var force = 100

@export
var teleportEffectiveDistance = 80;

@export
var teleportEntryTime = 1.0

@export
var teleportExitTime = 1.0

@export
var teleportMovingTime = 1.0

@onready
var particles:CPUParticles2D = $CPUParticles2D

@onready var timerSkinChange = Timer.new()

@onready var timerTeleport = Timer.new()

@onready var timerAllergy = Timer.new()

var isAllergyFreezed = false

@onready var teleportsNode =  get_tree().get_first_node_in_group("Teleports")

@onready var skin : Sprite2D = $Skin as Sprite2D

@onready var teleportStatus = TeleportState.NONACTIVE
@onready var animation_player = $AnimationPlayer



@onready 
var currentState = State.SHEEPSKIN

func _ready():
	#skin changer timer
	timerSkinChange.one_shot = true
	add_child(timerSkinChange);
	
	#teleport timer
	timerTeleport.one_shot = true
	add_child(timerTeleport);
	
	#allergy timer
	timerAllergy.one_shot = true
	add_child(timerAllergy);
	

func get_input(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED;

func _physics_process(delta):
	if isAllergyFreezed or timerSkinChange.time_left > 0:
		return
		
	get_input(delta)
	var result = move_and_slide()
	if not result:
		return
	resolve_collisions()


func resolve_collisions():
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		
		if col.get_collider() is RigidBody2D:
			col.get_collider().apply_force(col.get_normal() * -force)
			continue
		
		if not col.get_collider() is Node2D:
			return
		
		if col.get_collider().is_in_group("Flowers") and not isAllergyFreezed:
			isAllergyFreezed = true
			velocity = -velocity.normalized() * 100 #small hack to avoid eternal collision
			timerAllergy.start(allergyCooldown)
		
		
		

func _process(delta):
	
	process_particles()
	
	if timerAllergy.time_left == 0 and isAllergyFreezed:
		isAllergyFreezed = false
		return
	
	if isAllergyFreezed:
		return
	
	if Input.is_key_pressed(KEY_SPACE) and timerSkinChange.time_left == 0.0:
		timerSkinChange.one_shot = true
		timerSkinChange.start(skinChangeCooldown)
		
		inverse_current_state()
		
	process_teleport(delta)

	update_animation()
	flip_sprite_with_direction()
	
	
func process_particles():
	particles.emitting = true if velocity.length() > 0.0 and not isAllergyFreezed else false
	if not particles.emitting:
		return
	if velocity.x > 0:  # sprite direction
		particles.gravity.x = -abs(particles.gravity.x)
	elif velocity.x < 0:
		particles.gravity.x  = abs(particles.gravity.x)
	return
			
func process_teleport(_delta):
	if Input.is_key_pressed(KEY_ENTER) and teleportStatus == TeleportState.NONACTIVE:
		var newPosition = get_teleport_position()
		if newPosition == Vector2(-1, -1):
			return
		teleportStatus = TeleportState.ENTRY
		timerTeleport.start(teleportEntryTime)
		
	if teleportStatus == TeleportState.ENTRY and timerTeleport.time_left == 0.0:
		teleportStatus = TeleportState.MOVING
		timerTeleport.start(teleportMovingTime)
		#disable collision and visibility
		get_node("CollisionShape2D").set_deferred("disabled", true)
		visible = false
	if teleportStatus == TeleportState.MOVING and timerTeleport.time_left == 0.0:
		teleportStatus = TeleportState.EXIT
		var newPosition = get_teleport_position()
		position = newPosition
		visible = true
	if teleportStatus == TeleportState.EXIT and timerTeleport.time_left == 0.0:
		get_node("CollisionShape2D").set_deferred("disabled", false)
		teleportStatus = TeleportState.NONACTIVE


func flip_sprite_with_direction():
	if velocity.x > 0:  # sprite direction
		skin.scale.x = -abs(skin.scale.x)
	elif velocity.x < 0:
		skin.scale.x = abs(skin.scale.x)


func get_teleport_position():
	if teleportsNode == null:
		return Vector2(-1, -1)
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

func update_animation():
	
	if currentState == State.WOLFSKIN:
		if timerSkinChange.time_left > 0.0:
			if animation_player.current_animation == "sheep_to_wolf":
				return
			animation_player.play("sheep_to_wolf")
		else:	
			if teleportStatus == TeleportState.NONACTIVE && velocity == Vector2.ZERO:
				animation_player.play("idle_wolf")
			elif  teleportStatus == TeleportState.NONACTIVE && velocity != Vector2.ZERO:
				animation_player.play("walk_wolf")
			
	elif currentState == State.SHEEPSKIN:
		if timerSkinChange.time_left > 0.0:
			if animation_player.current_animation == "wolf_to_sheep":
				return
			animation_player.play("wolf_to_sheep")
		else:	
			if teleportStatus == TeleportState.NONACTIVE && velocity == Vector2.ZERO:
				animation_player.play("idle_sheep")
			elif teleportStatus == TeleportState.NONACTIVE && velocity != Vector2.ZERO:
				animation_player.play("walk_sheep")

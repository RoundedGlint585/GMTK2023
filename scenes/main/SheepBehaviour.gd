extends RigidBody2D

enum State {WOLFSKIN, SHEEPSKIN}

const SPEED = 100.0

@export
var bushPunchingForce = 1000; #heuristic 

@export
var stopDistance = 150;
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var canSeeWolf = true

var isFreezed = false

var finalSlot = null

@onready 
var mainCharacter: CharacterBody2D = get_tree().get_first_node_in_group("MainCharacter")

func _physics_process(delta):
	check_wolf_visibility()
	if isFreezed:
		return
	check_and_apply_bush_collision()
	return
	
	
	
func check_and_apply_bush_collision():
	for body in get_colliding_bodies():
		var groups = body.get_groups()
		if body.is_in_group("Bush"):
			apply_impulse(-linear_velocity.normalized() * bushPunchingForce) #not cool. but static area can't detect collisions with rigidbody properly

		
func check_wolf_visibility():
	var space_state = get_world_2d().direct_space_state	
	var query = PhysicsRayQueryParameters2D.create(position, mainCharacter.position)
	query.exclude = [self]
	query.collision_mask = 0x2 # (dsmoliakov) probably better to rename to adequate layer not flag
	var result = space_state.intersect_ray(query)
	if not result:
		canSeeWolf = false
		return
	canSeeWolf = true if result.collider == mainCharacter else false
	
	
	
func _integrate_forces(state):
	if not canSeeWolf:
		set_linear_velocity(Vector2(0, 0))
		return
		
	if finalSlot != null: #when finished
		var distance = position.distance_to(finalSlot.position)
		if distance < 10.0:
			isFreezed = true
		if not isFreezed:
			set_linear_velocity(position.direction_to(finalSlot.global_position) * 50)
			# works but why?
		return
		
	var mcCurrentState = mainCharacter.get_current_state()
	var velocity = 0.0
	var distanceToMC = position.distance_to(mainCharacter.position)
	var direction = position.direction_to(mainCharacter.position)
	direction = direction if mcCurrentState == State.SHEEPSKIN else -direction
	for body in get_colliding_bodies():
		if body == mainCharacter:
			direction = Vector2(0, 0)
			break
	set_linear_velocity(direction * SPEED)
		
	
func _process(delta):
	pass
	

func freeze_sheep():
	isFreezed = true
	return
	
func unfreeze_sheep():
	isFreezed = false
	pass
	
func reverse_freeze_status():
	isFreezed = !isFreezed
	pass
	
func set_final_position(slot):
	get_node("CollisionShape2D").set_deferred("disabled", true)
	finalSlot = slot


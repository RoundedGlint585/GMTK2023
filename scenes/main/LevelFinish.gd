extends Area2D

signal level_end
var slots
# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(on_enter)
	slots = get_tree().get_nodes_in_group("Slot")
	pass # Replace with function body.

func on_enter(body:Node2D):
	if not body.is_in_group("Sheep"):
		return
	var slot = get_free_slot()
	if slot == slots[-1]:
		emit_signal("level_end")
	body.set_final_position(slot)
	pass
	
	
func get_free_slot():
	for slot in slots:
		if not slot.isAvailable:
			continue
		slot.isAvailable = false;
		return slot;
	return null
	
# Called every frame. 'delta' is the elapsed time since the previous frame.

func is_level_finished()->bool:
	for slot in slots:
		if slot.isAvailable:
			return false
	return true
	
	
func _process(delta):
	pass

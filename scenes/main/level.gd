extends Node2D



@export
var scenePath = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_first_node_in_group("LevelFinish").connect("level_end", change_level)
	pass # Replace with function body.


func change_level():
	SceneTransition.close_screen()
	await SceneTransition.transition_halfway
	get_tree().change_scene_to_file(scenePath)
	SceneTransition.open_screen()
	pass
# Called every frame. 'delta' wis the elapsed time since the previous frame.
func _process(delta):
	pass

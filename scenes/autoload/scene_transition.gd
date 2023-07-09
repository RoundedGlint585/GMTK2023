extends CanvasLayer

signal transition_halfway
signal transition_finished

@onready var animation_player = $AnimationPlayer


func close_screen():
	animation_player.play("close_screen")

func open_screen():
	animation_player.play("open_screen")


func emit_transition_halfway():
	transition_halfway.emit()

func emit_transition_finished():
	transition_finished.emit()


func close_screen_and_load_scene(path: String):
	close_screen()
	await transition_halfway
	get_tree().change_scene_to_file(path)
	open_screen()

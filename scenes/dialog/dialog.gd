extends CanvasLayer
class_name Dialog

signal dialog_end

@export var dialog_path = ""
@export var text_speed: float = 0.05

@onready var timer = $ColorRect/Timer
@onready var end_phrase_timer = $ColorRect/EndPhraseTimer
@onready var name_label: RichTextLabel = $ColorRect/Name
@onready var text_label: RichTextLabel = $ColorRect/Text
@onready var indicator = $ColorRect/Indicator
@onready var portrait_sprite: Sprite2D = $ColorRect/Portrait
@onready var info_sprite: Sprite2D = $ColorRect/Info

var dialog
var phrase_num = 0
var finished = false


func _ready():
	timer.wait_time = text_speed
	dialog = get_dialog()
	next_phrase()


func _process(_delta):
	indicator.visible = finished
	if Input.is_action_just_pressed("ui_accept"):
		if finished:
			next_phrase()
		else:
			text_label.visible_characters = len(text_label.get_parsed_text())


func get_dialog() -> Array:
	if !FileAccess.file_exists(dialog_path):
		print("no file")
		return []
	var file = FileAccess.open(dialog_path, FileAccess.READ)
	var json = JSON.new()
	json.parse(file.get_as_text())
	var output = json.data
	
	if typeof(output) == TYPE_ARRAY:
		print(output)
		return output
	else:
		print("wrong file format")
		return []


func next_phrase():
	if phrase_num >= len(dialog):
		dialog_end.emit()
		queue_free()
		return
	finished = false
	
	#update_portrait()
	name_label.text = dialog[phrase_num]["name"]
	text_label.text = dialog[phrase_num]["text"]
	
	text_label.visible_characters = 0
	var parsed_text = text_label.get_parsed_text()
	
	while text_label.visible_characters < len(parsed_text):
		text_label.visible_characters += 1
		
		timer.start()
		await timer.timeout
	end_phrase_timer.start()
	await end_phrase_timer.timeout
	
	finished = true
	phrase_num += 1
	return


func update_portrait():
	portrait_sprite.visible = false
	info_sprite.visible = false
	var sprite_name = dialog[phrase_num]["image"]
	var portrait_path = "res://portraits/" + sprite_name
	if !ResourceLoader.exists(portrait_path):
		$ErrorSprite.visible = true
		return
	var portrait_image = load(portrait_path)
	portrait_sprite.texture = portrait_image
	portrait_sprite.visible = true

		

extends Node2D

@onready var label = $CanvasLayer/dead_screen/Label
@onready var dialogue_box = $CanvasLayer/TextField/DialogueBox
@onready var color = $CanvasLayer/dead_screen/ColorRect
@onready var portrait = $CanvasLayer/TextField/PortraitVBox
@onready var menu = $CanvasLayer/Main_Menu
var is_load_screen 
var game_started = false

func _ready() -> void:
	menu.is_menu = true
	portrait.hide()
	dialogue_box.hide()
	dialogue_box.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.visible = false
	color.visible = false

	print("Game loaded. Waiting for player to start.")

func start_game():
	print("Game started!")
	game_started = true
	dialogue_box.show()
	dialogue_box.mouse_filter = Control.MOUSE_FILTER_STOP
	dialogue_box.start('1') 

func load_game():
	if FileAccess.file_exists("user://savegame.json"):
		var file = FileAccess.open("user://savegame.json", FileAccess.READ)
		var data_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var error = json.parse(data_string)
		var save_data = json.data

		if typeof(save_data) == TYPE_DICTIONARY:
			print("Game loaded!")
			game_started = true
			dialogue_box.show()
			dialogue_box.mouse_filter = Control.MOUSE_FILTER_STOP
			dialogue_box.get_dialogue_parser().load_save_data(save_data)
		else:
			print("Error: Save file is corrupted.")
	else:
		print("No save file found.")

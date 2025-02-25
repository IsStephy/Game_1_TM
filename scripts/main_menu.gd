extends Control

@onready var exit_but = $Exit_Button
@onready var continue_but = $Continue_Button
@onready var start_but = $Start_Button
@onready var save_but = $Save_Button
@onready var load_but = $Load_Button
@onready var color = $ColorRect
@onready var dialogue_box = $"../TextField/DialogueBox"
@onready var texture = $"../Sprite2D"
var is_menu = true
var game_started = false 
var is_load_screen = false

var input_locked = false

func _ready() -> void:
	is_menu = true  
	update_menu_visibility()

func _unhandled_input(event: InputEvent) -> void:
	if input_locked:
		return
	if event.is_action_pressed("ui_cancel") and game_started:
		is_menu = !is_menu
		update_menu_visibility()

func update_menu_visibility():
	if is_menu:
		exit_but.show()
		continue_but.show()
		start_but.show()
		save_but.show()
		load_but.show()
		color.show()
		self.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		exit_but.hide()
		continue_but.hide()
		start_but.hide()
		save_but.hide()
		load_but.hide()
		color.hide()
		self.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_continue_button_pressed() -> void:
	if game_started:
		is_menu = false
		update_menu_visibility()

func _on_start_button_pressed() -> void:
	is_menu = false
	game_started = true 
	update_menu_visibility()

	if get_tree().current_scene.name == "MainMenu":
		get_tree().change_scene_to_file("res://scenes/background1.tscn")
		await get_tree().process_frame 
	var game_scene = get_tree().current_scene
	if game_scene.has_method("start_game"):
		game_scene.start_game()
	else:
		print("Error: Game scene does not have start_game() function!")

func _on_load_button_pressed() -> void:
	is_menu = false
	game_started = true
	update_menu_visibility()

	if FileAccess.file_exists("user://savegame.json"):
		var file = FileAccess.open("user://savegame.json", FileAccess.READ)
		var data_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var error = json.parse(data_string)
		var save_data = json.data

		await get_tree().process_frame 
		var game_scene = get_tree().current_scene
		if dialogue_box.has_method("load_game") and game_started:
			dialogue_box.load_game(save_data)
		else:
			print("Error: Game scene does not have load_game() function!")



func _on_save_button_pressed() -> void:
	is_menu = false
	var dialogue_parser = dialogue_box._dialogue_parser
	var save_data = dialogue_parser.get_save_data()

	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	if file and game_started:
		var json = JSON.new()
		var json_string = json.stringify(save_data)
		file.store_string(json_string)
		file.close()
		print("Game saved!")
	else:
		print("Error: Could not open save file for writing.")
		

func _on_exit_button_pressed() -> void:
	get_tree().quit()

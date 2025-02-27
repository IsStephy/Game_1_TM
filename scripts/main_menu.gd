extends Control

@onready var exit_but = $Exit_Button
@onready var continue_but = $Continue_Button
@onready var start_but = $Start_Button
@onready var save_but = $Save_Button
@onready var load_but = $Load_Button
@onready var color = $ColorRect
@onready var dialogue_box = $"../TextField/DialogueBox"
@onready var texture = $"../Sprite2D"
@onready var label = $"../dead_screen/Label"
@onready var colorrect= $"../dead_screen/ColorRect"
@onready var portrait = $"../TextField/PortraitVBox"
# Separate Save & Load Rects
@onready var save_rect = $"../SaveRect"
@onready var save_slots = [
	$"../SaveRect/Save1", $"../SaveRect/Save2", $"../SaveRect/Save3", 
	$"../SaveRect/Save4", $"../SaveRect/Save5", $"../SaveRect/Save6",
	$"../SaveRect/Save7", $"../SaveRect/Save8", $"../SaveRect/Save9"
]
@onready var load_rect = $"../LoadRect"
@onready var load_slots = [
	$"../LoadRect/Load1", $"../LoadRect/Load2", $"../LoadRect/Load3", 
	$"../LoadRect/Load4", $"../LoadRect/Load5", $"../LoadRect/Load6",
	$"../LoadRect/Load7", $"../LoadRect/Load8", $"../LoadRect/Load9"
]

var is_menu = true
var game_started = false
var is_load_screen = false

var input_locked = false

func _ready() -> void:
	is_menu = true  
	save_rect.hide()  
	load_rect.hide()
	update_menu_visibility()
	update_slot_backgrounds()

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
		save_rect.hide()
		load_rect.hide()
		self.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_continue_button_pressed() -> void:
	if game_started:
		is_menu = false
		update_menu_visibility()

func _on_start_button_pressed() -> void:
	label.hide()
	colorrect.hide()
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

func _on_save_button_pressed() -> void:
	if not game_started:
		print("Game has not started yet!")
		return
	
	
	is_load_screen = false
	save_rect.show()
	load_rect.hide()
	print("Choose a save slot.")

func _on_load_button_pressed() -> void:
	game_started = true
	is_load_screen = true
	load_rect.show()
	save_rect.hide()
	print("Choose a slot to load.")

func _on_save_slot_pressed(slot_index: int) -> void:
	if not game_started:
		print("Game has not started yet!")
		return

	var save_file = "user://savegame" + str(slot_index) + ".json"
	var dialogue_parser = dialogue_box._dialogue_parser
	var save_data = dialogue_parser.get_save_data()

	if texture.texture:
		save_data["current_background"] = texture.texture.resource_path

	var file = FileAccess.open(save_file, FileAccess.WRITE)
	if file:
		var json = JSON.new()
		var json_string = json.stringify(save_data)
		file.store_string(json_string)
		file.close()
		print("Game saved in slot " + str(slot_index) + "!")
		is_menu = false
		update_menu_visibility()
		set_slot_background(save_slots[slot_index - 1], save_data["current_background"])
		set_slot_background(load_slots[slot_index - 1], save_data["current_background"]) 
	else:
		print("Error: Could not save to slot " + str(slot_index) + ".")

	save_rect.hide()

func _on_load_slot_pressed(slot_index: int) -> void:
	var save_file = "user://savegame" + str(slot_index) + ".json"
	if FileAccess.file_exists(save_file):
		var file = FileAccess.open(save_file, FileAccess.READ)
		var data_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var error = json.parse(data_string)
		var save_data = json.data

		await get_tree().process_frame 
		var game_scene = get_tree().current_scene
		if dialogue_box.has_method("load_game") and game_started:
			dialogue_box.load_game(save_data)
			print("Game loaded from slot " + str(slot_index) + "!")

			game_started = true
			is_menu = false
			self.mouse_filter = Control.MOUSE_FILTER_STOP 
			if save_data.has("current_background"):
				texture.texture = load(save_data["current_background"])
			is_menu = false
			update_menu_visibility()
			label.hide()
			colorrect.hide()
			dialogue_box.show()
			portrait.show()
		else:
			print("Error: Could not load save data.")
	else:
		print("No save file found in slot " + str(slot_index) + ".")

	load_rect.hide()

func update_slot_backgrounds():
	for i in range(1, len(save_slots) + 1):
		var save_file = "user://savegame" + str(i) + ".json"
		if FileAccess.file_exists(save_file):
			var file = FileAccess.open(save_file, FileAccess.READ)
			var data_string = file.get_as_text()
			file.close()

			var json = JSON.new()
			var error = json.parse(data_string)
			var save_data = json.data

			if save_data.has("current_background"):
				set_slot_background(save_slots[i - 1], save_data["current_background"])
				set_slot_background(load_slots[i - 1], save_data["current_background"])

func set_slot_background(slot_button: Button, image_path: String):
	var texture = ResourceLoader.load(image_path)
	if texture:
		var style = StyleBoxTexture.new()
		style.texture = texture
		slot_button.add_theme_stylebox_override("normal", style)

func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_save_1_pressed() -> void:
	_on_save_slot_pressed(1)


func _on_save_2_pressed() -> void:
	_on_save_slot_pressed(2)


func _on_save_3_pressed() -> void:
	_on_save_slot_pressed(3)


func _on_save_4_pressed() -> void:
	_on_save_slot_pressed(4)


func _on_save_5_pressed() -> void:
	_on_save_slot_pressed(5)


func _on_save_6_pressed() -> void:
	_on_save_slot_pressed(6)


func _on_save_7_pressed() -> void:
	_on_save_slot_pressed(7)

func _on_save_8_pressed() -> void:
	_on_save_slot_pressed(8)


func _on_save_9_pressed() -> void:
	_on_save_slot_pressed(9)


func _on_load_1_pressed() -> void:
	_on_load_slot_pressed(1)


func _on_load_2_pressed() -> void:
	_on_load_slot_pressed(2)


func _on_load_3_pressed() -> void:
	_on_load_slot_pressed(3)


func _on_load_4_pressed() -> void:
	_on_load_slot_pressed(4)

func _on_load_5_pressed() -> void:
	_on_load_slot_pressed(5)

func _on_load_6_pressed() -> void:
	_on_load_slot_pressed(6)


func _on_load_7_pressed() -> void:
	_on_load_slot_pressed(7)


func _on_load_8_pressed() -> void:
	_on_load_slot_pressed(8)


func _on_load_9_pressed() -> void:
	_on_load_slot_pressed(9)

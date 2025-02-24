extends Control

@onready var exit_but = $Exit_Button
@onready var continue_but = $Continue_Button
@onready var start_but = $Start_Button
@onready var save_but = $Save_Button
@onready var load_but = $Load_Button
@onready var color = $ColorRect
var is_menu

var input_locked = false

func _ready() -> void:
	print(self.get_parent())
	if self.get_parent() == $Window:
		is_menu = false
	else:
		is_menu = true
	update_menu_visibility()

func _unhandled_input(event: InputEvent) -> void:
	if input_locked:
		return
	if event.is_action_pressed("ui_cancel"):
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
	is_menu = false
	update_menu_visibility()

func _on_start_button_pressed() -> void:
	is_menu = false
	update_menu_visibility()
	var dialoguebox = $"../TextField/DialogueBox"
	if dialoguebox:
		dialoguebox.start("1")
	await(get_tree().create_timer(10))
	get_tree().call_deferred("change_scene_to_file", "res://scenes/background1.tscn")




func _on_load_button_pressed() -> void:
	if FileAccess.file_exists("user://savegame.json"):
		var file = FileAccess.open("user://savegame.json", FileAccess.READ)
		var data_string = file.get_as_text()
		file.close()
		var json = JSON.new()
		var error = json.parse(data_string)
		var save_data = json.data
		if typeof(save_data) == TYPE_DICTIONARY:
			var dialogue_box = get_node("../TextField/DialogueBox")
			var dialogue_parser = dialogue_box._dialogue_parser
			dialogue_parser.load_save_data(save_data)
			print("Game loaded!")
		else:
			print("Error: Save file is corrupted.")
	else:
		print("No save file found.")



func _on_save_button_pressed() -> void:
	var dialogue_box = get_node("../TextField/DialogueBox") 
	var dialogue_parser = dialogue_box._dialogue_parser
	var save_data = dialogue_parser.get_save_data()

	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	if file:
		var json = JSON.new()
		var json_string = json.stringify(save_data)
		file.store_string(json_string)
		file.close()
		print("Game saved!")
	else:
		print("Error: Could not open save file for writing.")



func _on_exit_button_pressed() -> void:
	get_tree().quit()

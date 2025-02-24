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
	if self.get_parent() == $Window:
		is_menu = true
	else:
		is_menu = false
	update_menu_visibility()

func _unhandled_input(event: InputEvent) -> void:
	if input_locked:
		return

	if event.is_action_pressed("ui_cancel"):
		is_menu = !is_menu
	update_menu_visibility()

func update_menu_visibility():
	print("update_menu_visibility: is_menu =", is_menu)  # Debug output.
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
	pass 

func _on_save_button_pressed() -> void:
	pass 

func _on_exit_button_pressed() -> void:
	get_tree().quit()

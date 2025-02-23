extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
@onready var exit_but = $Exit_Button
@onready var continue_but = $Continue_Button
@onready var start_but = $Start_Button
@onready var save_but = $Save_Button
@onready var load_but = $Load_Button
@onready var color = $ColorRect
var is_menu = false
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		is_menu = !is_menu
	update_menu_visibility()

func update_menu_visibility():
  # Show/hide the menu buttons
	exit_but.visible = is_menu
	continue_but.visible = is_menu
	start_but.visible = is_menu
	save_but.visible = is_menu
	load_but.visible = is_menu
	color.visible = is_menu
	if is_menu:
		self.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		self.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_continue_button_pressed() -> void:
	is_menu = !is_menu


func _on_start_button_pressed() -> void:
	var dialoguebox = $"../TextField/DialogueBox"
	if dialoguebox:
		dialoguebox.start("1")

	get_tree().call_deferred("change_scene_to_file", "res://scenes/background1.tscn")


func _on_load_button_pressed() -> void:
	pass # Replace with function body.


func _on_save_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	get_tree().quit()

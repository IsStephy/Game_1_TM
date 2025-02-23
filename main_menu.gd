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
	
	if event.is_action_pressed("ui_cancel") and is_menu == false:
		is_menu = true
		
	elif event.is_action_pressed("ui_cancel") and is_menu == true:
		is_menu = false
		
	if is_menu == true:
		exit_but.visible = true
		continue_but.visible = true
		start_but.visible = true
		save_but.visible = true
		load_but.visible = true
		color.visible = true
	else:
		exit_but.visible = false
		continue_but.visible = false
		start_but.visible = false
		save_but.visible = false
		load_but.visible = false
		color.visible = false
		

func _on_continue_button_pressed() -> void:
	is_menu = false


func _on_start_button_pressed() -> void:
	var dialoguebox = $"../TextField/DialogueBox"
	if dialoguebox:
		dialoguebox.start("1")

	get_tree().call_deferred("change_scene_to_file", "res://background1.tscn")


func _on_load_button_pressed() -> void:
	pass # Replace with function body.


func _on_save_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	get_tree().quit()

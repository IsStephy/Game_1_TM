extends Control

@onready var menu = $Main_Menu
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu.is_menu = true
	menu.update_menu_visibility()



func _process(delta: float) -> void:
	menu.is_menu = true
	menu.update_menu_visibility()

extends ColorRect

@onready var label = $role
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.add_theme_font_size_override("font_size", 60)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_tree().change_scene_to_file("res://scenes/background1.tscn")

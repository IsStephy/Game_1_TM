extends PanelContainer

var currentSpeaking = "Bobik"
const BOBIK = "Bobik"

func _ready() -> void:
	_changePanelColor()
	_resize_panel()

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		_resize_panel()

func _changePanelColor() -> void:
	if currentSpeaking == BOBIK:
		modulate = Color(0, 0, 0)
	else:
		modulate = Color(1, 1, 1)

func _resize_panel() -> void:
	var parent_node = get_parent()
	if parent_node is Control:
		var parent_size = parent_node.size
		var new_width = parent_size.x * 0.8
		var new_height = parent_size.y * 0.4
		size = Vector2(new_width, new_height)
		
		position.x = (parent_size.x - new_width) / 2
		position.y = parent_size.y - new_height*1.2

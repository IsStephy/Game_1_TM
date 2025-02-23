extends Node2D


@onready var label = $CanvasLayer/dead_screen/Label
@onready var dialogue_box = $CanvasLayer/TextField/DialogueBox
@onready var color = $CanvasLayer/dead_screen/ColorRect
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.visible = false
	color.visible = false

	
	dialogue_box.start('1')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

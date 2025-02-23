extends CanvasLayer

@onready var label = $dead_screen/Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.size = Vector2(800, 600)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

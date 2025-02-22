extends PanelContainer


var currentSpeaking = "Bobik"
const BOBIK = "Bobik"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_changePanelColor()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _changePanelColor() -> void:
	var dialogueBox = self
	if currentSpeaking == BOBIK:
		dialogueBox.modulate = Color(0, 0, 0)
	else:
		dialogueBox.modulate = Color(1, 1, 1)

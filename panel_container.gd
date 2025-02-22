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
	var poligon = $Polygon2D
	var label =$Polygon2D/Label
	if currentSpeaking == BOBIK:
		dialogueBox.modulate = Color(0.288, 0.091, 0.668)
		poligon.modulate =Color(0.288, 0.091, 0.7)
		label.modulate = Color(1,1,1)
	else:
		dialogueBox.modulate = Color(1, 1, 1)

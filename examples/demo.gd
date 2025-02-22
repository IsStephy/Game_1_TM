extends Control

@export var demos: Array[DialogueData]

@onready var dialogue_box = $DialogueBox
@onready var particles = $Particles


func _ready():
	for demo in demos:
		var label = demo.resource_path.split('/')[-1].split('.')[0]
		$DemoSelector.add_item(label)
	
	dialogue_box.data = demos[0]


func explode(_a=0):
	particles.emitting = true


func _on_Button_pressed():
	if not dialogue_box.is_running():
<<<<<<< HEAD
		dialogue_box.start()
=======
		dialogue_box.start('1')
>>>>>>> acce819c21ac450449b3bce66a45ff17a4ce0b9d


func _on_dialogue_signal(value):
	match(value):
		'explode': explode()


func _on_demo_selected(index):
	dialogue_box.data = demos[index]


func _on_locale_selected(index):
	match index:
		0:
			# English
			TranslationServer.set_locale('en')
		1:
			# Japanese
			TranslationServer.set_locale('ja')
			

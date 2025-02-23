extends Control

@onready var video_player = $SplashVideo

func _ready():
	video_player.stream = preload("res://assets/Logo-animation.ogv")
	video_player.play()

func _process(delta):
	if not video_player.is_playing():
		get_tree().change_scene_to_file("res://background1.tscn")

@tool
## A node for displaying branching dialogues, primarily created using the Dialogue Nodes editor.
class_name DialogueBox
extends Panel


## Triggered when a dialogue has started. Passes [param id] of the dialogue tree as defined in the StartNode.
signal dialogue_started(id : String)
## Triggered when a single dialogue block has been processed.
## Passes [param speaker] which can be a [String] or a [param Character] resource, a [param dialogue] containing the text to be displayed
## and an [param options] list containing the texts for each option.
signal dialogue_processed(speaker : Variant, dialogue : String, options : Array[String])
## Triggered when an option is selected
signal option_selected(idx : int)
## Triggered when a SignalNode is encountered while processing the dialogue.
## Passes a [param value] of type [String] that is defined in the SignalNode in the dialogue tree.
signal dialogue_signal(value : String)
## Triggered when a variable value is changed.
## Passes the [param variable_name] along with it's [param value]
signal variable_changed(variable_name : String, value)
## Triggered when a dialogue tree has ended processing and reached the end of the dialogue.
## The [DialogueBox] may hide based on the [member hide_on_dialogue_end] property.
signal dialogue_ended



@export_group('Data')
## Contains the [param DialogueData] resource created using the Dialogue Nodes editor.
@export var data : DialogueData :
	get:
		return data
	set(value):
		data = value
		if _dialogue_parser:
			_dialogue_parser.data = value
			variables = _dialogue_parser.variables
			characters = _dialogue_parser.characters
## The default start ID to begin dialogue from. This is the value you set in the Dialogue Nodes editor.
@export var start_id : String

@export_group('Speaker')
## The default color for the speaker label.
@export var default_speaker_color := Color.WHITE :
	set(value):
		default_speaker_color = value
		if speaker_label: speaker_label.modulate = default_speaker_color
## Hide the character portrait (useful for custom character portrait implementations).
@export var hide_portrait := false :
	set(value):
		hide_portrait = value
		if portrait: portrait.visible = not hide_portrait
## Sample portrait image that is visible in editor. This will not show in-game.
@export var sample_portrait := preload('res://addons/dialogue_nodes/icons/Portrait.png') :
	set(value):
		sample_portrait = value
		if portrait: portrait.texture = sample_portrait

@export_group('Dialogue')
## Speed of scroll when using joystick/keyboard input
@export var scroll_speed := 4
## Input action used to skip dialogue animation
@export var skip_input_action := 'ui_cancel'
## Custom RichTextEffects that can be used in the dialogue as bbcodes.[br]
## Example: [code][ghost]Spooky dialogue![/ghost][/code]
@export var custom_effects : Array[RichTextEffect] = [
	RichTextWait.new(),
	RichTextGhost.new(),
	RichTextMatrix.new()
	]

@export_group('Options')

## The maximum number of options to show in the dialogue box.
@export var max_options_count := 4:
	get:
		return max_options_count
	set(value):
		max_options_count = max(value, 1)
		
		if options_container:
			# Clear all existing buttons.
			for option in options_container.get_children():
				options_container.remove_child(option)
				option.queue_free()
			
		
			# Create new buttons hidden by default.
			for idx in range(max_options_count):
				var button = Button.new()
				options_container.add_child(button)
				button.text = "Option " + str(idx + 1)
				button.hide()  # Always start hidden.
				button.pressed.connect(select_option.bind(idx))


## Icon displayed when no text options are available.
@export var next_icon : Texture2D = preload('res://addons/dialogue_nodes/icons/Play.svg')
## Alignment of options.
@export_enum('Begin', 'Center', 'End') var options_alignment := 2 :
	set(value):
		options_alignment = value
		if options_container:
			options_container.alignment = options_alignment
## Orientation of options.
@export var options_vertical := false :
	set(value):
		options_vertical = value
		if options_container:
			options_container.vertical = options_vertical
## Position of options along the dialogue box.
@export_enum('Top', 'Left', 'Right', 'Bottom') var options_position := 3 :
	set(value):
		options_position = value
		if not options_container: return
		if not _main_container: return
		if not _sub_container: return
		
		options_container.get_parent().remove_child(options_container)
		match value:
			0:
				# top
				_sub_container.add_child(options_container)
				_sub_container.move_child(options_container, 0)
			3:
				# bottom
				_sub_container.add_child(options_container)
			1:
				# left
				_main_container.add_child(options_container)
				_main_container.move_child(options_container, 0)
			2:
				# right
				_main_container.add_child(options_container)

@export_group('Misc')
## Hide dialogue box at the end of a dialogue
@export var hide_on_dialogue_end := true

## Contains the variable data from the [param DialogueData] parsed in an easy to access dictionary.[br]
## Example: [code]{ "COINS": 10, "NAME": "Obama", "ALIVE": true }[/code]
var variables : Dictionary
## Contains all the [param Character] resources loaded from the path in the [member data].
var characters : Array[Character]
## Displays the portrait image of the speaker in the [DialogueBox]. Access the speaker's texture by [member DialogueBox.portrait.texture]. This value is automatically set while running a dialogue tree.
var portrait : TextureRect
## Displays the name of the speaker in the [DialogueBox]. Access the speaker name by [code]DialogueBox.speaker_label.text[/code]. This value is automatically set while running a dialogue tree.
var speaker_label : Label
## Displays the dialogue text. This node's value is automatically set while running a dialogue tree.
var dialogue_label : RichTextLabel
## Contains all the option buttons. The currently displayed options are visible while the rest are hidden. This value is automatically set while running a dialogue tree.
var options_container : BoxContainer

# [param DialogueParser] used for parsing the dialogue [member data].
# NOTE: Using [param DialogueParser] as a child instead of extending from it, because [DialogueBox] needs to extend from [Panel].
var _dialogue_parser : DialogueParser
var _main_container : BoxContainer
var _sub_container : BoxContainer
var _wait_effect : RichTextWait
var portrait_override_active = false
var portrait_override_texture : Texture2D = null


func _enter_tree():
	# Remove any existing children from DialogueBox (if needed)
	if get_child_count() > 0:
		for child in get_children():
			remove_child(child)
			child.queue_free()
	
	# --- Get the externally created VBox ---
	# Adjust the node path as necessary to point to your manually created VBox.
	var external_vbox = get_node("/root/Node2D/CanvasLayer/TextField/PortraitVBox")
	
	# --- Create the portrait as a TextureRect and add it to the external VBox ---
	portrait = TextureRect.new()
	portrait.texture = sample_portrait
	portrait.expand = true
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	portrait.size_flags_vertical = Control.SIZE_EXPAND_FILL
	portrait.z_index = -1   # Ensure it's behind other elements if needed.
	portrait.visible = not hide_portrait
	external_vbox.add_child(portrait)
	
	# --- Create the dialogue UI container inside the DialogueBox ---
	var dlg_margin_container = MarginContainer.new()
	add_child(dlg_margin_container)
	dlg_margin_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	dlg_margin_container.set_offsets_preset(Control.PRESET_FULL_RECT)
	dlg_margin_container.add_theme_constant_override("margin_left", 4)
	dlg_margin_container.add_theme_constant_override("margin_top", 4)
	dlg_margin_container.add_theme_constant_override("margin_right", 4)
	dlg_margin_container.add_theme_constant_override("margin_bottom", 4)
	
	_main_container = BoxContainer.new()
	dlg_margin_container.add_child(_main_container)
	
	_sub_container = BoxContainer.new()
	_main_container.add_child(_sub_container)
	_sub_container.vertical = true
	_sub_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	speaker_label = Label.new()
	_sub_container.add_child(speaker_label)
	speaker_label.text = "Speaker"
	
	dialogue_label = RichTextLabel.new()
	_sub_container.add_child(dialogue_label)
	dialogue_label.text = "Some dialogue text to demonstrate how an actual dialogue might look like."
	dialogue_label.bbcode_enabled = true
	dialogue_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dialogue_label.custom_effects = custom_effects
	
	options_container = BoxContainer.new()
	_sub_container.add_child(options_container)
	options_container.alignment = BoxContainer.ALIGNMENT_END
	# Reapply option-related settings.
	max_options_count = max_options_count
	options_alignment = options_alignment
	options_vertical = options_vertical
	options_position = options_position
	
	# --- Set up the dialogue parser ---
	_dialogue_parser = DialogueParser.new()
	add_child(_dialogue_parser)
	_dialogue_parser.data = data
	variables = _dialogue_parser.variables
	characters = _dialogue_parser.characters
	
	_dialogue_parser.dialogue_started.connect(_on_dialogue_started)
	_dialogue_parser.dialogue_processed.connect(_on_dialogue_processed)
	_dialogue_parser.option_selected.connect(_on_option_selected)
	_dialogue_parser.dialogue_signal.connect(_on_dialogue_signal)
	_dialogue_parser.variable_changed.connect(_on_variable_changed)
	_dialogue_parser.dialogue_ended.connect(_on_dialogue_ended)


func _ready():
	for effect in custom_effects:
		if effect is RichTextWait:
			_wait_effect = effect
			_wait_effect.wait_finished.connect(_on_wait_finished)
			break
	
	hide()


func _process(delta):
	if not is_running(): return
	print(variables["PAR"])
	# scrolling for longer dialogues
	var scroll_amt := 0.0
	if options_vertical:
		scroll_amt = Input.get_axis("ui_left", "ui_right")
	else:
		scroll_amt = Input.get_axis("ui_up", "ui_down")
	
	if scroll_amt:
		dialogue_label.get_v_scroll_bar().value += int(scroll_amt * scroll_speed)


func _input(event):
	if is_running():
		if wait_for_input_continue:
			if event is InputEventMouseButton and event.pressed:
				_continue_dialogue()
			elif event is InputEventKey and event.pressed and (event.get_keycode() == KEY_SPACE or event.get_keycode() == MOUSE_BUTTON_MASK_LEFT):
				_continue_dialogue()
		elif Input.is_action_just_pressed(skip_input_action):
			if _wait_effect and not _wait_effect.skip:
				_wait_effect.skip = true
				await get_tree().process_frame
				_on_wait_finished()

func _continue_dialogue():
	if _dialogue_parser:
		call_deferred("_call_continue")
	wait_for_input_continue = false

func _call_continue():
	_dialogue_parser.continue_dialogue()



## Starts processing the dialogue [member data], starting with the Start Node with its ID set to [param start_id].
func start(id := start_id):
	if not _dialogue_parser: return
	_dialogue_parser.start(id)


## Stops processing the dialogue tree.
func stop():
	if not _dialogue_parser: return
	_dialogue_parser.stop()


## Continues processing the dialogue tree from the node connected to the option at [param idx].
func select_option(idx : int):
	if not _dialogue_parser: return
	_dialogue_parser.select_option(idx)


## Returns [code]true[/code] if the [DialogueBox] is processing a dialogue tree.
func is_running():
	if _dialogue_parser:
		return _dialogue_parser.is_running()
	return false

func _on_dialogue_started(id : String):
	speaker_label.text = ''
	portrait.texture = null
	dialogue_label.text = ''
	center_dialogue()
	show()
	dialogue_started.emit(id)

var wait_for_input_continue = false

@onready var textfield = self.get_parent()
func center_dialogue():
	options_container.top_level = true
	var viewport_size = get_viewport_rect().size
	options_container.anchor_left = 0.5
	options_container.anchor_top = 0.5
	options_container.anchor_right = 0.5
	options_container.anchor_bottom = 0.5
	options_container.vertical = true
	options_container.position.x = viewport_size.x / 2 - options_container.size.x / 2
	options_container.position.y = viewport_size.y / 2 * 0.5 - options_container.size.y / 2



func _on_dialogue_processed(speaker: Variant, dialogue: String, options: Array[String]):
	# Set speaker, dialogue text, etc.
	if speaker is Character:
		speaker_label.text = speaker.name
		speaker_label.modulate = speaker.color
		if not portrait_override_active:
			portrait.texture = speaker.image
		portrait.show()
		#if not speaker.image:
		#	portrait.hide()
	elif speaker is String and speaker != "":
		speaker_label.text = speaker
		speaker_label.modulate = Color.WHITE
		#portrait.hide()
	elif speaker is String and speaker == "":
		speaker_label.text = speaker
		speaker_label.modulate = Color.WHITE
		portrait.hide()
	

	dialogue_label.text = _dialogue_parser._update_wait_tags(dialogue_label, dialogue)
	dialogue_label.get_v_scroll_bar().set_value_no_signal(0)
	for effect in custom_effects:
		if effect is RichTextWait:
			effect.skip = false
			break
	
	_dialogue_parser.last_choice_background = _dialogue_parser.background

	
	if options.size() == 0 or options.size() == 1:
		wait_for_input_continue = true
		for child in options_container.get_children():
			child.hide()
	else:
		wait_for_input_continue = false
		# Show and update buttons
		for idx in range(options_container.get_child_count()):
			var option: Button = options_container.get_child(idx)
			if idx < options.size():
				option.text = options[idx].replace("[br]", "\n")
				option.show()  
			else:
				option.hide() 
		if options.size() == 1 and options[0] == '':
			options_container.get_child(0).icon = next_icon

	# Hide the container until the wait effect is finished
	options_container.hide()
	call_deferred("center_dialogue")
	dialogue_processed.emit(speaker, dialogue, options)



func _on_option_selected(idx : int):
	option_selected.emit(idx)



@onready var label = $"../../dead_screen/Label"
@onready var color = $"../../dead_screen/ColorRect"
@onready var texture = $"../../Sprite2D"
@onready var audio = $"../../AudioStreamPlayer"

func _on_dialogue_signal(value: String):
	if value == "DIE0":
		label.visible = true
		color.visible = true
		label.text = "You were sold by your father. You die!"
		var font = FontFile.new()
		font.font_data = load("res://assets/fonts/BloodyModes-gwwYp.ttf") 
		label.add_theme_font_override("font", font)
		label["theme_override_colors/font_color"] = Color.DARK_RED
		self.hide()
		portrait.hide()
		
	if value == "DIE1":
		label.visible = true
		color.visible = true
		var font = FontFile.new()
		font.font_data = load("res://assets/fonts/BloodyModes-gwwYp.ttf") 
		label.add_theme_font_override("font", font)
		label.text = "You pass out. When you wake up, you have no idea who you are. Suzie sells you to a gangster. You die!"
		label["theme_override_colors/font_color"] = Color.DARK_RED
		self.hide()
		portrait.hide()
	
	if value == "DIE2":
		label.visible = true
		color.visible = true
		var font = FontFile.new()
		font.font_data = load("res://assets/fonts/BloodyModes-gwwYp.ttf") 
		label.add_theme_font_override("font", font)
		label.text = "You survived, you need a therapist, you couldn't take it, you killed yourself a week later"
		label["theme_override_colors/font_color"] = Color.DARK_RED
		self.hide()
		portrait.hide()
	
	if value == "DIE3":
		label.visible = true
		color.visible = true
		var font = FontFile.new()
		font.font_data = load("res://assets/fonts/BloodyModes-gwwYp.ttf") 
		label.add_theme_font_override("font", font)
		label.text = "The creature screeches. You begin transforming into one of them. You die!"
		label["theme_override_colors/font_color"] = Color.DARK_RED
		self.hide()
		portrait.hide()
	
	if value == "DIE4":
		label.visible = true
		color.visible = true
		var font = FontFile.new()
		font.font_data = load("res://assets/fonts/BloodyModes-gwwYp.ttf") 
		label.add_theme_font_override("font", font)
		label.text = "Granny seems not happy. She takes a flycatcher (aka muhaboika) and beats you. You die!"
		label["theme_override_colors/font_color"] = Color.DARK_RED
		self.hide()
		portrait.hide()
		
	if value == "DIE5":
		label.visible = true
		color.visible = true
		var font = FontFile.new()
		font.font_data = load("res://assets/fonts/BloodyModes-gwwYp.ttf") 
		label.add_theme_font_override("font", font)
		label.text = "Something… flies into you??? It’s the big jar with kompot. You pass out!"
		label["theme_override_colors/font_color"] = Color.DARK_RED
		self.hide()
		portrait.hide()
		
	if value == "DIE6":
		label.visible = true
		color.visible = true
		var font = FontFile.new()
		font.font_data = load("res://assets/fonts/BloodyModes-gwwYp.ttf") 
		label.add_theme_font_override("font", font)
		label.text = "You land on a very sharp garden gnome. You die!"
		label["theme_override_colors/font_color"] = Color.DARK_RED
		self.hide()
		portrait.hide()
		
	if value == "DIE7":
		label.visible = true
		color.visible = true
		var font = FontFile.new()
		font.font_data = load("res://assets/fonts/BloodyModes-gwwYp.ttf") 
		label.add_theme_font_override("font", font)
		label.text = "They attack you. Die being suffocated by your family!"
		label["theme_override_colors/font_color"] = Color.DARK_RED
		self.hide()
		portrait.hide()
		
	if value == "END":
		label.visible = true
		color.visible = true
		#var font = FontFile.new()
		#font.font_data = load("") 
		#label.add_theme_font_override("font", font)
		label.text = "Congratulation you survived"
		label["theme_override_colors/font_color"] = Color.YELLOW
		self.hide()
		portrait.hide()
	if value == "CHAR0":
		portrait_override_texture = load("res://assets/broski/bro_monstertruck.png")
		portrait.texture = portrait_override_texture
		portrait_override_active = true

		
	var new_background_path
	var new_texture
	
	
	if value == "BACK0":
		new_texture = preload("res://assets/scenes/bro/bro_room_day.png")
		new_background_path = "res://assets/scenes/bro/bro_room_day.png"
	elif value == "BACK1":
		new_texture = preload("res://assets/scenes/dad/dad_room_idle.png")
		new_background_path = "res://assets/scenes/dad/dad_room_idle.png"
	elif value == "BACK2":
		new_texture = preload("res://assets/scenes/dad/dad_pc_view1.png")
		new_background_path = "res://assets/scenes/dad/dad_pc_view1.png"
	elif value == "BACK3":
		new_texture = preload("res://assets/scenes/dad/dad_pc_view2.png")
		new_background_path = "res://assets/scenes/dad/dad_pc_view2.png"
	elif value == "BACK4":
		new_texture = preload("res://assets/scenes/dad/dad_room_icon.png")
		new_background_path = "res://assets/scenes/dad/dad_room_icon.png"
	elif value == "BACK5":
		new_texture = preload("res://assets/scenes/sis/sis_room_full.png")
		new_background_path = "res://assets/scenes/sis/sis_room_full.png"
	elif value == "BACK6":
		new_texture = preload("res://assets/scenes/sis/sis_room_table_idle1.png")
		new_background_path = "res://assets/scenes/sis/sis_room_table_idle1.png"
	elif value == "BACK7":
		new_texture = preload("res://assets/scenes/sis/sis_room_money.png")
		new_background_path = "res://assets/scenes/sis/sis_room_money.png"
	elif value == "BACK8":
		new_texture = preload("res://assets/scenes/bro/bro_room_day.png")
		new_background_path = "res://assets/scenes/bro/bro_room_day.png"
	elif value == "BACK9":
		new_texture = preload("res://assets/scenes/new/mom_room/bedroom_door_closed.png")
		new_background_path = "res://assets/scenes/new/mom_room/bedroom_door_closed.png"
	elif value == "BACK10":
		new_texture = preload("res://assets/scenes/new/sis_room/sis_room_meh.png")
		new_background_path = "res://assets/scenes/new/sis_room/sis_room_meh.png"
	elif value == "BACK11":
		new_texture = preload("res://assets/scenes/bro/bro_room_day.png")
		new_background_path = "res://assets/scenes/bro/bro_room_day.png"
	elif value == "BACK12":
		new_texture = preload("res://assets/scenes/mum/bedroom.png")
		new_background_path = "res://assets/scenes/mum/bedroom.png"
	elif value == "BACK14":
		new_texture = preload("res://assets/scenes/new/mom_room/bedroom_door_open.png")
		new_background_path = "res://assets/scenes/new/mom_room/bedroom_door_open.png"
	elif value == "BACK15":
		new_texture = preload("res://assets/scenes/new/mom_room/bedroom_door_closed.png")
		new_background_path = "res://assets/scenes/new/mom_room/bedroom_door_closed.png"
	elif value == "BACK16":
		new_texture = preload("res://assets/scenes/grma/kitchen_idle.png")
		new_background_path = "res://assets/scenes/grma/kitchen_idle.png"
	elif value == "BACK17":
		new_texture = preload("res://assets/scenes/grma/kitchen_plate.png")
		new_background_path = "res://assets/scenes/grma/kitchen_plate.png"
	elif value == "BACK18":
		new_texture = preload("res://assets/scenes/bro/bro_room_day.png")
		new_background_path = "res://assets/scenes/bro/bro_room_day.png"
	elif value == "BACK19":
		new_texture = preload("res://assets/scenes/final/coridor.png")
		new_background_path = "res://assets/scenes/final/coridor.png"
	elif value == "BACK22":
		new_texture = preload("res://assets/scenes/bro/bro_room_night.png")
		new_background_path = "res://assets/scenes/bro/bro_room_night.png"
	elif value == "BACK23":
		new_texture = preload("res://assets/scenes/grma/kitchen_idle.png")
		new_background_path = "res://assets/scenes/grma/kitchen_idle.png"
	if value.begins_with("BACK"):
		texture.texture = new_texture
	if new_background_path:
		_dialogue_parser.background = new_background_path
	
	var new_background_music_path
	var new_background_music
	
	if value == "MUS0":
		new_background_music_path = "res://assets/Sounds/sounds/sitting_on_bed.ogg"
		audio.stream = load("res://assets/Sounds/sounds/sitting_on_bed.ogg")
		audio.play()
		
	
func _on_variable_changed(variable_name : String, value):
	variable_changed.emit(variable_name, value)


func _on_dialogue_ended():
	if hide_on_dialogue_end: hide()
	dialogue_ended.emit()


func _on_wait_finished():
	options_container.show()
	call_deferred("center_dialogue")
	options_container.get_child(0).grab_focus()

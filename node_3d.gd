extends Node3D

@onready var drop_down_menu = $OptionButton
@onready var music_player = $AudioVisualizer/MusicPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	_add_items()

func _add_items():
	drop_down_menu.add_item("battle")
	drop_down_menu.add_item("cello")
	drop_down_menu.add_item("house")


func _on_option_button_item_selected(index):
	var currently_selected = index
	var audio_file = drop_down_menu.get_item_text(index)
	music_player.stream = AudioStreamOggVorbis.load_from_file("res://" + audio_file + ".ogg")
	music_player.play()

func _on_button_pressed():
	pass


func _on_button_toggled(toggled_on):
	if toggled_on:
		get_tree().paused = true
	else:
		get_tree().paused = false

extends HSlider

@export
var bus_name: String

var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index("Music")
	value_changed.connect(_on_value_changed)
	
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(0.5)
	)

func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(value)
	)

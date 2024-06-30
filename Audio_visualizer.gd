#Cello b1 124 seq.wav by ERH -- https://freesound.org/s/38002/ -- License: Attribution 4.0
extends Control

const VU_COUNT = 16
const HEIGHT = 60
const FREQ_MAX = 11050.0

const MIN_DB = 60

var energy := 0.0

var energyArray = []

signal energy_changed(energyArray)

@onready
var spectrum = AudioServer.get_bus_effect_instance(1,0)

@onready
var topRightArray = $CircleBase/Right/Top.get_children()

@onready
var bottomRightArray = $CircleBase/Right/Bottom.get_children()

@onready
var topLeftArray = $CircleBase/Left/Top.get_children()

@onready
var bottomLeftArray = $CircleBase/Left/Bottom.get_children()

@onready
var gridmap = get_tree().get_first_node_in_group("gridmap")

func _get_energy_at(index):
	if not self.is_node_ready():
		return 0
	return self.energyArray[index]

# Called when the node enters the scene tree for the first time.
func _ready():
	energyArray.resize(VU_COUNT)
	bottomLeftArray.reverse()
	topLeftArray.reverse()
	energy_changed.connect(gridmap._on_energy_change)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		
	var new_energyArray = []
	new_energyArray.resize(VU_COUNT)
	var prev_hz = 0
	for i in range(1,VU_COUNT+1):   
		var hz = i * FREQ_MAX / VU_COUNT;
		var f = spectrum.get_magnitude_for_frequency_range(prev_hz,hz)
		energy = clamp((MIN_DB + linear_to_db(f.length()))/MIN_DB,0,1)
		new_energyArray[i-1] = energy
		var height = energy * HEIGHT
		
		prev_hz = hz
		
		var bottomRightRect = bottomRightArray[i - 1]
		var topRightRect = topRightArray[i - 1]
		var topLeftRect = topLeftArray[i - 1]
		var bottomLeftRect = bottomLeftArray[i - 1]
		
		var tween = get_tree().create_tween()

		tween.tween_property(topRightRect, "size", Vector2(topRightRect.size.x, height), 0.05)
		tween.tween_property(bottomRightRect, "size", Vector2(bottomRightRect.size.x, height), 0.05)
		tween.tween_property(topLeftRect, "size", Vector2(topLeftRect.size.x, height), 0.05)
		tween.tween_property(bottomLeftRect, "size", Vector2(bottomLeftRect.size.x, height), 0.05)
#	
	if new_energyArray != energyArray:
		energyArray = new_energyArray
		energy_changed.emit(energyArray)

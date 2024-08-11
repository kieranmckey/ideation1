extends GridMap

var terrain_noise := FastNoiseLite.new()
var stone_noise := FastNoiseLite.new()
var map_width = 50 #50 Adjust this value for desired map width
var map_depth = 8 #50 Adjust this value for desired map depth
var water_level = 0 #-9 # Adjust this value for desired water level
var chunk_size = 10.0 # Adjust this value for desired chunk size
var chunks = {} # Dictionary to store generated chunks
var load_distance = 1 # Distance around the player to load chunks

#<a href="https://www.freepik.com/free-photo/artistic-background-wallpaper-with-color-halftone-effect_70549534.htm#fromView=search&page=1&position=22&uuid=820d1880-ea1a-44fd-8829-70bfdf2820a0">Image by Mateus Andre on Freepik</a>
var thisEnergyArray = []

@onready var player = $"../CharacterBody3D"

func _on_energy_change(energyArray):	
	var half_width = chunk_size / 2.0
	var half_depth = chunk_size / 2.0
	self.thisEnergyArray = energyArray.duplicate(true)
	
	var player_chunk = Vector2(
		0,
		0
	)
	var new_chunks = {} # Dictionary to store the chunks that should be loaded

	for i in range(-load_distance, load_distance + 1):
		for j in range(-load_distance, load_distance + 1):
			var chunk_pos = player_chunk + Vector2(i, j)
			new_chunks[chunk_pos] = true
			if not chunks.has(chunk_pos):
				for x in range(chunk_pos.x * chunk_size - half_width, chunk_pos.x * chunk_size + half_width):
					for z in range(chunk_pos.y * chunk_size - half_depth, chunk_pos.y * chunk_size + half_depth):
						var terrain_height = -terrain_noise.get_noise_2d(x, z) * map_depth
						var stone_density = stone_noise.get_noise_2d(x, z)
						
						var k = 0
						for y in range(-map_depth * 2, 0):
							k = k + 1
							var p = energyArray[k-1]
							if p > 0:
								set_cell_item(Vector3i(x, y, z), 0)

	# Unload any chunks that are too far from the player
	for chunk_pos in chunks.keys():
		if not new_chunks.has(chunk_pos):
			unload_chunk(chunk_pos.x, chunk_pos.y)
			

func _ready():
	terrain_noise.seed = 693169
	stone_noise.seed = 316931
	thisEnergyArray.resize(16)
	thisEnergyArray.fill(0)

func _process(_delta):
	self.clear()

func unload_chunk(chunk_x, chunk_z):
	var half_width = chunk_size / 2.0
	var half_depth = chunk_size / 2.0
	
	for x in range(chunk_x * chunk_size - half_width, chunk_x * chunk_size + half_width):
		for z in range(chunk_z * chunk_size - half_depth, chunk_z * chunk_size + half_depth):
			for y in range(-map_depth, 0):
				set_cell_item(Vector3i(x, y, z), -1) # -1 unloads the cell


	


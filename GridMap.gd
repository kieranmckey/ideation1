extends GridMap

var terrain_noise := FastNoiseLite.new()
var stone_noise := FastNoiseLite.new()
var map_width = 50 # Adjust this value for desired map width
var map_depth = 30 # Adjust this value for desired map depth
var water_level = -9 # Adjust this value for desired water level
var chunk_size = 10.0 # Adjust this value for desired chunk size
var chunks = {} # Dictionary to store generated chunks
var load_distance = 2 # Distance around the player to load chunks

@onready var player = $"../CharacterBody3D"

func _on_energy_change(energyArray):	
	var used_cells = self.get_used_cells()
	print(map_to_local(used_cells[1]))
	#for i in range(1,16):   
	#	var energy = energyArray[i]
	#	if energy > 0:
	#		var tween = get_tree().create_tween()
			

func _ready():
	terrain_noise.seed = 693169
	stone_noise.seed = 316931
	_process_chunk_loading()

func _process(_delta):
	_process_chunk_loading()

func _process_chunk_loading():
	var player_chunk = Vector2(
		floor(local_to_map(player.position).x / chunk_size),
		floor(local_to_map(player.position).z / chunk_size)
	)

	var new_chunks = {} # Dictionary to store the chunks that should be loaded

	for x in range(-load_distance, load_distance + 1):
		for z in range(-load_distance, load_distance + 1):
			var chunk_pos = player_chunk + Vector2(x, z)
			new_chunks[chunk_pos] = true
			if not chunks.has(chunk_pos):
				generate_chunk(chunk_pos.x, chunk_pos.y)

	# Unload any chunks that are too far from the player
	for chunk_pos in chunks.keys():
		if not new_chunks.has(chunk_pos):
			unload_chunk(chunk_pos.x, chunk_pos.y)

	chunks = new_chunks

func unload_chunk(chunk_x, chunk_z):
	var half_width = chunk_size / 2.0
	var half_depth = chunk_size / 2.0
	
	for x in range(chunk_x * chunk_size - half_width, chunk_x * chunk_size + half_width):
		for z in range(chunk_z * chunk_size - half_depth, chunk_z * chunk_size + half_depth):
			for y in range(-map_depth, 0):
				set_cell_item(Vector3i(x, y, z), -1) # -1 unloads the cell

func generate_chunk(chunk_x, chunk_z):
	var half_width = chunk_size / 2.0
	var half_depth = chunk_size / 2.0
	
	for x in range(chunk_x * chunk_size - half_width, chunk_x * chunk_size + half_width):
		for z in range(chunk_z * chunk_size - half_depth, chunk_z * chunk_size + half_depth):
			var terrain_height = -terrain_noise.get_noise_2d(x, z) * map_depth
			var stone_density = stone_noise.get_noise_2d(x, z)
			
			for y in range(-map_depth, 0):
				if y <= terrain_height:
					if (y > terrain_height - 8 and y < terrain_height - 5 and stone_density > 0.3) or y <= terrain_height - 8:
						set_cell_item(Vector3i(x, y, z), 1) # rock
					else:
						set_cell_item(Vector3i(x, y, z), 0) # dirt
				elif y < water_level:
					if terrain_height + 1 > y and y > terrain_height:
						set_cell_item(Vector3i(x, y, z), 3) # sand
					else:
						set_cell_item(Vector3i(x, y, z), 2) # water
	
	chunks[Vector2(chunk_x, chunk_z)] = true
	
func pulse_chunk(chunk_x, chunk_z, energyArray):
	var half_width = chunk_size / 2.0
	var half_depth = chunk_size / 2.0
	
	var ml = self.get_meshes()
	if ml != null:
		ml.is_empty()
	
	#for x in range(chunk_x * chunk_size - half_width, chunk_x * chunk_size + half_width):
		#for z in range(chunk_z * chunk_size - half_depth, chunk_z * chunk_size + half_depth):
			#for y in range(-map_depth, 0):
				#var ml2 = self.get_meshes()
				#for i in range(1,16):   
					#var energy = energyArray[i]
					#if energy > 0:
						#var tween = get_tree().create_tween()
						#tween.tween_property(ml, "mesh.material:albedo_color.a", 0.5, energy)

	

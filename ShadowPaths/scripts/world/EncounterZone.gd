extends Area2D
class_name EncounterZone

# Encounter zone properties
var zone_name: String = "Zone"
var encounter_rate: float = 0.1  # Probability per second
var min_encounter_interval: float = 5.0  # Minimum time between encounters

var encounter_table: Array[Dictionary] = []
var last_encounter_time: float = 0.0
var player_in_zone: bool = false

# Zone appearance
var zone_color: Color = Color(1.0, 0.0, 0.0, 0.3)

func _ready():
	# Set up area detection
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Visual representation
	setup_zone_visual()

	# Default encounter table if empty
	if encounter_table.is_empty():
		setup_default_encounters()

func setup_zone_visual():
	"""Create visual representation of encounter zone"""
	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(200, 200)
	collision_shape.shape = shape
	add_child(collision_shape)

	# Add visual indicator
	var sprite = Sprite2D.new()
	var texture = Texture2D.new()
	# Create a simple colored rectangle texture
	var image = Image.create(200, 200, false, Image.FORMAT_RGBA8)
	image.fill(zone_color)
	texture.set_image(image)
	sprite.texture = texture
	sprite.modulate = Color.TRANSPARENT  # Invisible by default
	add_child(sprite)

func setup_default_encounters():
	"""Set up default enemy encounters"""
	encounter_table = [
		{
			"enemy_type": "shadow_beast",
			"weight": 40,
			"min_level": 1,
			"max_level": 3,
			"corruption_threshold": 0.0
		},
		{
			"enemy_type": "corrupted_wildlife",
			"weight": 30,
			"min_level": 2,
			"max_level": 4,
			"corruption_threshold": 15.0
		},
		{
			"enemy_type": "corruption_manifestation",
			"weight": 20,
			"min_level": 3,
			"max_level": 5,
			"corruption_threshold": 35.0
		},
		{
			"enemy_type": "forbidden_guardian",
			"weight": 10,
			"min_level": 5,
			"max_level": 8,
			"corruption_threshold": 60.0
		}
	]

func _on_body_entered(body):
	if body is Player:
		player_in_zone = true
		print("Entered encounter zone: ", zone_name)

func _on_body_exited(body):
	if body is Player:
		player_in_zone = false
		print("Exited encounter zone: ", zone_name)

func _process(delta):
	if player_in_zone:
		check_encounter_timing(delta)

func check_encounter_timing(delta):
	"""Check if enough time has passed for potential encounter"""
	last_encounter_time += delta

	if last_encounter_time >= min_encounter_interval:
		last_encounter_time = 0.0
		return true
	return false

func is_player_in_zone(player_pos: Vector2) -> bool:
	"""Check if player position is within this zone"""
	# This would check actual zone boundaries
	# For simplicity, using Area2D detection instead
	return player_in_zone

func should_trigger_encounter() -> bool:
	"""Determine if an encounter should trigger based on probability"""
	# Base encounter rate
	var modified_rate = encounter_rate

	# Increase encounter rate based on player corruption
	if player_in_zone:
		var player = get_tree().get_first_node_in_group("player") as Player
		if player and player.game_state_manager:
			var corruption_bonus = player.game_state_manager.corruption_level / 200.0  # Max 0.5 bonus
			modified_rate += corruption_bonus

	# Check against probability
	return randf() < modified_rate

func get_encounter_data() -> Dictionary:
	"""Get encounter data based on current game state"""
	var player = get_tree().get_first_node_in_group("player") as Player
	if not player:
		return {}

	var player_corruption = player.game_state_manager.corruption_level if player.game_state_manager else 0.0

	# Filter encounters by corruption threshold
	var available_encounters = []
	for encounter in encounter_table:
		if encounter.corruption_threshold <= player_corruption:
			available_encounters.append(encounter)

	if available_encounters.is_empty():
		return encounter_table[0]  # Fallback to first encounter

	# Select encounter by weight
	var selected_encounter = select_encounter_by_weight(available_encounters)

	# Generate level within range
	var level = randi_range(selected_encounter.min_level, selected_encounter.max_level)

	# Scale difficulty based on player corruption
	var difficulty_multiplier = 1.0 + (player_corruption / 100.0)

	return {
		"enemy_type": selected_encounter.enemy_type,
		"level": level,
		"difficulty_multiplier": difficulty_multiplier,
		"zone_name": zone_name,
		"corruption_infused": player_corruption > 50.0
	}

func select_encounter_by_weight(encounters: Array[Dictionary]) -> Dictionary:
	"""Select an encounter from the table based on weight weights"""
	var total_weight = 0
	for encounter in encounters:
		total_weight += encounter.weight

	var roll = randf() * total_weight
	var current_weight = 0

	for encounter in encounters:
		current_weight += encounter.weight
		if roll <= current_weight:
			return encounter

	return encounters[0]  # Fallback

func set_encounter_rate(new_rate: float):
	"""Modify the encounter rate for this zone"""
	encounter_rate = clamp(new_rate, 0.0, 1.0)

func set_zone_corruption(corruption_level: float):
	"""Modify zone behavior based on corruption level"""
	if corruption_level > 50.0:
		# High corruption zones have more frequent encounters
		encounter_rate *= 1.5
		min_encounter_interval *= 0.7
	elif corruption_level > 25.0:
		# Moderate corruption
		encounter_rate *= 1.2
		min_encounter_interval *= 0.9

func disable_zone():
	"""Temporarily disable encounters in this zone"""
	player_in_zone = false

func enable_zone():
	"""Re-enable encounters in this zone"""
	player_in_zone = has_overlapping_bodies()
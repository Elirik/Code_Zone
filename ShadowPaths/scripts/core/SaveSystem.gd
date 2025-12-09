extends Node

class_name SaveSystem

# Save file configuration
const SAVE_VERSION: String = "1.0"
const MAX_SAVE_SLOTS: int = 3
const AUTO_SAVE_INTERVAL: float = 300.0  # 5 minutes

var save_slots: Array[Dictionary] = []
var auto_save_timer: Timer
var current_save_slot: int = -1

# References
var game_state_manager: GameStateManager
var player: Player

func _ready():
	# Set up auto-save timer
	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = AUTO_SAVE_INTERVAL
	auto_save_timer.timeout.connect(_on_auto_save)
	add_child(auto_save_timer)

	# Load save slot information
	load_save_slots()

func set_game_state_manager(gsm: GameStateManager):
	game_state_manager = gsm

func set_player(p: Player):
	player = p

func load_save_slots():
	"""Load information about existing save slots"""
	save_slots.clear()

	for i in range(MAX_SAVE_SLOTS):
		var save_path = get_save_path(i)
		var save_info = {
			"slot": i,
			"exists": FileAccess.file_exists(save_path),
			"data": null
		}

		if save_info.exists:
			save_info.data = read_save_file(save_path)

		save_slots.append(save_info)

func get_save_path(slot: int) -> String:
	"""Get file path for save slot"""
	return "user://save_slot_" + str(slot) + ".json"

func read_save_file(path: String) -> Dictionary:
	"""Read and parse save file"""
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_text)

	if parse_result != OK:
		print("Error parsing save file: ", path)
		return {}

	return json.data

func create_save_data() -> Dictionary:
	"""Create save data structure"""
	return {
		"version": SAVE_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"playtime": get_playtime_seconds(),

		# Player data
		"player_data": serialize_player(),

		# Game state
		"game_state": serialize_game_state(),

		# World state
		"world_state": serialize_world_state(),

		# System data
		"system_data": serialize_system_data()
	}

func serialize_player() -> Dictionary:
	"""Serialize player data"""
	if not player:
		return {}

	return {
		"position": {
			"x": player.global_position.x,
			"y": player.global_position.y
		},
		"current_map": "main",  # Would track current map
		"health": player.health,
		"max_health": player.max_health,
		"mana": player.mana,
		"max_mana": player.max_mana,
		"stats": {
			"attack": player.attack,
			"defense": player.defense,
			"speed": player.speed,
			"special": player.special
		},
		"inventory": serialize_inventory(),
		"abilities": serialize_abilities()
	}

func serialize_inventory() -> Dictionary:
	"""Serialize player inventory"""
	if not player or not player.inventory:
		return {}

	var inventory_data = {
		"gold": player.inventory.gold,
		"slots": []
	}

	for slot in player.inventory.slots:
		var slot_data = {
			"item_id": slot.item.item_id if slot.item else "",
			"quantity": slot.quantity
		}
		inventory_data.slots.append(slot_data)

	return inventory_data

func serialize_abilities() -> Array[Dictionary]:
	"""Serialize player abilities"""
	if not player:
		return []

	var abilities_data = []
	for ability in player.abilities:
		abilities_data.append({
			"name": ability.name,
			"damage": ability.damage,
			"mana_cost": ability.mana_cost,
			"required_corruption": ability.required_corruption
		})

	return abilities_data

func serialize_game_state() -> Dictionary:
	"""Serialize game state data"""
	if not game_state_manager:
		return {}

	return {
		"corruption_level": game_state_manager.corruption_level,
		"discovered_secrets": game_state_manager.discovered_secrets,
		"active_quests": game_state_manager.active_quests,
		"completed_quests": game_state_manager.completed_quests,
		"npc_relationships": game_state_manager.npc_relationships,
		"current_act": game_state_manager.current_act,
		"moral_alignment": game_state_manager.moral_alignment,
		"reputation_groups": game_state_manager.reputation_groups
	}

func serialize_world_state() -> Dictionary:
	"""Serialize world state data"""
	if not game_state_manager:
		return {}

	return {
		"world_changes": game_state_manager.world_changes,
		"visited_locations": [],  # Would track visited locations
		"defeated_enemies": [],   # Would track defeated enemies
		"opened_chests": [],      # Would track opened containers
		"activated_objects": []   # Would track activated interactables
	}

func serialize_system_data() -> Dictionary:
	"""Serialize system data"""
	return {
		"game_flags": [],         # Game-specific flags
		"audio_settings": {
			"master_volume": 1.0,
			"music_volume": 0.8,
			"sfx_volume": 0.9
		},
		"ui_settings": {
			"corruption_warnings": true,
			"auto_save_enabled": true
		}
	}

func save_game(slot: int) -> bool:
	"""Save game to specified slot"""
	print("Saving game to slot ", slot)

	var save_data = create_save_data()
	var save_path = get_save_path(slot)

	# Write save file
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if not file:
		print("Failed to create save file: ", save_path)
		return false

	var json_string = JSON.stringify(save_data)
	file.store_string(json_string)
	file.close()

	# Update save slot info
	current_save_slot = slot
	load_save_slots()

	print("Game saved successfully to slot ", slot)
	return true

func load_game(slot: int) -> bool:
	"""Load game from specified slot"""
	print("Loading game from slot ", slot)

	var save_path = get_save_path(slot)
	var save_data = read_save_file(save_path)

	if save_data.is_empty():
		print("No save data found in slot ", slot)
		return false

	# Validate save version
	if save_data.get("version") != SAVE_VERSION:
		print("Save file version mismatch")
		return false

	# Load data
	# Note: This is a simplified version. In practice, you'd want to
	# properly rebuild the game scene and restore all state

	load_player_data(save_data.get("player_data", {}))
	load_game_state(save_data.get("game_state", {}))
	load_world_state(save_data.get("world_state", {}))
	load_system_data(save_data.get("system_data", {}))

	current_save_slot = slot

	print("Game loaded successfully from slot ", slot)
	return true

func load_player_data(player_data: Dictionary):
	"""Load player data from save"""
	if player_data.is_empty() or not player:
		return

	# Restore position and stats
	player.global_position = Vector2(
		player_data.get("position", {}).get("x", 0),
		player_data.get("position", {}).get("y", 0)
	)

	player.health = player_data.get("health", 100)
	player.max_health = player_data.get("max_health", 100)
	player.mana = player_data.get("mana", 50)
	player.max_mana = player_data.get("max_mana", 50)

	var stats = player_data.get("stats", {})
	player.attack = stats.get("attack", 10)
	player.defense = stats.get("defense", 8)
	player.speed = stats.get("speed", 12)
	player.special = stats.get("special", 9)

	# Restore inventory
	load_inventory_data(player_data.get("inventory", {}))

	# Restore abilities
	load_abilities_data(player_data.get("abilities", []))

func load_inventory_data(inventory_data: Dictionary):
	"""Load inventory data from save"""
	if inventory_data.is_empty() or not player or not player.inventory:
		return

	player.inventory.gold = inventory_data.get("gold", 0)

	var slots = inventory_data.get("slots", [])
	for i in range(min(slots.size(), player.inventory.slots.size())):
		var slot_data = slots[i]
		var slot = player.inventory.slots[i]

		# This would need proper item loading system
		# For now, just clear the slot
		slot.item = null
		slot.quantity = 0

func load_abilities_data(abilities_data: Array):
	"""Load abilities data from save"""
	if abilities_data.is_empty() or not player:
		return

	player.abilities.clear()

	for ability_data in abilities_data:
		var ability = Ability.new()
		ability.name = ability_data.get("name", "Unknown")
		ability.damage = ability_data.get("damage", 0)
		ability.mana_cost = ability_data.get("mana_cost", 0)
		ability.required_corruption = ability_data.get("required_corruption", 0.0)

		player.abilities.append(ability)

func load_game_state(game_state: Dictionary):
	"""Load game state data from save"""
	if game_state.is_empty() or not game_state_manager:
		return

	game_state_manager.corruption_level = game_state.get("corruption_level", 0.0)
	game_state_manager.discovered_secrets = game_state.get("discovered_secrets", [])
	game_state_manager.active_quests = game_state.get("active_quests", {})
	game_state_manager.completed_quests = game_state.get("completed_quests", [])
	game_state_manager.npc_relationships = game_state.get("npc_relationships", {})
	game_state_manager.current_act = game_state.get("current_act", 1)
	game_state_manager.moral_alignment = game_state.get("moral_alignment", 0.0)

	var reputation_groups = game_state.get("reputation_groups", {})
	for key in reputation_groups:
		if game_state_manager.reputation_groups.has(key):
			game_state_manager.reputation_groups[key] = reputation_groups[key]

func load_world_state(world_state: Dictionary):
	"""Load world state data from save"""
	if world_state.is_empty() or not game_state_manager:
		return

	game_state_manager.world_changes = world_state.get("world_changes", {})
	# Would handle other world state restoration

func load_system_data(system_data: Dictionary):
	"""Load system data from save"""
	if system_data.is_empty():
		return

	# Would handle audio settings, UI settings, etc.
	var audio_settings = system_data.get("audio_settings", {})
	var ui_settings = system_data.get("ui_settings", {})

	# Apply settings to appropriate systems

func delete_save(slot: int) -> bool:
	"""Delete save file for specified slot"""
	var save_path = get_save_path(slot)

	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)
		load_save_slots()
		print("Deleted save slot ", slot)
		return true

	print("No save file to delete in slot ", slot)
	return false

func get_save_info(slot: int) -> Dictionary:
	"""Get information about save slot"""
	if slot < 0 or slot >= save_slots.size():
		return {}

	return save_slots[slot]

func get_playtime_seconds() -> int:
	"""Get current playtime in seconds"""
	# This would track actual playtime
	# For now, return a placeholder
	return 0

func format_playtime(seconds: int) -> String:
	"""Format playtime as readable string"""
	var hours = seconds / 3600
	var minutes = (seconds % 3600) / 60
	return "%02d:%02d" % [hours, minutes]

func auto_save():
	"""Perform automatic save"""
	if current_save_slot >= 0:
		print("Auto-saving to slot ", current_save_slot)
		save_game(current_save_slot)

func _on_auto_save():
	"""Handle auto-save timer timeout"""
	auto_save()

func enable_auto_save():
	"""Enable automatic saving"""
	if not auto_save_timer.is_connected("timeout", _on_auto_save):
		auto_save_timer.timeout.connect(_on_auto_save)
	auto_save_timer.start()

func disable_auto_save():
	"""Disable automatic saving"""
	auto_save_timer.stop()
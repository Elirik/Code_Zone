extends Node2D

@onready var player: Player = $World/Player
@onready var game_state_manager: GameStateManager = $GameStateManager
@onready var ui_controller: Control = $UI/UIController

# Exploration settings
var current_map: String = "village"
var camera: Camera2D
var npcs: Array[NPC] = []
var interactables: Array[Interactable] = []
var encounter_zones: Array[EncounterZone] = []

func _ready():
	# Set up camera following player
	setup_camera()

	# Connect player signals
	if player:
		player.health_changed.connect(_on_player_health_changed)
		player.mana_changed.connect(_on_player_mana_changed)

	# Connect game state signals
	if game_state_manager:
		game_state_manager.corruption_changed.connect(_on_corruption_changed)

	# Initialize UI
	if ui_controller:
		ui_controller.set_player(player)
		ui_controller.set_game_state_manager(game_state_manager)

func setup_camera():
	camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	add_child(camera)
	camera.enabled = true

	# Make camera follow player
	if player:
		camera.position = player.position

func _process(_delta):
	# Update camera position to follow player
	if player and camera:
		camera.global_position = player.global_position

	# Check for interactions
	if Input.is_action_just_pressed("interact"):
		check_interactions()

func check_interactions():
	"""Check for nearby interactable objects"""
	if not player:
		return

	var player_pos = player.global_position
	var interaction_range = 50.0

	# Check NPCs
	for npc in npcs:
		if npc.global_position.distance_to(player_pos) < interaction_range:
			if npc.can_interact():
				npc.interact(player)
				return

	# Check other interactables
	for interactable in interactables:
		if interactable.global_position.distance_to(player_pos) < interaction_range:
			if interactable.can_interact():
				interactable.interact(player)
				return

func add_npc(npc: NPC):
	npcs.append(npc)
	add_child(npc)

func add_interactable(interactable: Interactable):
	interactables.append(interactable)
	add_child(interactable)

func add_encounter_zone(zone: EncounterZone):
	encounter_zones.append(zone)
	add_child(zone)

func check_random_encounters():
	"""Check if a random encounter should trigger"""
	if not player:
		return

	var player_pos = player.global_position

	for zone in encounter_zones:
		if zone.is_player_in_zone(player_pos):
			if zone.should_trigger_encounter():
				start_combat(zone.get_encounter_data())
				break

func start_combat(encounter_data: Dictionary):
	"""Start a combat encounter"""
	print("Starting combat with: ", encounter_data)
	# This would transition to combat scene
	# For now, just print the encounter data

func _on_player_health_changed(new_health: int):
	"""Handle player health changes"""
	if ui_controller:
		ui_controller.update_health_bar(new_health, player.max_health)

func _on_player_mana_changed(new_mana: int):
	"""Handle player mana changes"""
	if ui_controller:
		ui_controller.update_mana_bar(new_mana, player.max_mana)

func _on_corruption_changed(new_corruption: float):
	"""Handle corruption level changes"""
	if ui_controller:
		ui_controller.update_corruption_meter(new_corruption)

	# Update NPC reactions based on corruption
	update_npc_reactions()

func update_npc_reactions():
	"""Update NPC behavior based on player corruption"""
	var corruption_stage = game_state_manager.get_corruption_stage()

	for npc in npcs:
		npc.update_reaction_to_corruption(corruption_stage)
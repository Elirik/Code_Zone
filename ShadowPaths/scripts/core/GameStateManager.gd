extends Node

class_name GameStateManager

signal corruption_changed(new_corruption: float)
signal choice_made(choice_id: String, consequences: Dictionary)
signal world_state_changed(location_id: String, changes: Dictionary)

# Core game state
var corruption_level: float = 0.0
var discovered_secrets: Array[String] = []
var active_quests: Dictionary = {}
var completed_quests: Array[String] = []
var npc_relationships: Dictionary = {}
var world_changes: Dictionary = {}

# Player progression
var current_act: int = 1
var player_position: Vector2 = Vector2.ZERO
var current_map: String = "village"

# Moral alignment tracking
var moral_alignment: float = 0.0  # -100 (evil) to +100 (good)
var reputation_groups: Dictionary = {
	"civilians": 0,
	"authorities": 0,
	"criminals": 0,
	"merchants": 0,
	"scholars": 0
}

# Corruption visual states
var corruption_visuals: Dictionary = {
	"eye_color": "normal",
	"skin_marks": [],
	"body_modifications": [],
	"aura_intensity": 0.0
}

const MAX_CORRUPTION: float = 100.0
const CORRUPTION_THRESHOLDS: Dictionary = {
	"stage_1": 25.0,  # Subtle changes
	"stage_2": 50.0,  # Obvious markings
	"stage_3": 75.0,  # Major transformation
	"stage_4": 100.0  # Complete corruption
}

func _ready():
	# Initialize game state
	reset_game_state()

func reset_game_state():
	"""Reset all game state to initial values"""
	corruption_level = 0.0
	discovered_secrets.clear()
	active_quests.clear()
	completed_quests.clear()
	npc_relationships.clear()
	world_changes.clear()
	current_act = 1
	moral_alignment = 0.0

	# Reset reputation
	for key in reputation_groups:
		reputation_groups[key] = 0

	# Reset corruption visuals
	corruption_visuals = {
		"eye_color": "normal",
		"skin_marks": [],
		"body_modifications": [],
		"aura_intensity": 0.0
	}

func record_choice(choice_id: String, consequences: Dictionary):
	"""Record a player choice and apply its consequences"""
	print("Recording choice: ", choice_id, " with consequences: ", consequences)

	# Apply corruption changes
	if consequences.has("corruption_impact"):
		apply_corruption_change(consequences.corruption_impact)

	# Apply moral alignment changes
	if consequences.has("moral_impact"):
		moral_alignment += consequences.moral_impact
		moral_alignment = clamp(moral_alignment, -100.0, 100.0)

	# Update faction reputations
	if consequences.has("faction_impact"):
		for faction in consequences.faction_impact:
			if reputation_groups.has(faction):
				reputation_groups[faction] += consequences.faction_impact[faction]

	# Track world changes
	if consequences.has("world_changes"):
		apply_world_changes(consequences.world_changes)

	# Update relationships
	if consequences.has("relationship_changes"):
		update_relationships(consequences.relationship_changes)

	# Handle discovered secrets
	if consequences.has("discovers_secret"):
		discover_secret(consequences.discovers_secret)

	# Quest progression
	if consequences.has("quest_progress"):
		handle_quest_progress(consequences.quest_progress)

	choice_made.emit(choice_id, consequences)

func apply_corruption_change(amount: float):
	"""Apply corruption change and update visual state"""
	var old_corruption = corruption_level
	corruption_level += amount
	corruption_level = clamp(corruption_level, 0.0, MAX_CORRUPTION)

	# Update corruption visuals based on new level
	update_corruption_visuals()

	if old_corruption != corruption_level:
		corruption_changed.emit(corruption_level)

		# Check for corruption threshold milestones
		check_corruption_milestones()

func update_corruption_visuals():
	"""Update visual corruption state based on current corruption level"""
	# Clear previous visual states
	corruption_visuals.skin_marks.clear()
	corruption_visuals.body_modifications.clear()

	# Apply visual changes based on corruption level
	if corruption_level >= CORRUPTION_THRESHOLDS.stage_1:
		# Stage 1: Subtle changes
		corruption_visuals.eye_color = "unnatural"
		corruption_visuals.skin_marks.append("faint_scars")
		corruption_visuals.aura_intensity = 0.2

	if corruption_level >= CORRUPTION_THRESHOLDS.stage_2:
		# Stage 2: Obvious markings
		corruption_visuals.eye_color = "glowing"
		corruption_visuals.skin_marks.append("glowing_runes")
		corruption_visuals.aura_intensity = 0.5

	if corruption_level >= CORRUPTION_THRESHOLDS.stage_3:
		# Stage 3: Major transformation
		corruption_visuals.eye_color = "monster"
		corruption_visuals.body_modifications.append("limb_distortion")
		corruption_visuals.aura_intensity = 0.8

	if corruption_level >= CORRUPTION_THRESHOLDS.stage_4:
		# Stage 4: Complete corruption
		corruption_visuals.eye_color = "abyss"
		corruption_visuals.body_modifications.append("full_transformation")
		corruption_visuals.aura_intensity = 1.0

func check_corruption_milestones():
	"""Check if player has reached corruption milestones"""
	for milestone_name in CORRUPTION_THRESHOLDS:
		var threshold = CORRUPTION_THRESHOLDS[milestone_name]
		if corruption_level >= threshold:
			print("Corruption milestone reached: ", milestone_name)
			# This could trigger story events, dialogue changes, etc.

func apply_world_changes(changes: Dictionary):
	"""Apply changes to the world state"""
	for location_id in changes:
		if not world_changes.has(location_id):
			world_changes[location_id] = {}

		# Merge changes
		for change_key in changes[location_id]:
			world_changes[location_id][change_key] = changes[location_id][change_key]

		world_state_changed.emit(location_id, changes[location_id])

func update_relationships(changes: Dictionary):
	"""Update NPC relationships"""
	for npc_id in changes:
		if not npc_relationships.has(npc_id):
			npc_relationships[npc_id] = {
				"friendship": 0,
				"trust": 0,
				"fear": 0
			}

		# Apply relationship changes
	 for relationship_type in changes[npc_id]:
			if npc_relationships[npc_id].has(relationship_type):
				npc_relationships[npc_id][relationship_type] += changes[npc_id][relationship_type]
				# Clamp values between -100 and 100
				npc_relationships[npc_id][relationship_type] = clamp(
					npc_relationships[npc_id][relationship_type],
					-100.0,
					100.0
				)

func discover_secret(secret_id: String):
	"""Add a discovered secret to the game state"""
	if not secret_id in discovered_secrets:
		discovered_secrets.append(secret_id)
		print("Secret discovered: ", secret_id)

func handle_quest_progress(quest_data: Dictionary):
	"""Handle quest progression"""
	var quest_id = quest_data.quest_id
	var action = quest_data.action  # "start", "complete", "update"

	match action:
		"start":
			if not active_quests.has(quest_id):
				active_quests[quest_id] = {
					"status": "active",
					"progress": 0,
					"objectives": quest_data.objectives if quest_data.has("objectives") else []
				}
		"complete":
			if active_quests.has(quest_id):
				active_quests[quest_id].status = "completed"
				if not quest_id in completed_quests:
					completed_quests.append(quest_id)
				active_quests.erase(quest_id)
		"update":
			if active_quests.has(quest_id):
				if quest_data.has("progress"):
					active_quests[quest_id].progress = quest_data.progress
				if quest_data.has("objectives"):
					active_quests[quest_id].objectives = quest_data.objectives

func get_corruption_stage() -> String:
	"""Get current corruption stage name"""
	if corruption_level >= CORRUPTION_THRESHOLDS.stage_4:
		return "stage_4"
	elif corruption_level >= CORRUPTION_THRESHOLDS.stage_3:
		return "stage_3"
	elif corruption_level >= CORRUPTION_THRESHOLDS.stage_2:
		return "stage_2"
	elif corruption_level >= CORRUPTION_THRESHOLDS.stage_1:
		return "stage_1"
	else:
		return "normal"

func can_access_area(area_id: String) -> bool:
	"""Check if player can access an area based on corruption state"""
	# This would contain logic for corruption-based access restrictions
	# For example, certain areas might be inaccessible at high corruption levels
	match area_id:
		"village_church":
			return corruption_level < CORRUPTION_THRESHOLDS.stage_2
		"forbidden_library":
			return corruption_level >= CORRUPTION_THRESHOLDS.stage_1
		"civilian_areas":
			return corruption_level < CORRUPTION_THRESHOLDS.stage_3
		_:
			return true

func get_npc_reaction(npc_id: String) -> String:
	"""Get how an NPC should react based on relationship and corruption"""
	if not npc_relationships.has(npc_id):
		# Default reaction based on corruption level
		if corruption_level < CORRUPTION_THRESHOLDS.stage_2:
			return "neutral"
		elif corruption_level < CORRUPTION_THRESHOLDS.stage_3:
			return "wary"
		else:
			return "fearful"

	var relationship = npc_relationships[npc_id]

	# Complex reaction logic based on relationship stats
	if relationship.fear > 50:
		return "fearful"
	elif relationship.friendship > 30:
		return "friendly"
	elif relationship.trust < -30:
		return "hostile"
	else:
		return "neutral"
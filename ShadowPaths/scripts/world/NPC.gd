extends CharacterBody2D
class_name NPC

@onready var game_state_manager: GameStateManager = get_node("/root/GameStateManager")
@onready var sprite: Sprite2D = $Sprite2D

# NPC properties
var npc_name: String = "NPC"
var dialogues: Dictionary = {}
var current_dialogue_index: int = 0
var relationship_level: float = 0.0  # -100 (hate) to +100 (friendship)

# Behavior settings
var can_interact: bool = true
var interaction_range: float = 50.0
var requires_corruption: float = 0.0  # Minimum corruption to interact

# Reactions to corruption
var corruption_reactions: Dictionary = {
	"normal": "friendly",
	"stage_1": "wary",
	"stage_2": "fearful",
	"stage_3": "hostile",
	"stage_4": "fleeing"
}

func _ready():
	# Initialize NPC with default dialogue
	if dialogues.is_empty():
		setup_default_dialogues()

func setup_default_dialogues():
	"""Set up default dialogue options"""
	dialogues = {
		"greeting": "Hello, traveler.",
		"corruption_low": "You seem like a decent person.",
		"corruption_medium": "There's something... different about you.",
		"corruption_high": "Stay away from me! You're changing!",
		"corruption_extreme": "Monster! Don't come near me!"
	}

func can_interact_with(player: Player) -> bool:
	"""Check if NPC can interact with player based on corruption"""
	if not can_interact:
		return false

	if player.game_state_manager.corruption_level < requires_corruption:
		return false

	# Check relationship
	var player_corruption = player.game_state_manager.corruption_level
	if player_corruption > 75.0 and relationship_level < -50:
		return false  # Too corrupt, relationship too poor

	return true

func get_reaction_to_corruption(corruption_stage: String) -> String:
	"""Get NPC reaction based on corruption stage"""
	return corruption_reactions.get(corruption_stage, "neutral")

func update_reaction_to_corruption(corruption_stage: String):
	"""Update NPC behavior based on player corruption"""
	var reaction = get_reaction_to_corruption(corruption_stage)

	match reaction:
		"friendly":
			sprite.modulate = Color.WHITE
			can_interact = true
		"wary":
			sprite.modulate = Color(0.9, 0.9, 1.0, 1.0)
			can_interact = true
		"fearful":
			sprite.modulate = Color(0.7, 0.7, 1.0, 1.0)
			can_interact = true
		"hostile":
			sprite.modulate = Color(0.6, 0.4, 0.4, 1.0)
			can_interact = false
		"fleeing":
			sprite.modulate = Color(0.4, 0.2, 0.2, 1.0)
			can_interact = false
			# Could implement fleeing behavior here

func interact(player: Player):
	"""Handle interaction with player"""
	if not can_interact_with(player):
		show_unavailable_dialogue(player)
		return

	# Get appropriate dialogue based on player corruption
	var dialogue_key = get_dialogue_key_for_corruption(player.game_state_manager.corruption_level)
	var dialogue = dialogues.get(dialogue_key, "I have nothing to say to you.")

	# Show dialogue
	if player.has_method("get_ui_controller"):
		var ui_controller = player.get_ui_controller()
		if ui_controller:
			ui_controller.show_dialogue(dialogue, npc_name)

	# Update relationship based on interaction
	update_relationship(player)

func get_dialogue_key_for_corruption(corruption_level: float) -> String:
	"""Get appropriate dialogue key based on corruption level"""
	if corruption_level < 25.0:
		return "corruption_low"
	elif corruption_level < 50.0:
		return "corruption_medium"
	elif corruption_level < 75.0:
		return "corruption_high"
	else:
		return "corruption_extreme"

func show_unavailable_dialogue(player: Player):
	"""Show dialogue when NPC cannot interact"""
	var player_corruption = player.game_state_manager.corruption_level

	if player_corruption < requires_corruption:
		var dialogue = "You are not ready to speak with me yet."
		if player.has_method("get_ui_controller"):
			var ui_controller = player.get_ui_controller()
			if ui_controller:
				ui_controller.show_dialogue(dialogue, npc_name)
	else:
		# Relationship too poor or corruption too high
		var dialogue = "I want nothing to do with you."
		if player.has_method("get_ui_controller"):
			var ui_controller = player.get_ui_controller()
			if ui_controller:
				ui_controller.show_dialogue(dialogue, npc_name)

func update_relationship(player: Player):
	"""Update relationship based on player corruption"""
	var player_corruption = player.game_state_manager.corruption_level

	# Higher corruption damages relationships
	if player_corruption > 50.0:
		relationship_level -= (player_corruption - 50.0) * 0.5
	elif player_corruption < 25.0:
		relationship_level += (25.0 - player_corruption) * 0.2

	relationship_level = clamp(relationship_level, -100.0, 100.0)

	# Update relationship in game state
	if game_state_manager:
		game_state_manager.update_relationships({
			npc_name: {
				"friendship": relationship_level * 0.01,
				"trust": relationship_level * 0.01,
				"fear": max(0, -relationship_level) * 0.02
			}
		})

func offer_quest(quest_id: String, player: Player):
	"""Offer a quest to the player"""
	# This would integrate with the quest system
	if player.has_method("get_ui_controller"):
		var ui_controller = player.get_ui_controller()
		if ui_controller:
			var quest_text = "I have a task for you. Will you accept?"
			var choices = ["Accept", "Decline"]
			ui_controller.show_choice_dialogue(quest_text, choices, _on_quest_choice.bind(quest_id, player))

func _on_quest_choice(choice: String, quest_id: String, player: Player):
	"""Handle player's choice about quest"""
	if choice == "Accept":
		# Start quest
		print("Quest accepted: ", quest_id)
		if game_state_manager:
			game_state_manager.handle_quest_progress({
				"quest_id": quest_id,
				"action": "start",
				"objectives": []
			})
	else:
		# Decline quest
		print("Quest declined: ", quest_id)
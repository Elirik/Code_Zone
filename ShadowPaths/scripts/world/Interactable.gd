extends Node2D
class_name Interactable

@onready var game_state_manager: GameStateManager = get_node("/root/GameStateManager")
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null

# Interactable properties
var interactable_name: String = "Object"
var interaction_text: String = "Press E to interact"
var can_interact: bool = true
var interaction_count: int = 0
var max_interactions: int = -1  # -1 for unlimited

# Corruption requirements
var requires_corruption: float = 0.0
var corruption_changes_interaction: bool = false

# Choice system
var presents_choice: bool = false
var choice_data: Dictionary = {}

# Secret discovery
var is_secret: bool = false
var discovery_corruption_required: float = 0.0

func _ready():
	# Initialize interaction
	if is_secret:
		hide_secret()  # Hide secrets initially

func can_interact_with(player: Player) -> bool:
	if not can_interact:
		return false

	if max_interactions > 0 and interaction_count >= max_interactions:
		return false

	if player.game_state_manager.corruption_level < requires_corruption:
		return false

	# Secrets require minimum corruption to discover
	if is_secret and player.game_state_manager.corruption_level < discovery_corruption_required:
		return false

	return true

func interact(player: Player):
	"""Handle interaction with player"""
	if not can_interact_with(player):
		show_unavailable_interaction(player)
		return

	interaction_count += 1

	if presents_choice:
		show_choice(player)
	else:
		perform_interaction(player)

func perform_interaction(player: Player):
	"""Perform the main interaction logic"""
	# Default interaction - show description
	if player.has_method("get_ui_controller"):
		var ui_controller = player.get_ui_controller()
		if ui_controller:
			ui_controller.show_dialogue(get_interaction_text(player), interactable_name)

	# Apply effects
	apply_interaction_effects(player)

func get_interaction_text(player: Player) -> String:
	"""Get interaction text based on player state"""
	var base_text = interaction_text

	if corruption_changes_interaction:
		var corruption = player.game_state_manager.corruption_level
		if corruption > 50.0:
			base_text += "\n\nThe object seems to react to your corruption..."
			base_text += "\nStrange whispers echo in your mind."
		elif corruption > 25.0:
			base_text += "\n\nYou feel a subtle connection to this object."

	return base_text

func show_choice(player: Player):
	"""Show choice dialogue to player"""
	if choice_data.is_empty():
		perform_interaction(player)
		return

	if player.has_method("get_ui_controller"):
		var ui_controller = player.get_ui_controller()
		if ui_controller:
			var choices = choice_data.get("choices", [])
			var description = choice_data.get("description", "Make a choice:")
			ui_controller.show_choice_dialogue(description, choices, _on_choice_selected.bind(player))

func _on_choice_selected(choice: String, player: Player):
	"""Handle player's choice"""
	print("Player chose: ", choice)

	# Find the choice consequences
	var consequences = {}
	for choice_option in choice_data.get("options", []):
		if choice_option.get("text") == choice:
			consequences = choice_option.get("consequences", {})
			break

	# Apply consequences through game state manager
	if game_state_manager and not consequences.is_empty():
		game_state_manager.record_choice(choice_data.get("id", "unknown_choice"), consequences)

	# Show result
	if player.has_method("get_ui_controller"):
		var ui_controller = player.get_ui_controller()
		if ui_controller:
			var result_text = choice_option.get("result", "You made your choice.")
			ui_controller.show_dialogue(result_text, interactable_name)

func apply_interaction_effects(player: Player):
	"""Apply effects of interaction"""
	# This would handle things like:
	# - Giving items
	# - Triggering events
	# - Modifying player stats
	# - Unlocking new areas

	# Example: discovering forbidden knowledge
	if is_secret:
		discover_secret(player)

func discover_secret(player: Player):
	"""Handle discovery of secret"""
	if game_state_manager:
		game_state_manager.discover_secret(interactable_name)

	# Grant corruption for forbidden knowledge
	if discovery_corruption_required > 0:
		game_state_manager.apply_corruption_change(discovery_corruption_required * 0.1)

	# Show discovery message
	if player.has_method("get_ui_controller"):
		var ui_controller = player.get_ui_controller()
		if ui_controller:
			ui_controller.show_dialogue("You have discovered a forbidden secret!", "Secret Discovered")

func show_unavailable_interaction(player: Player):
	"""Show message when interaction is not available"""
	var reason = ""

	if player.game_state_manager.corruption_level < requires_corruption:
		reason = "You are not ready for this yet."
	elif max_interactions > 0 and interaction_count >= max_interactions:
		reason = "There is nothing more to learn from this."
	else:
		reason = "You cannot interact with this right now."

	if player.has_method("get_ui_controller"):
		var ui_controller = player.get_ui_controller()
		if ui_controller:
			ui_controller.show_dialogue(reason, interactable_name)

func hide_secret():
	"""Hide secret interactable"""
	if sprite:
		sprite.modulate.a = 0.3  # Make semi-transparent
	# Could also make collision disabled or use other hiding methods

func reveal_secret():
	"""Reveal secret interactable"""
	if sprite:
		sprite.modulate.a = 1.0
	is_secret = false

func check_reveal_condition(player: Player):
	"""Check if secret should be revealed to player"""
	if is_secret and player.game_state_manager.corruption_level >= discovery_corruption_required:
		reveal_secret()
extends Node

class_name CombatEngine

signal combat_started(participants: Array)
signal combat_ended(victory: bool)
signal turn_started(actor: Node)
signal turn_completed(actor: Node)
signal action_executed(actor: Node, action: Dictionary, target: Node)

# Combat state
enum CombatState {
	IDLE,
	PLAYER_TURN,
	ENEMY_TURN,
	ANIMATING,
	VICTORY,
	DEFEAT
}

var current_state: CombatState = CombatState.IDLE
var participants: Array[Node] = []
var turn_order: Array[Node] = []
var current_turn_index: int = 0
var round_number: int = 1

# Player reference
var player: Player
var enemies: Array[Node] = []

# UI references
var combat_ui: Control

# Animation
var is_animating: bool = false
var animation_queue: Array[Dictionary] = []

func _ready():
	# Set up combat engine
	pass

func start_combat(player_party: Array, enemy_party: Array):
	"""Initialize and start combat"""
	print("Starting combat!")

	# Store participants
	player = player_party[0] if player_party.size() > 0 else null
	enemies = enemy_party.duplicate()

	# Clear previous state
	participants.clear()
	turn_order.clear()
	current_turn_index = 0
	round_number = 1

	# Build turn order
	participants.append_array(player_party)
	participants.append_array(enemies)
	setup_turn_order()

	# Change state
	current_state = CombatState.IDLE
	transition_to_combat()

	combat_started.emit(participants)

func setup_turn_order():
	"""Determine turn order based on speed stats"""
	# Sort all participants by speed (descending)
	participants.sort_custom(_compare_speed)

	# Create turn order
	turn_order = participants.duplicate()
	current_turn_index = 0

	print("Turn order: ", _get_participant_names())

func _compare_speed(a: Node, b: Node) -> bool:
	var speed_a = a.get("speed") if a.has_method("get") else 0
	var speed_b = b.get("speed") if b.has_method("get") else 0
	return speed_a > speed_b

func _get_participant_names() -> Array[String]:
	var names: Array[String] = []
	for participant in participants:
		var name = participant.get("name") if participant.has_method("get") else "Unknown"
		names.append(name)
	return names

func transition_to_combat():
	"""Transition from exploration to combat mode"""
	current_state = CombatState.PLAYER_TURN

	# Set player combat state
	if player:
		player.in_combat = true

	# Set up combat UI
	setup_combat_ui()

	# Start first turn
	execute_next_turn()

func setup_combat_ui():
	"""Set up combat user interface"""
	# This would load and configure combat UI
	# For now, just print combat info
	print("=== COMBAT START ===")
	print("Player: ", player.health if player else "None", " HP")
	for enemy in enemies:
		print("Enemy: ", enemy.get("name", "Unknown"), " HP")

func execute_next_turn():
	"""Execute the next turn in combat"""
	if current_state == CombatState.VICTORY or current_state == CombatState.DEFEAT:
		return

	var current_actor = turn_order[current_turn_index]

	# Check if current actor is still alive
	if not is_alive(current_actor):
		advance_turn()
		return

	# Determine turn type
	if current_actor == player:
		current_state = CombatState.PLAYER_TURN
		execute_player_turn(current_actor)
	else:
		current_state = CombatState.ENEMY_TURN
		execute_enemy_turn(current_actor)

	turn_started.emit(current_actor)

func execute_player_turn(actor: Player):
	"""Handle player's turn"""
	print("Player's turn - HP: ", actor.health, "/", actor.max_health)

	# Show combat UI with player options
	show_player_options(actor)

func show_player_options(player: Player):
	"""Display available actions for player"""
	var options = []

	# Get available abilities
	var abilities = player.get_available_abilities()
	for ability in abilities:
		options.append({
			"type": "ability",
			"text": ability.name,
			"ability": ability
		})

	# Add item option
	options.append({
		"type": "item",
		"text": "Use Item",
		"ability": null
	})

	# Add flee option (if not boss fight)
	options.append({
		"type": "flee",
		"text": "Flee",
		"ability": null
	})

	# Show options (this would integrate with UI)
	print("Available actions:")
	for i in range(options.size()):
		print(i + 1, ". ", options[i].text)

	# For now, simulate player choosing first ability
	if options.size() > 0:
		execute_action(player, options[0], get_random_target(options[0]))

func execute_enemy_turn(enemy: Node):
	"""Handle enemy's turn"""
	print("Enemy turn: ", enemy.get("name", "Unknown"))

	# Simple AI: attack random player character
	var action = {
		"type": "attack",
		"damage": enemy.get("attack", 10),
		"text": "Attack"
	}

	var target = player  # For now, always target player

	execute_action(enemy, action, target)

func execute_action(actor: Node, action: Dictionary, target: Node):
	"""Execute a combat action"""
	current_state = CombatState.ANIMATING

	print(actor.get("name", "Unknown"), " uses ", action.text, " on ", target.get("name", "Unknown"))

	# Apply damage
	if action.has("damage") and action.damage > 0:
		var damage = calculate_damage(actor, target, action)
		target.take_damage(damage, action.get("damage_type", "physical"))

	# Apply ability effects
	if action.has("ability") and action.ability:
		actor.use_ability(action.ability, target)

	# Apply item effects
	if action.type == "item" and actor == player:
		# Show inventory for item selection
		use_item_in_combat(actor)

	# Handle flee
	if action.type == "flee" and actor == player:
		attempt_flee()

	action_executed.emit(actor, action, target)

	# Queue turn completion
	await get_tree().create_timer(1.0).timeout  # Animation delay
	complete_turn(actor)

func calculate_damage(attacker: Node, defender: Node, action: Dictionary) -> int:
	var base_damage = action.get("damage", 0)
	var damage_type = action.get("damage_type", "physical")

	# Get stats
	var attack_stat = attacker.get("attack", 10)
	var defense_stat = defender.get("defense", 5)

	# Calculate damage with variance
	var damage = base_damage + (attack_stat * 0.5)
	damage -= defense_stat * 0.3
	damage = max(1, int(damage))

	# Add random variance (+/- 20%)
	damage = int(damage * (0.8 + randf() * 0.4))

	return damage

func use_item_in_combat(actor: Player):
	"""Handle item usage during combat"""
	# This would show item selection UI
	print("Using item in combat")
	# For now, just pass the turn

func attempt_flee():
	"""Attempt to flee from combat"""
	var flee_chance = 0.5 + (player.speed / 50.0)  # Base 50% + speed bonus

	if randf() < flee_chance:
		print("Fled successfully!")
		end_combat(false)  # False means not a victory/defeat
	else:
		print("Failed to flee!")

func complete_turn(actor: Node):
	"""Complete current actor's turn"""
	turn_completed.emit(actor)

	# Update status effects
	if actor.has_method("update_status_effects"):
		actor.update_status_effects()

	# Check battle end conditions
	if check_battle_end():
		return

	# Advance to next turn
	advance_turn()

func advance_turn():
	"""Move to next turn"""
	current_turn_index += 1

	# Check if we need to start a new round
	if current_turn_index >= turn_order.size():
		current_turn_index = 0
		round_number += 1
		print("--- Round ", round_number, " ---")

		# Reduce ability cooldowns
		for participant in participants:
			if participant.has_method("abilities"):
				for ability in participant.abilities:
					ability.reduce_cooldown()

	execute_next_turn()

func is_alive(actor: Node) -> bool:
	if not actor:
		return false

	var health = actor.get("health") if actor.has_method("get") else 0
	return health > 0

func check_battle_end() -> bool:
	"""Check if combat should end"""
	var player_alive = false
	var enemies_alive = 0

	for participant in participants:
		if not is_alive(participant):
			continue

		if participant == player:
			player_alive = true
		elif participant in enemies:
			enemies_alive += 1

	if not player_alive:
		current_state = CombatState.DEFEAT
		end_combat(false)  # Player defeated
		return true
	elif enemies_alive == 0:
		current_state = CombatState.VICTORY
		end_combat(true)  # Player victorious
		return true

	return false

func end_combat(victory: bool):
	"""End combat and return to exploration"""
	print("Combat ended! Victory: ", victory)

	# Set player combat state
	if player:
		player.in_combat = false

	# Handle victory/defeat rewards
	if victory:
		handle_victory()
	else:
		handle_defeat()

	combat_ended.emit(victory)
	current_state = CombatState.IDLE

func handle_victory():
	"""Handle combat victory rewards"""
	print("Victory! Gaining rewards...")

	# Calculate experience and gold
	var total_exp = 0
	var total_gold = 0

	for enemy in enemies:
		if not is_alive(enemy):
			total_exp += enemy.get("exp_reward", 20)
			total_gold += enemy.get("gold_reward", 10)

	# Give rewards to player
	if player:
		if player.has_method("gain_experience"):
			player.gain_experience(total_exp)

		if player.inventory:
			player.inventory.add_gold(total_gold)

	print("Gained ", total_exp, " experience and ", total_gold, " gold")

func handle_defeat():
	"""Handle combat defeat"""
	print("Defeat! Game over...")

	# This would trigger game over state
	# For now, just return to main scene

func get_random_target(action: Dictionary) -> Node:
	"""Get random valid target for action"""
	if action.get("type") == "ability" and action.ability:
		var ability = action.ability
		# This would check ability target type
		# For now, just return random enemy
		return enemies[randi() % enemies.size()] if enemies.size() > 0 else null

	# Default: return random enemy
	return enemies[randi() % enemies.size()] if enemies.size() > 0 else null

func get_available_targets(actor: Node, action: Dictionary) -> Array[Node]:
	"""Get list of valid targets for action"""
	var targets = []

	# This would implement proper target filtering
	# For now, return all living enemies
	for enemy in enemies:
		if is_alive(enemy):
			targets.append(enemy)

	return targets

func get_combat_status() -> Dictionary:
	"""Get current combat status for UI"""
	return {
		"state": current_state,
		"round": round_number,
		"current_actor": turn_order[current_turn_index] if current_turn_index < turn_order.size() else null,
		"player_hp": player.health if player else 0,
		"player_max_hp": player.max_health if player else 0,
		"enemies": enemies.map(func(e): return {
			"name": e.get("name", "Unknown"),
			"hp": e.get("health", 0),
			"max_hp": e.get("max_health", 100)
		})
	}
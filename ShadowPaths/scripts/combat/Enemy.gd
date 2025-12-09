extends CharacterBody2D
class_name Enemy

# Enemy properties
var enemy_name: String = "Enemy"
var enemy_type: String = "beast"
var level: int = 1

# Combat stats
var health: int = 50
var max_health: int = 50
var attack: int = 8
var defense: int = 5
var speed: int = 8
var special: int = 6

# Rewards
var exp_reward: int = 20
var gold_reward: int = 10

# Visual
@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = $HealthBar

# Corruption properties
var corruption_infused: bool = false
var corruption_level: float = 0.0

func _ready():
	setup_enemy()

func setup_enemy():
	"""Initialize enemy based on type and level"""
	apply_level_scaling()
	setup_visual()
	update_health_bar()

func apply_level_scaling():
	"""Scale stats based on level"""
	var level_multiplier = 1.0 + (level - 1) * 0.2

	health = int(50 * level_multiplier)
	max_health = health
	attack = int(8 * level_multiplier)
	defense = int(5 * level_multiplier)
	speed = int(8 * level_multiplier)
	special = int(6 * level_multiplier)

	# Scale rewards
	exp_reward = int(20 * level_multiplier)
	gold_reward = int(10 * level_multiplier)

func setup_visual():
	"""Set up enemy visual appearance"""
	if sprite:
		# Apply corruption visual effects
		if corruption_infused:
			sprite.modulate = Color(0.7, 0.4, 0.9, 1.0)

func update_health_bar():
	"""Update health bar display"""
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health

func take_damage(damage: int, damage_type: String = "physical"):
	"""Apply damage to enemy"""
	var actual_damage = calculate_damage_received(damage, damage_type)
	health -= actual_damage
	health = max(0, health)

	update_health_bar()

	# Play damage effect
	play_damage_effect()

	if health <= 0:
		die()

func calculate_damage_received(base_damage: int, damage_type: String) -> int:
	"""Calculate actual damage after defenses"""
	var damage = base_damage

	# Apply defense reduction for physical damage
	if damage_type == "physical":
		damage = max(1, damage - defense / 2)

	# Corruption type deals extra damage to normal enemies
	if damage_type == "corruption" and not corruption_infused:
		damage = int(damage * 1.2)
	# Corruption type heals corrupted enemies
	elif damage_type == "corruption" and corruption_infused:
		heal(damage / 2)
		damage = 0

	return damage

func heal(amount: int):
	"""Heal the enemy"""
	health += amount
	health = min(health, max_health)
	update_health_bar()

func die():
	"""Handle enemy death"""
	print(enemy_name, " defeated!")

	# Play death effect
	play_death_effect()

	# Remove from scene
	queue_free()

func play_damage_effect():
	"""Play damage visual effect"""
	if sprite:
		# Flash red
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE if not corruption_infused else Color(0.7, 0.4, 0.9, 1.0)

func play_death_effect():
	"""Play death visual effect"""
	if sprite:
		# Fade out
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 0.5)

func get_corruption_resistance() -> float:
	"""Get resistance to corruption damage"""
	if corruption_infused:
		return 1.0  # Immune
	else:
		return 0.0  # Full damage

func get_available_actions() -> Array[Dictionary]:
	"""Get list of available combat actions"""
	var actions = []

	# Basic attack
	actions.append({
		"name": "Attack",
		"type": "damage",
		"damage": attack,
		"damage_type": "physical",
		"weight": 50
	})

	# Corruption-based actions for corrupted enemies
	if corruption_infused:
		actions.append({
			"name": "Corruption Touch",
			"type": "damage",
			"damage": attack * 1.5,
			"damage_type": "corruption",
			"weight": 30
		})

		actions.append({
			"name": "Void Scream",
			"type": "debuff",
			"damage": 0,
			"damage_type": "status",
			"weight": 20
		})

	# Special attacks based on enemy type
	match enemy_type:
		"shadow_beast":
			actions.append({
				"name": "Shadow Strike",
				"type": "damage",
				"damage": attack * 1.3,
				"damage_type": "dark",
				"weight": 25
			})
		"corrupted_wildlife":
			actions.append({
				"name": "Frenzied Bite",
				"type": "damage",
				"damage": attack * 1.2,
				"damage_type": "physical",
				"weight": 30
			})

	return actions

func select_action(target: Node) -> Dictionary:
	"""AI: Select action based on weights and situation"""
	var actions = get_available_actions()
	var total_weight = 0

	# Calculate total weight
	for action in actions:
		total_weight += action.get("weight", 1)

	# Select action by weight
	var roll = randf() * total_weight
	var current_weight = 0

	for action in actions:
		current_weight += action.get("weight", 1)
		if roll <= current_weight:
			# Set target for the action
			action.target = target
			return action

	# Fallback: return first action
	if actions.size() > 0:
		actions[0].target = target
		return actions[0]

	# Default attack
	return {
		"name": "Attack",
		"type": "damage",
		"damage": attack,
		"damage_type": "physical",
		"target": target
	}

func apply_corruption(corruption_amount: float):
	"""Apply corruption to enemy"""
	corruption_level = min(100.0, corruption_level + corruption_amount)

	if corruption_level >= 50.0 and not corruption_infused:
		become_corrupted()

func become_corrupted():
	"""Transform enemy into corrupted version"""
	print(enemy_name, " becomes corrupted!")
	corruption_infused = true

	# Increase stats
	attack = int(attack * 1.3)
	max_health = int(max_health * 1.2)
	health = max_health

	# Update appearance
	setup_visual()
	update_health_bar()

func get_description() -> String:
	"""Get enemy description for combat UI"""
	var desc = enemy_name + " (Lv " + str(level) + ")"

	if corruption_infused:
		desc += " [Corrupted]"

	desc += "\nHP: " + str(health) + "/" + str(max_health)
	desc += "\nATK: " + str(attack) + " DEF: " + str(defense)

	return desc

# Static factory methods for creating different enemy types
static func create_enemy(enemy_type: String, enemy_level: int, corruption: float = 0.0) -> Enemy:
	var enemy = preload("res://scripts/combat/Enemy.gd").new()
	enemy.enemy_type = enemy_type
	enemy.level = enemy_level
	enemy.apply_corruption(corruption)

	# Set specific properties based on type
	match enemy_type:
		"shadow_beast":
			enemy.enemy_name = "Shadow Beast"
			enemy.attack += 2
			enemy.speed += 3
		"corrupted_wildlife":
			enemy.enemy_name = "Corrupted Wolf"
			enemy.speed += 5
			enemy.defense -= 1
		"corruption_manifestation":
			enemy.enemy_name = "Corruption Manifestation"
			enemy.special += 4
			enemy.defense += 2
		"forbidden_guardian":
			enemy.enemy_name = "Forbidden Guardian"
			enemy.attack += 4
			enemy.defense += 4
			enemy.speed -= 2

	return enemy
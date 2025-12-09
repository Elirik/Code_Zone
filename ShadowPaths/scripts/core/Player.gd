extends CharacterBody2D

class_name Player

@onready var game_state_manager: GameStateManager = get_node("/root/GameStateManager")

# Core stats
var health: int = 100
var max_health: int = 100
var mana: int = 50
var max_mana: int = 50

# Combat stats
var attack: int = 10
var defense: int = 8
var speed: int = 12
var special: int = 9

# Movement
@export var move_speed: float = 200.0
var is_moving: bool = false
var facing_direction: Vector2 = Vector2.DOWN

# Combat state
var in_combat: bool = false
var abilities: Array[Ability] = []
var status_effects: Array[StatusEffect] = []

# Inventory
var inventory: InventorySystem

# Visual corruption references
@onready var sprite: Sprite2D = $Sprite2D
@onready var corruption_particles: GPUParticles2D = $CorruptionParticles
@onready var aura_light: PointLight2D = $AuraLight

# Animation
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal health_changed(new_health: int)
signal mana_changed(new_mana: int)
signal corruption_visuals_updated(corruption_stage: String)
signal ability_learned(ability: Ability)

func _ready():
	# Initialize player
	inventory = InventorySystem.new()

	# Connect to game state signals
	if game_state_manager:
		game_state_manager.corruption_changed.connect(_on_corruption_changed)

	# Start with basic abilities
	learn_basic_abilities()

func _physics_process(_delta):
	if not in_combat:
		handle_movement()

func handle_movement():
	var input_direction = Vector2.ZERO

	# Get input
	if Input.is_action_pressed("move_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("move_right"):
		input_direction.x += 1
	if Input.is_action_pressed("move_up"):
		input_direction.y -= 1
	if Input.is_action_pressed("move_down"):
		input_direction.y += 1

	# Normalize diagonal movement
	if input_direction.length() > 0:
		input_direction = input_direction.normalized()
		velocity = input_direction * move_speed
		is_moving = true
		facing_direction = input_direction

		# Update animation based on direction
		update_movement_animation(input_direction)
	else:
		velocity = Vector2.ZERO
		is_moving = false
		play_idle_animation()

	move_and_slide()

func update_movement_animation(direction: Vector2):
	"""Play appropriate movement animation based on direction"""
	if direction.y < -0.5:  # Moving up
		animation_player.play("walk_up")
	elif direction.y > 0.5:  # Moving down
		animation_player.play("walk_down")
	elif direction.x < -0.5:  # Moving left
		animation_player.play("walk_left")
	elif direction.x > 0.5:  # Moving right
		animation_player.play("walk_right")

func play_idle_animation():
	"""Play idle animation based on last facing direction"""
	if facing_direction.y < -0.5:  # Facing up
		animation_player.play("idle_up")
	elif facing_direction.y > 0.5:  # Facing down
		animation_player.play("idle_down")
	elif facing_direction.x < -0.5:  # Facing left
		animation_player.play("idle_left")
	else:  # Facing right or default
		animation_player.play("idle_right")

func take_damage(damage: int, damage_type: String = "physical"):
	"""Apply damage to player"""
	var actual_damage = calculate_damage_received(damage, damage_type)
	health -= actual_damage
	health = max(0, health)

	health_changed.emit(health)

	# Play damage animation/effect
	play_damage_effect()

	if health <= 0:
		die()

func calculate_damage_received(base_damage: int, damage_type: String) -> int:
	"""Calculate actual damage after defenses"""
	var damage = base_damage

	# Apply defense reduction for physical damage
	if damage_type == "physical":
		damage = max(1, damage - defense / 2)

	# Apply corruption-based resistances/vulnerabilities
	var corruption_stage = game_state_manager.get_corruption_stage()
	match corruption_stage:
		"stage_3", "stage_4":
			# High corruption provides some damage resistance
			damage = int(damage * 0.8)
		_:
			pass

	return damage

func heal(amount: int):
	"""Heal the player"""
	health += amount
	health = min(health, max_health)
	health_changed.emit(health)

	# Play healing effect
	play_heal_effect()

func use_mana(amount: int) -> bool:
	"""Use mana, return false if not enough"""
	if mana >= amount:
		mana -= amount
		mana = max(0, mana)
		mana_changed.emit(mana)
		return true
	return false

func restore_mana(amount: int):
	"""Restore mana"""
	mana += amount
	mana = min(mana, max_mana)
	mana_changed.emit(mana)

func learn_basic_abilities():
	"""Learn starting abilities"""
	var basic_attack = Ability.new()
	basic_attack.name = "Strike"
	basic_attack.damage = 10
	basic_attack.mana_cost = 0
	basic_attack.description = "A basic physical attack"
	abilities.append(basic_attack)

	var defend = Ability.new()
	defend.name = "Defend"
	defend.damage = 0
	defend.mana_cost = 5
	defend.description = "Increase defense for one turn"
	defend.is_defensive = true
	abilities.append(defend)

func learn_ability(ability: Ability):
	"""Learn a new ability"""
	if not ability in abilities:
		abilities.append(ability)
		ability_learned.emit(ability)
		print("Learned ability: ", ability.name)

func get_available_abilities() -> Array[Ability]:
	"""Get abilities that can be used based on current state"""
	var available = []

	for ability in abilities:
		# Check mana requirements
		if ability.mana_cost <= mana:
			# Check corruption requirements
			if ability.required_corruption <= game_state_manager.corruption_level:
				available.append(ability)

	return available

func use_ability(ability: Ability, target = null):
	"""Use an ability"""
	if not ability in abilities:
		return false

	if use_mana(ability.mana_cost):
		# Apply ability effects
		if ability.damage > 0 and target:
			target.take_damage(ability.damage, ability.damage_type)

		if ability.is_defensive:
			apply_defensive_buff(ability)

		# Play ability animation/effect
		play_ability_effect(ability)

		return true

	return false

func apply_defensive_buff(ability: Ability):
	"""Apply defensive buffs from abilities"""
	if ability.name == "Defend":
		# Temporary defense boost would be handled by status effects
		var defense_buff = StatusEffect.new()
		defense_buff.name = "Defense Boost"
		defense_buff.stat_changes = {"defense": 5}
		defense_buff.duration = 1  # One turn
		add_status_effect(defense_buff)

func add_status_effect(effect: StatusEffect):
	"""Add a status effect to the player"""
	# Remove existing effect of same type
	for i in range(status_effects.size() - 1, -1, -1):
		if status_effects[i].name == effect.name:
			status_effects.remove_at(i)

	status_effects.append(effect)

func update_status_effects():
	"""Update all status effects (called each turn)"""
	for i in range(status_effects.size() - 1, -1, -1):
		var effect = status_effects[i]
		effect.duration -= 1

		if effect.duration <= 0:
			remove_status_effect(effect)
			status_effects.remove_at(i)

func remove_status_effect(effect: StatusEffect):
	"""Remove a status effect and apply its removal changes"""
	# This would handle removing stat modifications
	pass

func _on_corruption_changed(new_corruption: float):
	"""Handle corruption level changes"""
	update_corruption_appearance()

	# Check for corruption-granted abilities
	check_corruption_abilities()

func update_corruption_appearance():
	"""Update visual appearance based on corruption"""
	var corruption_stage = game_state_manager.get_corruption_stage()
	var visuals = game_state_manager.corruption_visuals

	# Update sprite appearance (this would require actual sprite modifications)
	match corruption_stage:
		"stage_1":
			# Subtle changes - could apply shader or tint
			sprite.modulate = Color(0.9, 0.9, 1.0, 1.0)
		"stage_2":
			# More obvious changes
			sprite.modulate = Color(0.8, 0.7, 1.0, 1.0)
		"stage_3":
			# Major transformation
			sprite.modulate = Color(0.6, 0.4, 0.9, 1.0)
		"stage_4":
			# Complete corruption
			sprite.modulate = Color(0.4, 0.2, 0.7, 1.0)

	# Update corruption particles
	if corruption_particles:
		corruption_particles.emitting = new_corruption > 0.0
		corruption_particles.amount_ratio = new_corruption / 100.0

	# Update aura light
	if aura_light:
		aura_light.energy = visuals.aura_intensity
		aura_light.color = get_corruption_aura_color()

	corruption_visuals_updated.emit(corruption_stage)

func get_corruption_aura_color() -> Color:
	"""Get aura color based on corruption level"""
	var corruption = game_state_manager.corruption_level

	# Interpolate from blue to purple to dark red
	if corruption < 33.0:
		return Color(0.5, 0.5, 1.0, 1.0)  # Blue
	elif corruption < 66.0:
		return Color(0.7, 0.3, 0.9, 1.0)  # Purple
	else:
		return Color(0.8, 0.2, 0.3, 1.0)  # Dark red

func check_corruption_abilities():
	"""Check for new abilities granted by corruption"""
	var corruption = game_state_manager.corruption_level

	# Example corruption-granted abilities
	if corruption >= 25.0 and not has_ability("Dark Sight"):
		var dark_sight = Ability.new()
		dark_sight.name = "Dark Sight"
		dark_sight.damage = 0
		dark_sight.mana_cost = 10
		dark_sight.required_corruption = 25.0
		dark_sight.description = "Reveal hidden secrets in the area"
		learn_ability(dark_sight)

	if corruption >= 50.0 and not has_ability("Corruption Touch"):
		var corruption_touch = Ability.new()
		corruption_touch.name = "Corruption Touch"
		corruption_touch.damage = 20
		corruption_touch.mana_cost = 15
		corruption_touch.required_corruption = 50.0
		corruption_touch.damage_type = "corruption"
		corruption_touch.description = "Damage enemy with corrupting energy"
		learn_ability(corruption_touch)

func has_ability(ability_name: String) -> bool:
	"""Check if player has a specific ability"""
	for ability in abilities:
		if ability.name == ability_name:
			return true
	return false

func play_damage_effect():
	"""Play damage visual/audio effects"""
	# Screen shake, damage sound, etc.
	# This would be expanded with actual effects
	pass

func play_heal_effect():
	"""Play healing visual/audio effects"""
	# Healing particles, sound, etc.
	pass

func play_ability_effect(ability: Ability):
	"""Play ability-specific effects"""
	# Different effects based on ability type
	pass

func die():
	"""Handle player death"""
	print("Player died")
	# This would trigger game over scene or other death handling
	# For now, just print a message
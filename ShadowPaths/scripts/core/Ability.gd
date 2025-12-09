extends Resource
class_name Ability

@export var name: String = ""
@export var description: String = ""
@export var damage: int = 0
@export var damage_type: String = "physical"  # physical, magical, corruption
@export var mana_cost: int = 0
@export var cooldown: int = 0  # Turns
@export var current_cooldown: int = 0

# Special properties
@export var is_defensive: bool = false
@export var is_passive: bool = false
@export var required_corruption: float = 0.0
@export var stat_changes: Dictionary = {}  # For buff abilities

# Visual and audio
@export var animation_name: String = ""
@export var sound_effect: String = ""
@export var particle_effect: String = ""

# Status effects this ability applies
@export var status_effects: Array[StatusEffect] = []

func _init():
	# Initialize default values
	pass

func can_use(caster_mana: int, caster_corruption: float) -> bool:
	"""Check if ability can be used"""
	if current_cooldown > 0:
		return false

	if mana_cost > caster_mana:
		return false

	if required_corruption > caster_corruption:
		return false

	return true

func use(caster, target = null):
	"""Apply ability effects"""
	if not can_use(caster.mana, caster.corruption_level if caster.has_method("get_corruption_level") else 0):
		return false

	# Use mana
	if caster.has_method("use_mana"):
		if not caster.use_mana(mana_cost):
			return false

	# Apply damage
	if damage > 0 and target and target.has_method("take_damage"):
		target.take_damage(damage, damage_type)

	# Apply stat changes
	if not stat_changes.is_empty() and caster.has_method("add_status_effect"):
		var buff_effect = StatusEffect.new()
		buff_effect.name = name + " Buff"
		buff_effect.stat_changes = stat_changes
		buff_effect.duration = 1  # Default 1 turn
		caster.add_status_effect(buff_effect)

	# Apply status effects
	for effect in status_effects:
		if target and target.has_method("add_status_effect"):
			target.add_status_effect(effect)

	# Set cooldown
	current_cooldown = cooldown

	return true

func reduce_cooldown():
	"""Reduce cooldown by 1 turn"""
	if current_cooldown > 0:
		current_cooldown -= 1

func get_description() -> String:
	"""Get formatted ability description"""
	var desc = description

	# Add damage info
	if damage > 0:
		desc += "\nDamage: " + str(damage)
		if damage_type != "physical":
			desc += " (" + damage_type + ")"

	# Add mana cost
	if mana_cost > 0:
		desc += "\nMana Cost: " + str(mana_cost)

	# Add cooldown
	if cooldown > 0:
		desc += "\nCooldown: " + str(cooldown) + " turns"

	# Add corruption requirement
	if required_corruption > 0:
		desc += "\nRequires Corruption: " + str(required_corruption)

	return desc
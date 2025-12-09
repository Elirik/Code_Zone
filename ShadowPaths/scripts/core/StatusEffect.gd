extends Resource
class_name StatusEffect

@export var name: String = ""
@export var description: String = ""
@export var duration: int = 0  # Turns remaining, -1 for permanent
@export var is_positive: bool = false  # Buff vs Debuff

# Stat modifications
@export var stat_changes: Dictionary = {
	"attack": 0,
	"defense": 0,
	"speed": 0,
	"special": 0
}

# Damage over time
@export var damage_per_turn: int = 0
@export var damage_type: String = "poison"  # poison, burn, corruption, heal

# Visual effects
@export var particle_effect: String = ""
@export var color_tint: Color = Color.WHITE

func _init():
	pass

func apply(character):
	"""Apply the status effect to a character"""
	# This would modify character stats
	# Implementation depends on character system
	pass

func remove(character):
	"""Remove the status effect from a character"""
	# This would restore character stats
	# Implementation depends on character system
	pass

func on_turn_start(character):
	"""Called at the start of character's turn"""
	if damage_per_turn != 0:
		if damage_per_turn > 0:
			character.take_damage(damage_per_turn, damage_type)
		else:
			character.heal(abs(damage_per_turn))

func on_turn_end(character):
	"""Called at the end of character's turn"""
	duration -= 1

func is_expired() -> bool:
	"""Check if effect should be removed"""
	return duration == 0

func get_display_text() -> String:
	"""Get text for UI display"""
	var text = name

	if duration > 0:
		text += " (" + str(duration) + ")"

	return text
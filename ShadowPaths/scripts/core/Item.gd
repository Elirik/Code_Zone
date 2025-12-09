extends Resource
class_name Item

@export var item_id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var category: String = "consumables"  # weapons, armor, consumables, materials, key_items, forbidden_knowledge
@export var rarity: String = "common"  # common, uncommon, rare, legendary, forbidden

# Item properties
@export var stackable: bool = true
@export var max_stack: int = 99
@export var value: int = 0
@export var consumable: bool = false

# Equipment properties (for weapons/armor)
@export var slot_type: String = ""  # weapon, armor_head, armor_body, armor_accessory
@export var stat_bonuses: Dictionary = {
	"attack": 0,
	"defense": 0,
	"speed": 0,
	"special": 0
}

# Consumable effects
@export var effects: Dictionary = {
	"heal": 0,
	"mana": 0,
	"corruption": 0,
	"status_effects": []
}

# Forbidden knowledge properties
@export var corruption_cost: float = 0.0
@export var knowledge_power: int = 0
@export var forbidden_effects: Array[String] = []

# Visual/audio
@export var icon_texture: Texture2D
@export var use_sound: String = ""

func _init():
	pass

func can_use(user: Node) -> bool:
	"""Check if item can be used by user"""
	if category == "forbidden_knowledge":
		# Forbidden knowledge requires minimum corruption
		if user.has_method("game_state_manager"):
			var user_corruption = user.game_state_manager.corruption_level
			return user_corruption >= corruption_cost

	return true

func get_description() -> String:
	"""Get formatted item description"""
	var desc = description

	# Add value
	if value > 0:
		desc += "\nValue: " + str(value) + " gold"

	# Add stat bonuses for equipment
	for stat in stat_bonuses:
		if stat_bonuses[stat] > 0:
			desc += "\n" + stat.capitalize() + ": +" + str(stat_bonuses[stat])

	# Add consumable effects
	if effects.has("heal") and effects.heal > 0:
		desc += "\nRestores " + str(effects.heal) + " HP"

	if effects.has("mana") and effects.mana > 0:
		desc += "\nRestores " + str(effects.mana) + " MP"

	if effects.has("corruption") and effects.corruption != 0:
		var corr_text = "Increases" if effects.corruption > 0 else "Decreases"
		desc += "\n" + corr_text + " corruption by " + str(abs(effects.corruption))

	# Add forbidden knowledge info
	if category == "forbidden_knowledge":
		if corruption_cost > 0:
			desc += "\nRequires corruption: " + str(corruption_cost)
		if knowledge_power > 0:
			desc += "\nKnowledge power: " + str(knowledge_power)

	return desc

func get_rarity_color() -> Color:
	"""Get color based on item rarity"""
	match rarity:
		"common":
			return Color.WHITE
		"uncommon":
			return Color.GREEN
		"rare":
			return Color.BLUE
		"legendary":
			return Color.GOLD
		"forbidden":
			return Color.PURPLE
		_:
			return Color.WHITE
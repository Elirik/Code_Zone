extends Resource
class_name ItemDatabase

# Item database for Shadow Paths
static var items: Dictionary = {}

func _init():
	create_items()

func create_items():
	# Consumables
	items["health_potion"] = create_health_potion()
	items["mana_potion"] = create_mana_potion()
	items["corruption_tonic"] = create_corruption_tonic()
	items["purifying_herb"] = create_purifying_herb()

	# Weapons
	items["rusty_sword"] = create_rusty_sword()
	items["dark_blade"] = create_dark_blade()
	items["scholar_staff"] = create_scholar_staff()

	# Armor
	items["worn_robes"] = create_worn_robes()
	items["corrupted_armor"] = create_corrupted_armor()

	# Materials
	items["forbidden_essence"] = create_forbidden_essence()
	items["dark_crystal"] = create_dark_crystal()

	# Key Items
	items["village_key"] = create_village_key()
	items["ancient_scroll"] = create_ancient_scroll()

	# Forbidden Knowledge
	items["forbidden_text"] = create_forbidden_text()
	items["shadow_ritual"] = create_shadow_ritual()

# Consumable Items
func create_health_potion() -> Item:
	var item = Item.new()
	item.item_id = "health_potion"
	item.name = "Health Potion"
	item.description = "A basic healing potion that restores 50 HP."
	item.category = "consumables"
	item.rarity = "common"
	item.stackable = true
	item.max_stack = 99
	item.value = 25
	item.consumable = true
	item.effects = {
		"heal": 50
	}
	return item

func create_mana_potion() -> Item:
	var item = Item.new()
	item.item_id = "mana_potion"
	item.name = "Mana Potion"
	item.description = "A blue potion that restores 30 MP."
	item.category = "consumables"
	item.rarity = "common"
	item.stackable = true
	item.max_stack = 99
	item.value = 20
	item.consumable = true
	item.effects = {
		"mana": 30
	}
	return item

func create_corruption_tonic() -> Item:
	var item = Item.new()
	item.item_id = "corruption_tonic"
	item.name = "Corruption Tonic"
	item.description = "A dark brew that heals 75 HP but increases corruption by 5%."
	item.category = "consumables"
	item.rarity = "uncommon"
	item.stackable = true
	item.max_stack = 20
	item.value = 50
	item.consumable = true
	item.effects = {
		"heal": 75,
		"corruption": 5.0
	}
	return item

func create_purifying_herb() -> Item:
	var item = Item.new()
	item.item_id = "purifying_herb"
	item.name = "Purifying Herb"
	item.description = "A rare herb that reduces corruption by 3% but damages you."
	item.category = "consumables"
	item.rarity = "rare"
	item.stackable = true
	item.max_stack = 10
	item.value = 100
	item.consumable = true
	item.effects = {
		"heal": -20,  # Damages player
		"corruption": -3.0
	}
	return item

# Weapons
func create_rusty_sword() -> Item:
	var item = Item.new()
	item.item_id = "rusty_sword"
	item.name = "Rusty Sword"
	item.description = "An old sword covered in rust. Better than nothing."
	item.category = "weapons"
	item.rarity = "common"
	item.stackable = false
	item.value = 40
	item.slot_type = "weapon"
	item.stat_bonuses = {
		"attack": 5
	}
	return item

func create_dark_blade() -> Item:
	var item = Item.new()
	item.item_id = "dark_blade"
	item.name = "Dark Blade"
	item.description = "A blade forged in darkness. Requires 25% corruption to wield."
	item.category = "weapons"
	item.rarity = "rare"
	item.stackable = false
	item.value = 200
	item.slot_type = "weapon"
	item.corruption_cost = 25.0
	item.stat_bonuses = {
		"attack": 12,
		"special": 3
	}
	return item

func create_scholar_staff() -> Item:
	var item = Item.new()
	item.item_id = "scholar_staff"
	item.name = "Scholar's Staff"
	item.description = "A wooden staff used by scholars. Boosts magical abilities."
	item.category = "weapons"
	item.rarity = "uncommon"
	item.stackable = false
	item.value = 80
	item.slot_type = "weapon"
	item.stat_bonuses = {
		"special": 8,
		"mana": 20
	}
	return item

# Armor
func create_worn_robes() -> Item:
	var item = Item.new()
	item.item_id = "worn_robes"
	item.name = "Worn Robes"
	item.description = "Simple robes that offer minimal protection."
	item.category = "armor"
	item.rarity = "common"
	item.stackable = false
	item.value = 30
	item.slot_type = "armor_body"
	item.stat_bonuses = {
		"defense": 3
	}
	return item

func create_corrupted_armor() -> Item:
	var item = Item.new()
	item.item_id = "corrupted_armor"
	item.name = "Corrupted Armor"
	item.description = "Armor twisted by dark forces. Requires 40% corruption."
	item.category = "armor"
	item.rarity = "rare"
	item.stackable = false
	item.value = 250
	item.slot_type = "armor_body"
	item.corruption_cost = 40.0
	item.stat_bonuses = {
		"defense": 15,
		"attack": 5
	}
	return item

# Materials
func create_forbidden_essence() -> Item:
	var item = Item.new()
	item.item_id = "forbidden_essence"
	item.name = "Forbidden Essence"
	item.description = "A dark liquid pulsing with unnatural energy."
	item.category = "materials"
	item.rarity = "rare"
	item.stackable = true
	item.max_stack = 50
	item.value = 150
	return item

func create_dark_crystal() -> Item:
	var item = Item.new()
	item.item_id = "dark_crystal"
	item.name = "Dark Crystal"
	item.description = "A crystal that absorbs all light around it."
	item.category = "materials"
	item.rarity = "legendary"
	item.stackable = true
	item.max_stack = 10
	item.value = 500
	return item

# Key Items
func create_village_key() -> Item:
	var item = Item.new()
	item.item_id = "village_key"
	item.name = "Village Key"
	item.description = "A key that opens important doors in the village."
	item.category = "key_items"
	item.rarity = "common"
	item.stackable = false
	item.value = 0
	return item

func create_ancient_scroll() -> Item:
	var item = Item.new()
	item.item_id = "ancient_scroll"
	item.name = "Ancient Scroll"
	item.description = "A scroll containing forgotten knowledge. Reading it may have consequences."
	item.category = "key_items"
	item.rarity = "uncommon"
	item.stackable = false
	item.value = 100
	return item

# Forbidden Knowledge
func create_forbidden_text() -> Item:
	var item = Item.new()
	item.item_id = "forbidden_text"
	item.name = "Forbidden Text"
	item.description = "A book containing knowledge that mortals were never meant to know."
	item.category = "forbidden_knowledge"
	item.rarity = "forbidden"
	item.stackable = false
	item.value = 0
	item.corruption_cost = 15.0
	item.knowledge_power = 25
	item.forbidden_effects = ["corruption_touch", "dark_vision"]
	return item

func create_shadow_ritual() -> Item:
	var item = Item.new()
	item.item_id = "shadow_ritual"
	item.name = "Shadow Ritual"
	item.description = "Instructions for a ritual that grants power at a terrible cost."
	item.category = "forbidden_knowledge"
	item.rarity = "forbidden"
	item.stackable = false
	item.value = 0
	item.corruption_cost = 35.0
	item.knowledge_power = 50
	item.forbidden_effects = ["summon_shadows", "shadow_step"]
	return item

# Utility functions
static func get_item(item_id: String) -> Item:
	return items.get(item_id, null)

static func get_items_by_category(category: String) -> Array[Item]:
	var result: Array[Item] = []
	for item_id in items:
		var item = items[item_id]
		if item.category == category:
			result.append(item)
	return result

static func get_items_by_rarity(rarity: String) -> Array[Item]:
	var result: Array[Item] = []
	for item_id in items:
		var item = items[item_id]
		if item.rarity == rarity:
			result.append(item)
	return result

static func get_forbidden_knowledge_by_corruption(corruption_level: float) -> Array[Item]:
	var result: Array[Item] = []
	for item_id in items:
		var item = items[item_id]
		if item.category == "forbidden_knowledge" and item.corruption_cost <= corruption_level:
			result.append(item)
	return result

static func create_random_loot(corruption_level: float = 0.0) -> Item:
	"""Create random loot based on corruption level"""
	var available_items = []

	# Add basic items always
	available_items.append_array(get_items_by_category("consumables"))

	# Add equipment based on corruption
	if corruption_level >= 25.0:
		available_items.append_array(get_items_by_category("weapons"))
		available_items.append_array(get_items_by_category("armor"))

	# Add forbidden knowledge at high corruption
	if corruption_level >= 50.0:
		available_items.append_array(get_items_by_category("forbidden_knowledge"))

	if available_items.size() > 0:
		return available_items[randi() % available_items.size()]

	# Fallback to health potion
	return get_item("health_potion")
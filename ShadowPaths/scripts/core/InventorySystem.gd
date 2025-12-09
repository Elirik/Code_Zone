extends Node
class_name InventorySystem

signal item_added(item: Item)
signal item_removed(item: Item)
signal inventory_changed

# Inventory configuration
var max_slots: int = 30
var slots: Array[InventorySlot] = []
var gold: int = 100

# Categories for organization
var categories: Dictionary = {
	"weapons": [],
	"armor": [],
	"consumables": [],
	"materials": [],
	"key_items": [],
	"forbidden_knowledge": []
}

func _ready():
	# Initialize empty inventory slots
	slots.clear()
	for i in range(max_slots):
		var slot = InventorySlot.new()
		slot.slot_index = i
		slots.append(slot)

func add_item(item: Item, quantity: int = 1) -> bool:
	"""Add item to inventory, returns true if successful"""
	# Check for existing stackable item first
	if item.stackable:
		var existing_slot = find_item_slot(item)
		if existing_slot:
			existing_slot.quantity += quantity
			item_added.emit(item)
			inventory_changed.emit()
			return true

	# Find empty slot
	var empty_slot = find_empty_slot()
	if empty_slot:
		empty_slot.item = item
		empty_slot.quantity = quantity
		categorize_item(item)
		item_added.emit(item)
		inventory_changed.emit()
		return true

	# No space available
	return false

func remove_item(item: Item, quantity: int = 1) -> bool:
	"""Remove item from inventory, returns true if successful"""
	var slot = find_item_slot(item)
	if slot and slot.quantity >= quantity:
		slot.quantity -= quantity
		if slot.quantity <= 0:
			slot.item = null
			uncategorize_item(item)

		item_removed.emit(item)
		inventory_changed.emit()
		return true

	return false

func has_item(item: Item, quantity: int = 1) -> bool:
	"""Check if inventory contains enough of an item"""
	var slot = find_item_slot(item)
	if slot:
		return slot.quantity >= quantity
	return false

func get_item_quantity(item: Item) -> int:
	"""Get quantity of specific item"""
	var slot = find_item_slot(item)
	if slot:
		return slot.quantity
	return 0

func find_item_slot(item: Item) -> InventorySlot:
	"""Find slot containing specific item"""
	for slot in slots:
		if slot.item and slot.item.item_id == item.item_id:
			return slot
	return null

func find_empty_slot() -> InventorySlot:
	"""Find first empty inventory slot"""
	for slot in slots:
		if not slot.item:
			return slot
	return null

func categorize_item(item: Item):
	"""Add item to appropriate category"""
	if not categories.has(item.category):
		categories[item.category] = []

	if not item.item_id in categories[item.category]:
		categories[item.category].append(item.item_id)

func uncategorize_item(item: Item):
	"""Remove item from category tracking"""
	if categories.has(item.category):
		var index = categories[item.category].find(item.item_id)
		if index >= 0:
			categories[item.category].remove_at(index)

func get_items_by_category(category: String) -> Array[Item]:
	"""Get all items in a specific category"""
	var items: Array[Item] = []
	if categories.has(category):
		for item_id in categories[category]:
			var slot = find_item_slot_by_id(item_id)
			if slot and slot.item:
				items.append(slot.item)
	return items

func find_item_slot_by_id(item_id: String) -> InventorySlot:
	"""Find slot by item ID"""
	for slot in slots:
		if slot.item and slot.item.item_id == item_id:
			return slot
	return null

func add_gold(amount: int):
	"""Add gold to inventory"""
	gold += amount
	inventory_changed.emit()

func remove_gold(amount: int) -> bool:
	"""Remove gold from inventory, returns true if successful"""
	if gold >= amount:
		gold -= amount
		inventory_changed.emit()
		return true
	return false

func has_gold(amount: int) -> bool:
	"""Check if has enough gold"""
	return gold >= amount

func get_total_items() -> int:
	"""Get total number of unique items in inventory"""
	var count = 0
	for slot in slots:
		if slot.item:
			count += 1
	return count

func get_used_slots() -> int:
	"""Get number of used inventory slots"""
	return get_total_items()

func get_free_slots() -> int:
	"""Get number of free inventory slots"""
	return max_slots - get_used_slots()

func is_full() -> bool:
	"""Check if inventory is full"""
	return get_free_slots() == 0

func sort_inventory(sort_type: String = "name"):
	"""Sort inventory by specified criteria"""
	# This would implement different sorting methods
	# Name, type, value, quantity, etc.
	match sort_type:
		"name":
			slots.sort_custom(_sort_by_name)
		"type":
			slots.sort_custom(_sort_by_type)
		"quantity":
			slots.sort_custom(_sort_by_quantity)
		_:
			pass

	inventory_changed.emit()

func _sort_by_name(a: InventorySlot, b: InventorySlot) -> bool:
	if not a.item or not b.item:
		return a.item != null
	return a.item.name < b.item.name

func _sort_by_type(a: InventorySlot, b: InventorySlot) -> bool:
	if not a.item or not b.item:
		return a.item != null
	return a.item.category < b.item.category

func _sort_by_quantity(a: InventorySlot, b: InventorySlot) -> bool:
	return a.quantity > b.quantity

func use_consumable(item: Item, user: Node) -> bool:
	"""Use a consumable item"""
	if item.category != "consumables":
		return false

	if not has_item(item):
		return false

	# Apply item effects
	apply_item_effects(item, user)

	# Remove one from inventory
	remove_item(item, 1)

	return true

func apply_item_effects(item: Item, user: Node):
	"""Apply consumable item effects"""
	match item.item_id:
		"health_potion":
			if user.has_method("heal"):
				user.heal(50)
		"mana_potion":
			if user.has_method("restore_mana"):
				user.restore_mana(30)
		"corruption_tonic":
			# Small healing but increases corruption
			if user.has_method("heal") and user.has_method("game_state_manager"):
				user.heal(75)
				user.game_state_manager.apply_corruption_change(5.0)
		_:
			# Generic effects based on item properties
			if item.effects.has("heal"):
				if user.has_method("heal"):
					user.heal(item.effects.heal)

			if item.effects.has("mana"):
				if user.has_method("restore_mana"):
					user.restore_mana(item.effects.mana)

			if item.effects.has("corruption"):
				if user.has_method("game_state_manager"):
					user.game_state_manager.apply_corruption_change(item.effects.corruption)
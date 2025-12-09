extends Resource
class_name InventorySlot

var slot_index: int = 0
var item: Item = null
var quantity: int = 0

func _init():
	pass

func is_empty() -> bool:
	return item == null

func is_full() -> bool:
	if not item:
		return false
	return quantity >= item.max_stack

func can_add_item(new_item: Item, add_quantity: int = 1) -> bool:
	if is_empty():
		return true

	return item.item_id == new_item.item_id and quantity + add_quantity <= item.max_stack

func add_item(new_item: Item, add_quantity: int = 1) -> bool:
	if not can_add_item(new_item, add_quantity):
		return false

	if is_empty():
		item = new_item

	quantity += add_quantity
	return true

func remove_item(remove_quantity: int = 1) -> bool:
	if quantity < remove_quantity:
		return false

	quantity -= remove_quantity

	if quantity <= 0:
		item = null
		quantity = 0

	return true

func get_stack_size() -> int:
	return quantity if item else 0

func get_max_stack_size() -> int:
	return item.max_stack if item else 0
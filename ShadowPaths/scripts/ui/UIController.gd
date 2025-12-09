extends Control

@onready var health_bar: ProgressBar = $"../HealthBar"
@onready var health_label: Label = $"../HealthLabel"
@onready var mana_bar: ProgressBar = $"../ManaBar"
@onready var mana_label: Label = $"../ManaLabel"
@onready var corruption_meter: ProgressBar = $"../CorruptionMeter"
@onready var corruption_label: Label = $"../CorruptionLabel"
@onready var dialogue_panel: Panel = $"../DialoguePanel"
@onready var dialogue_text: RichTextLabel = $"../DialoguePanel/DialogueText"
@onready var inventory_panel: Panel = $"../InventoryPanel"
@onready var inventory_grid: GridContainer = $"../InventoryPanel/InventoryGrid"

var player: Player
var game_state_manager: GameStateManager
var is_inventory_open: bool = false

func _ready():
	# Set up input handling
	set_process_input(true)

	# Hide panels initially
	if dialogue_panel:
		dialogue_panel.visible = false
	if inventory_panel:
		inventory_panel.visible = false

func _input(event):
	if event.is_action_pressed("open_inventory"):
		toggle_inventory()

func set_player(p: Player):
	player = p

func set_game_state_manager(gsm: GameStateManager):
	game_state_manager = gsm

func update_health_bar(current: int, maximum: int):
	if health_bar:
		health_bar.max_value = maximum
		health_bar.value = current

func update_mana_bar(current: int, maximum: int):
	if mana_bar:
		mana_bar.max_value = maximum
		mana_bar.value = current

func update_corruption_meter(corruption: float):
	if corruption_meter:
		corruption_meter.value = corruption

	# Update corruption meter color based on level
	if corruption >= 75.0:
		corruption_meter.tint_progress = Color(0.8, 0.2, 0.3, 1)  # Red
	elif corruption >= 50.0:
		corruption_meter.tint_progress = Color(0.7, 0.3, 0.9, 1)  # Purple
	elif corruption >= 25.0:
		corruption_meter.tint_progress = Color(0.5, 0.5, 1.0, 1)  # Blue
	else:
		corruption_meter.tint_progress = Color(0.6, 0.2, 0.8, 1)  # Default

func show_dialogue(text: String, speaker: String = ""):
	if dialogue_panel and dialogue_text:
		dialogue_panel.visible = true

		# Format dialogue with speaker name
		var formatted_text = text
		if speaker != "":
			formatted_text = "[b]" + speaker + ":[/b]\n" + text

		dialogue_text.text = formatted_text

		# Add typewriter effect
		typewriter_effect(dialogue_text, formatted_text)

func hide_dialogue():
	if dialogue_panel:
		dialogue_panel.visible = false

func typewriter_effect(label: RichTextLabel, text: String):
	"""Simple typewriter effect for dialogue"""
	label.visible_characters = 0
	label.text = text

	# Create timer for typewriter effect
	var timer = Timer.new()
	timer.wait_time = 0.03  # Speed of typewriter
	timer.timeout.connect(_on_typewriter_tick.bind(label, text))
	add_child(timer)
	timer.start()

func _on_typewriter_tick(label: RichTextLabel, full_text: String):
	if label.visible_characters < full_text.length():
		label.visible_characters += 1
	else:
		# Effect finished, remove timer
		for child in get_children():
			if child is Timer:
				child.queue_free()

func show_choice_dialogue(text: String, choices: Array[String], callback: Callable):
	"""Show dialogue with player choices"""
	# This would extend the dialogue system to include choice buttons
	# For now, just show the text and handle choices via input
	show_dialogue(text + "\n\nChoices: " + str(choices))

func toggle_inventory():
	if is_inventory_open:
		close_inventory()
	else:
		open_inventory()

func open_inventory():
	if not inventory_panel or not player:
		return

	is_inventory_open = true
	inventory_panel.visible = true
	update_inventory_display()

func close_inventory():
	if inventory_panel:
		inventory_panel.visible = false
	is_inventory_open = false

func update_inventory_display():
	if not inventory_grid or not player:
		return

	# Clear existing inventory items
	for child in inventory_grid.get_children():
		child.queue_free()

	# Add inventory items
	var inventory = player.inventory
	if inventory:
		for slot in inventory.slots:
			if slot.item:
				var item_button = Button.new()
				item_button.text = slot.item.name
				if slot.quantity > 1:
					item_button.text += " x" + str(slot.quantity)

				# Set color based on rarity
				item_button.modulate = slot.item.get_rarity_color()

				# Connect item use
				item_button.pressed.connect(_on_item_button_pressed.bind(slot.item))

				inventory_grid.add_child(item_button)

func _on_item_button_pressed(item: Item):
	if not player:
		return

	if item.consumable:
		# Use consumable item
		if player.inventory.use_consumable(item, player):
			print("Used item: ", item.name)
			update_inventory_display()
	else:
		# Show item details
		show_dialogue(item.get_description(), item.name)

func show_corruption_preview(choice_data: Dictionary):
	"""Show preview of corruption impact before making a choice"""
	if not choice_data.has("consequences"):
		return

	var consequences = choice_data.consequences
	var preview_text = "This choice will have the following consequences:\n"

	if consequences.has("corruption_impact"):
		var impact = consequences.corruption_impact
		if impact > 0:
			preview_text += "\n• [color=red]+" + str(impact) + "% Corruption[/color]"
		elif impact < 0:
			preview_text += "\n• [color=green]" + str(impact) + "% Corruption[/color]"

	if consequences.has("moral_impact"):
		var impact = consequences.moral_impact
		if impact > 0:
			preview_text += "\n• [color=blue]Good alignment[/color]"
		elif impact < 0:
			preview_text += "\n• [color=red]Evil alignment[/color]"

	# Show preview
	show_dialogue(preview_text, "Choice Consequences")

func update_ui_for_corruption_stage():
	"""Update UI appearance based on corruption stage"""
	if not game_state_manager:
		return

	var corruption_stage = game_state_manager.get_corruption_stage()

	# Apply visual corruption to UI
	match corruption_stage:
		"stage_1":
			# Subtle UI corruption
			modulate = Color(0.95, 0.95, 1.0, 1.0)
		"stage_2":
			# More obvious UI changes
			modulate = Color(0.9, 0.85, 1.0, 1.0)
		"stage_3":
			# Major UI transformation
			modulate = Color(0.8, 0.7, 0.9, 1.0)
		"stage_4":
			# Complete UI corruption
			modulate = Color(0.6, 0.4, 0.7, 1.0)

func show_game_over(is_corruption_victory: bool = false):
	"""Show game over screen"""
	var game_over_text = "GAME OVER"

	if is_corruption_victory:
		game_over_text = "CORRUPTION VICTORY\nYou have embraced the darkness"
	else:
		game_over_text = "GAME OVER\nYour journey ends here"

	show_dialogue(game_over_text, "")

func show_ending(ending_type: String):
	"""Show specific ending based on corruption and choices"""
	match ending_type:
		"corrupted_victory":
			show_dialogue("You rule as a monster, forever changed by the knowledge you sought.", "Corrupted Victory")
		"redemptive_sacrifice":
			show_dialogue("You died as a human, but saved others from your fate.", "Redemptive Sacrifice")
		"transcendent_being":
			show_dialogue("You have become something beyond human comprehension.", "Transcendence")
		"wounded_survivor":
			show_dialogue("You live with your scars, forever marked by your choices.", "Wounded Survivor")
		"normal_life":
			show_dialogue("You rejected forbidden knowledge and chose a normal life.", "Normal Life")
		_:
			show_dialogue("Your story ends here.", "The End")
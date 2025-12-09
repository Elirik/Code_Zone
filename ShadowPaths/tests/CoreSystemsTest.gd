extends Node2D

@onready var game_state_manager: GameStateManager = $GameStateManager
@onready var test_player: Player = $TestPlayer
@onready var test_label: Label = $TestUI/TestPanel/TestLabel

func _ready():
	print("=== Core Systems Test Started ===")

	# Test the core systems
	run_core_systems_tests()

func run_core_systems_tests():
	"""Test all core systems working together"""
	var test_results = []

	# Test 1: GameStateManager initialization
	test_results.append(test_game_state_manager())

	# Test 2: Player systems
	test_results.append(test_player_systems())

	# Test 3: Corruption system
	test_results.append(test_corruption_system())

	# Test 4: Inventory system
	test_results.append(test_inventory_system())

	# Test 5: Save system
	test_results.append(test_save_system())

	# Test 6: Combat system
	test_results.append(test_combat_system())

	# Display results
	display_test_results(test_results)

func test_game_state_manager() -> String:
	"""Test GameStateManager functionality"""
	try:
		# Test initial state
		assert(game_state_manager.corruption_level == 0.0, "Initial corruption should be 0")
		assert(game_state_manager.discovered_secrets.size() == 0, "No secrets discovered initially")

		# Test choice recording
		game_state_manager.record_choice("test_choice", {
			"corruption_impact": 10.0,
			"moral_impact": 5
		})

		assert(game_state_manager.corruption_level == 10.0, "Corruption should be 10 after choice")
		assert(game_state_manager.moral_alignment == 5, "Moral alignment should be 5")

		return "✓ GameStateManager: PASSED"
	except:
		return "✗ GameStateManager: FAILED - " + str(get_stack_error())

func test_player_systems() -> String:
	"""Test Player character systems"""
	try:
		# Test initial stats
		assert(test_player.health == test_player.max_health, "Player should start at full health")
		assert(test_player.mana == test_player.max_mana, "Player should start at full mana")

		# Test damage
		var initial_health = test_player.health
		test_player.take_damage(20)
		assert(test_player.health == initial_health - 20, "Player should take 20 damage")

		# Test healing
		test_player.heal(10)
		assert(test_player.health == initial_health - 10, "Player should heal for 10")

		# Test abilities
		var abilities = test_player.get_available_abilities()
		assert(abilities.size() > 0, "Player should have starting abilities")

		return "✓ Player Systems: PASSED"
	except:
		return "✗ Player Systems: FAILED - " + str(get_stack_error())

func test_corruption_system() -> String:
	"""Test corruption mechanics"""
	try:
		# Test corruption progression
		var initial_corruption = game_state_manager.corruption_level

		# Apply corruption through choice
		game_state_manager.apply_corruption_change(25.0)
		assert(game_state_manager.corruption_level == initial_corruption + 25.0, "Corruption should increase by 25")

		# Test corruption stage
		var stage = game_state_manager.get_corruption_stage()
		assert(stage == "stage_1", "Should be in stage 1 corruption")

		# Test corruption visual effects (player should update)
		# This would test player sprite changes

		return "✓ Corruption System: PASSED"
	except:
		return "✗ Corruption System: FAILED - " + str(get_stack_error())

func test_inventory_system() -> String:
	"""Test inventory functionality"""
	try:
		var inventory = test_player.inventory

		# Test inventory initialization
		assert(inventory.get_total_items() == 0, "Inventory should start empty")
		assert(inventory.get_free_slots() > 0, "Should have free slots")

		# Test adding items
		var health_potion = Item.new()
		health_potion.item_id = "test_health_potion"
		health_potion.name = "Test Health Potion"
		health_potion.stackable = true

		var success = inventory.add_item(health_potion, 5)
		assert(success, "Should be able to add item to empty inventory")
		assert(inventory.get_item_quantity(health_potion) == 5, "Should have 5 potions")

		# Test using consumable
		health_potion.consumable = true
		health_potion.effects = {"heal": 25}

		var initial_health = test_player.health
		inventory.use_consumable(health_potion, test_player)
		assert(test_player.health > initial_health, "Should heal when using potion")
		assert(inventory.get_item_quantity(health_potion) == 4, "Should have 4 potions remaining")

		return "✓ Inventory System: PASSED"
	except:
		return "✗ Inventory System: FAILED - " + str(get_stack_error())

func test_save_system() -> String:
	"""Test save/load functionality"""
	try:
		var save_system = SaveSystem.new()
		save_system.set_game_state_manager(game_state_manager)
		save_system.set_player(test_player)

		# Test save data creation
		var save_data = save_system.create_save_data()
		assert(save_data.has("version"), "Save data should have version")
		assert(save_data.has("player_data"), "Save data should have player data")
		assert(save_data.has("game_state"), "Save data should have game state")

		# Test serialization
		assert(save_data.player_data.has("health"), "Player data should include health")
		assert(save_data.game_state.has("corruption_level"), "Game state should include corruption")

		# Test loading (basic structure test)
		# Full save/load testing would require file system operations

		return "✓ Save System: PASSED (Structure)"
	except:
		return "✗ Save System: FAILED - " + str(get_stack_error())

func test_combat_system() -> String:
	"""Test combat system functionality"""
	try:
		var combat_engine = preload("res://scripts/combat/CombatEngine.gd").new()

		# Test combat initialization
		var enemies = []
		var enemy = preload("res://scripts/combat/Enemy.gd").create_enemy("shadow_beast", 2)
		enemies.append(enemy)

		combat_engine.start_combat([test_player], enemies)

		# Test turn order setup
		assert(combat_engine.participants.size() > 0, "Should have participants")
		assert(combat_engine.turn_order.size() > 0, "Should have turn order")

		# Test damage calculation
		var damage = combat_engine.calculate_damage(test_player, enemy, {"damage": 20, "damage_type": "physical"})
		assert(damage > 0, "Should calculate damage greater than 0")

		return "✓ Combat System: PASSED (Structure)"
	except:
		return "✗ Combat System: FAILED - " + str(get_stack_error())

func display_test_results(results: Array[String]):
	"""Display test results on screen"""
	var output = "CORE SYSTEMS TEST RESULTS\n\n"

	var passed = 0
	var failed = 0

	for result in results:
		output += result + "\n"
		if "PASSED" in result:
			passed += 1
		else:
			failed += 1

	output += "\n" + "=".repeat(30) + "\n"
	output += "TOTAL: " + str(passed + failed) + " tests\n"
	output += "PASSED: " + str(passed) + "\n"
	output += "FAILED: " + str(failed) + "\n"

	if failed == 0:
		output += "\n🎉 ALL SYSTEMS OPERATIONAL! 🎉"
	else:
		output += "\n⚠️ Some systems need attention"

	test_label.text = output
	print(output)

func get_stack_error() -> String:
	"""Get error message from current stack"""
	var stack = get_stack()
	if stack.size() > 1:
		return "Error at line " + str(stack[1].line)
	return "Unknown error"

func _input(event):
	# Run tests again with Space key
	if event.is_action_pressed("ui_accept"):  # Space or Enter
		print("\n=== Rerunning Core Systems Test ===")
		run_core_systems_tests()
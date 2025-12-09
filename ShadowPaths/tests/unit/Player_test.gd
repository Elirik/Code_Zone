extends "res://tests/TestFramework.gd"
class_name PlayerTest

# Unit tests for Player character system

var test_player: Player
var test_gsm: GameStateManager
var test_assertions: TestAssertions

func _ready():
	test_name = "Player Unit Tests"
	test_type = TestType.UNIT
	setup()

func setup():
	"""Set up test environment"""
	test_player = Player.new()
	test_gsm = GameStateManager.new()
	test_player.game_state_manager = test_gsm
	test_assertions = TestAssertions.new()
	test_assertions.set_test_result(self)

func test_initial_stats():
	"""Test player initial statistics"""
	test_assertions.assert_equals(100, test_player.max_health, "Initial max health should be 100")
	test_assertions.assert_equals(100, test_player.health, "Initial health should equal max health")
	test_assertions.assert_equals(50, test_player.max_mana, "Initial max mana should be 50")
	test_assertions.assert_equals(50, test_player.mana, "Initial mana should equal max mana")

	# Test combat stats
	test_assertions.assert_equals(10, test_player.attack, "Initial attack should be 10")
	test_assertions.assert_equals(8, test_player.defense, "Initial defense should be 8")
	test_assertions.assert_equals(12, test_player.speed, "Initial speed should be 12")
	test_assertions.assert_equals(9, test_player.special, "Initial special should be 9")

func test_health_management():
	"""Test health damage and healing"""
	var initial_health = test_player.health

	# Test taking damage
	test_player.take_damage(20)
	test_assertions.assert_equals(initial_health - 20, test_player.health, "Health should decrease by damage amount")

	# Test taking lethal damage
	test_player.health = 5
	test_player.take_damage(10)
	test_assertions.assert_equals(0, test_player.health, "Health should not go below 0")

	# Test healing
	test_player.health = 50
	test_player.heal(30)
	test_assertions.assert_equals(80, test_player.health, "Health should increase by heal amount")

	# Test overhealing (should not exceed max)
	test_player.heal(50)
	test_assertions.assert_equals(test_player.max_health, test_player.health, "Health should not exceed max health")

func test_mana_management():
	"""Test mana usage and restoration"""
	var initial_mana = test_player.mana

	# Test mana usage
	var can_use = test_player.use_mana(20)
	test_assertions.assert_true(can_use, "Should be able to use mana when available")
	test_assertions.assert_equals(initial_mana - 20, test_player.mana, "Mana should decrease by usage amount")

	# Test insufficient mana
	test_player.mana = 10
	can_use = test_player.use_mana(20)
	test_assertions.assert_false(can_use, "Should not be able to use more mana than available")
	test_assertions.assert_equals(10, test_player.mana, "Mana should not change when usage fails")

	# Test mana restoration
	test_player.mana = 20
	test_player.restore_mana(25)
	test_assertions.assert_equals(45, test_player.mana, "Mana should increase by restore amount")

	# Test over-restoration
	test_player.restore_mana(20)
	test_assertions.assert_equals(test_player.max_mana, test_player.mana, "Mana should not exceed max")

func test_damage_calculation():
	"""Test damage calculation with defense"""
	# Test normal damage
	var damage = test_player.calculate_damage_received(30, "physical")
	test_assertions.assert_greater_than(30, damage, "Physical damage should be reduced by defense")
	test_assertions.assert_greater_than(0, damage, "Damage should not be reduced to zero")

	# Test damage with corruption bonus (when player is corrupted)
	test_gsm.corruption_level = 60.0  # High corruption
	test_player._on_corruption_changed(60.0)

	damage = test_player.calculate_damage_received(30, "physical")
	test_assertions.assert_greater_than(0, damage, "Corrupted player should still take damage")

func test_ability_system():
	"""Test ability learning and usage"""
	# Test initial abilities
	var initial_abilities = test_player.get_available_abilities()
	test_assertions.assert_greater_than(0, initial_abilities.size(), "Player should have starting abilities")

	# Test learning new ability
	var new_ability = Ability.new()
	new_ability.name = "Test Ability"
	new_ability.damage = 25
	new_ability.mana_cost = 15
	new_ability.required_corruption = 0.0

	test_player.learn_ability(new_ability)
	test_assertions.assert_true(test_player.has_ability("Test Ability"), "Player should learn new ability")

	# Test ability mana requirements
	test_player.mana = 10
	test_assertions.assert_false(new_ability.can_use(test_player.mana, 0.0), "Should not be able to use ability without enough mana")

	test_player.mana = 20
	test_assertions.assert_true(new_ability.can_use(test_player.mana, 0.0), "Should be able to use ability with enough mana")

func test_corruption_abilities():
	"""Test corruption-granted abilities"""
	var corruption_ability = Ability.new()
	corruption_ability.name = "Corruption Touch"
	corruption_ability.damage = 40
	corruption_ability.mana_cost = 20
	corruption_ability.required_corruption = 25.0

	# Test ability unavailable at low corruption
	test_gsm.corruption_level = 10.0
	test_player.learn_ability(corruption_ability)
	test_assertions.assert_false(
		test_player.has_ability("Corruption Touch"),
		"Should not learn corruption ability below threshold"
	)

	# Test ability available at sufficient corruption
	test_gsm.corruption_level = 30.0
	test_player.check_corruption_abilities()
	test_assertions.assert_true(
		test_player.has_ability("Corruption Touch"),
		"Should learn corruption ability at threshold"
	)

func test_inventory_system():
	"""Test player inventory integration"""
	test_assertions.assert_not_null(test_player.inventory, "Player should have inventory")

	var inventory = test_player.inventory
	test_assertions.assert_equals(30, inventory.max_slots, "Default inventory should have 30 slots")

func test_status_effects():
	"""Test status effect system"""
	var status_effect = StatusEffect.new()
	status_effect.name = "Test Buff"
	status_effect.duration = 3
	status_effect.stat_changes = {"attack": 5}

	# Test adding status effect
	test_player.add_status_effect(status_effect)
	test_assertions.assert_array_contains(
		test_player.status_effects,
		status_effect,
		"Status effect should be added to player"
	)

	# Test status effect update
	var initial_duration = status_effect.duration
	test_player.update_status_effects()
	test_assertions.assert_equals(
		initial_duration - 1,
		status_effect.duration,
		"Status effect duration should decrease"
	)

func test_movement_state():
	"""Test movement and combat state"""
	# Test initial state
	test_assertions.assert_false(test_player.in_combat, "Player should not start in combat")

	# Test combat state
	test_player.in_combat = true
	test_assertions.assert_true(test_player.in_combat, "Combat state should be settable")

func test_corruption_visuals():
	"""Test corruption visual changes"""
	# Test stage 1 corruption
	test_gsm.corruption_level = 25.0
	test_player._on_corruption_changed(25.0)

	var corruption_stage = test_gsm.get_corruption_stage()
	test_assertions.assert_equals("stage_1", corruption_stage, "Should be in stage 1 corruption")

	# Test stage 3 corruption
	test_gsm.corruption_level = 75.0
	test_player._on_corruption_changed(75.0)

	corruption_stage = test_gsm.get_corruption_stage()
	test_assertions.assert_equals("stage_3", corruption_stage, "Should be in stage 3 corruption")

func test_facing_direction():
	"""Test facing direction updates"""
	# Test initial direction
	test_assertions.assert_equals(Vector2.DOWN, test_player.facing_direction, "Initial facing should be down")

	# Test direction update
	test_player.facing_direction = Vector2.LEFT
	test_assertions.assert_equals(Vector2.LEFT, test_player.facing_direction, "Facing direction should be updatable")

func test_moving_state():
	"""Test movement state tracking"""
	# Test not moving
	test_assertions.assert_false(test_player.is_moving, "Player should not be moving initially")

	# Test moving state
	test_player.is_moving = true
	test_assertions.assert_true(test_player.is_moving, "Movement state should be updatable")

func test_error_handling():
	"""Test error handling and edge cases"""
	# Test taking negative damage
	var initial_health = test_player.health
	test_player.take_damage(-10)
	test_assertions.assert_equals(initial_health, test_player.health, "Negative damage should not increase health")

	# Test healing with negative amount
	initial_health = test_player.health
	test_player.heal(-10)
	test_assertions.assert_equals(initial_health, test_player.health, "Negative healing should not decrease health")

func teardown():
	"""Clean up after tests"""
	if test_player:
		test_player.queue_free()
	if test_gsm:
		test_gsm.queue_free()
	if test_assertions:
		test_assertions.queue_free()
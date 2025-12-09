extends "res://tests/TestFramework.gd"
class_name GameStateManagerTest

# Unit tests for GameStateManager

var test_gsm: GameStateManager
var test_assertions: TestAssertions

func _ready():
	test_name = "GameStateManager Unit Tests"
	test_type = TestType.UNIT
	setup()

func setup():
	"""Set up test environment"""
	test_gsm = GameStateManager.new()
	test_assertions = TestAssertions.new()
	test_assertions.set_test_result(self)

func test_initial_state():
	"""Test that GameStateManager initializes with correct default values"""
	# Test initial corruption level
	test_assertions.assert_equals(0.0, test_gsm.corruption_level, "Initial corruption should be 0.0")

	# Test initial arrays are empty
	test_assertions.assert_array_empty(test_gsm.discovered_secrets, "Discovered secrets should be empty initially")
	test_assertions.assert_array_empty(test_gsm.completed_quests, "Completed quests should be empty initially")

	# Test initial act
	test_assertions.assert_equals(1, test_gsm.current_act, "Should start in Act 1")

	# Test initial alignment
	test_assertions.assert_equals(0.0, test_gsm.moral_alignment, "Initial moral alignment should be 0.0")

func test_corruption_application():
	"""Test corruption level changes"""
	var initial_corruption = test_gsm.corruption_level

	# Apply positive corruption
	test_gsm.apply_corruption_change(25.0)
	test_assertions.assert_equals(initial_corruption + 25.0, test_gsm.corruption_level, "Corruption should increase by 25.0")

	# Apply negative corruption (purification)
	test_gsm.apply_corruption_change(-10.0)
	test_assertions.assert_equals(initial_corruption + 15.0, test_gsm.corruption_level, "Corruption should decrease by 10.0")

	# Test corruption clamping at maximum
	test_gsm.corruption_level = 90.0
	test_gsm.apply_corruption_change(20.0)
	test_assertions.assert_equals(100.0, test_gsm.corruption_level, "Corruption should clamp at 100.0")

	# Test corruption clamping at minimum
	test_gsm.corruption_level = 5.0
	test_gsm.apply_corruption_change(-10.0)
	test_assertions.assert_equals(0.0, test_gsm.corruption_level, "Corruption should clamp at 0.0")

func test_choice_recording():
	"""Test choice recording and consequence application"""
	var initial_corruption = test_gsm.corruption_level
	var initial_alignment = test_gsm.moral_alignment

	# Record a choice with corruption and moral impact
	test_gsm.record_choice("test_choice", {
		"corruption_impact": 15.0,
		"moral_impact": -10,
		"relationship_changes": {
			"test_npc": {"friendship": -20}
		}
	})

	# Test corruption applied
	test_assertions.assert_approximately_equal(
		initial_corruption + 15.0,
		test_gsm.corruption_level,
		0.01,
		"Choice should apply corruption impact"
	)

	# Test moral alignment applied
	test_assertions.assert_equals(
		initial_alignment - 10,
		test_gsm.moral_alignment,
		"Choice should apply moral impact"
	)

	# Test relationship changes applied
	test_assertions.assert_dict_has_key(
		test_gsm.npc_relationships,
		"test_npc",
		"Choice should create NPC relationship entry"
	)

func test_corruption_stages():
	"""Test corruption stage determination"""
	# Test normal stage
	test_gsm.corruption_level = 0.0
	test_assertions.assert_equals("normal", test_gsm.get_corruption_stage(), "0% corruption should be normal stage")

	# Test stage 1
	test_gsm.corruption_level = 25.0
	test_assertions.assert_equals("stage_1", test_gsm.get_corruption_stage(), "25% corruption should be stage 1")

	# Test stage 2
	test_gsm.corruption_level = 50.0
	test_assertions.assert_equals("stage_2", test_gsm.get_corruption_stage(), "50% corruption should be stage 2")

	# Test stage 3
	test_gsm.corruption_level = 75.0
	test_assertions.assert_equals("stage_3", test_gsm.get_corruption_stage(), "75% corruption should be stage 3")

	# Test stage 4
	test_gsm.corruption_level = 100.0
	test_assertions.assert_equals("stage_4", test_gsm.get_corruption_stage(), "100% corruption should be stage 4")

func test_secret_discovery():
	"""Test secret discovery system"""
	var secret_id = "test_secret"

	# Test discovering new secret
	test_gsm.discover_secret(secret_id)
	test_assertions.assert_array_contains(
		test_gsm.discovered_secrets,
		secret_id,
		"Discovered secrets should contain the new secret"
	)

	# Test discovering same secret again (should not duplicate)
	var initial_count = test_gsm.discovered_secrets.size()
	test_gsm.discover_secret(secret_id)
	test_assertions.assert_equals(
		initial_count,
		test_gsm.discovered_secrets.size(),
		"Discovering same secret should not create duplicate"
	)

func test_quest_system():
	"""Test quest progression system"""
	var quest_id = "test_quest"

	# Test starting quest
	test_gsm.handle_quest_progress({
		"quest_id": quest_id,
		"action": "start",
		"objectives": ["objective1", "objective2"]
	})

	test_assertions.assert_dict_has_key(
		test_gsm.active_quests,
		quest_id,
		"Active quests should contain started quest"
	)

	# Test updating quest progress
	test_gsm.handle_quest_progress({
		"quest_id": quest_id,
		"action": "update",
		"progress": 50,
		"objectives": ["objective1"]
	})

	test_assertions.assert_equals(
		50,
		test_gsm.active_quests[quest_id].progress,
		"Quest progress should be updated"
	)

	# Test completing quest
	test_gsm.handle_quest_progress({
		"quest_id": quest_id,
		"action": "complete"
	})

	test_assertions.assert_false(
		test_gsm.active_quests.has(quest_id),
		"Completed quest should be removed from active quests"
	)

	test_assertions.assert_array_contains(
		test_gsm.completed_quests,
		quest_id,
		"Completed quests should contain the quest"
	)

func test_reputation_system():
	"""Test faction reputation system"""
	var faction = "test_faction"

	# Test initial reputation
	test_assertions.assert_dict_has_key(
		test_gsm.reputation_groups,
		faction,
		"Reputation groups should contain test faction"
	)

	var initial_reputation = test_gsm.reputation_groups[faction]

	# Test applying reputation changes
	test_gsm.record_choice("reputation_test", {
		"faction_impact": {
			faction: 25
		}
	})

	test_assertions.assert_equals(
		initial_reputation + 25,
		test_gsm.reputation_groups[faction],
		"Reputation should be updated correctly"
	)

func test_area_access():
	"""Test area access based on corruption"""
	# Test normal area access
	test_gsm.corruption_level = 0.0
	test_assertions.assert_true(
		test_gsm.can_access_area("village_church"),
		"Should be able to access church at low corruption"
	)

	# Test forbidden library access
	test_gsm.corruption_level = 0.0
	test_assertions.assert_false(
		test_gsm.can_access_area("forbidden_library"),
		"Should not be able to access library without corruption"
	)

	test_gsm.corruption_level = 30.0
	test_assertions.assert_true(
		test_gsm.can_access_area("forbidden_library"),
		"Should be able to access library with corruption"
	)

	# Test civilian area access at high corruption
	test_gsm.corruption_level = 80.0
	test_assertions.assert_false(
		test_gsm.can_access_area("civilian_areas"),
		"Should not be able to access civilian areas at high corruption"
	)

func test_npc_reaction():
	"""Test NPC reaction based on corruption and relationships"""
	# Test unknown NPC
	test_gsm.corruption_level = 30.0
	var reaction = test_gsm.get_npc_reaction("unknown_npc")
	test_assertions.assert_equals("neutral", reaction, "Unknown NPC should have neutral reaction")

	# Test known NPC with relationship
	test_gsm.npc_relationships["friendly_npc"] = {
		"friendship": 50,
		"trust": 30,
		"fear": 0
	}

	reaction = test_gsm.get_npc_reaction("friendly_npc")
	test_assertions.assert_equals("friendly", reaction, "High friendship NPC should be friendly")

	# Test fearful NPC
	test_gsm.npc_relationships["fearful_npc"] = {
		"friendship": -20,
		"trust": -50,
		"fear": 80
	}

	reaction = test_gsm.get_npc_reaction("fearful_npc")
	test_assertions.assert_equals("fearful", reaction, "High fear NPC should be fearful")

func test_world_changes():
	"""Test world state changes"""
	var location_id = "test_location"
	var changes = {
		"destroyed": true,
		"new_npc": "mysterious_stranger"
	}

	# Apply world changes
	test_gsm.apply_world_changes({location_id: changes})

	# Verify changes recorded
	test_assertions.assert_dict_has_key(
		test_gsm.world_changes,
		location_id,
		"World changes should contain location"
	)

	test_assertions.assert_dict_has_key(
		test_gsm.world_changes[location_id],
		"destroyed",
		"Location changes should contain specific changes"
	)

	test_assertions.assert_true(
		test_gsm.world_changes[location_id]["destroyed"],
		"Destroy flag should be set to true"
	)

func test_state_reset():
	"""Test game state reset functionality"""
	# Modify state
	test_gsm.corruption_level = 50.0
	test_gsm.discover_secret("test_secret")
	test_gsm.moral_alignment = -25.0
	test_gsm.current_act = 2

	# Reset state
	test_gsm.reset_game_state()

	# Verify reset
	test_assertions.assert_equals(0.0, test_gsm.corruption_level, "Corruption should be reset to 0")
	test_assertions.assert_array_empty(test_gsm.discovered_secrets, "Discovered secrets should be cleared")
	test_assertions.assert_equals(0.0, test_gsm.moral_alignment, "Moral alignment should be reset")
	test_assertions.assert_equals(1, test_gsm.current_act, "Should reset to Act 1")
	test_assertions.assert_dict_has_key(test_gsm.npc_relationships, "test_faction", "Reputation should be reset")
	test_assertions.assert_equals(0, test_gsm.reputation_groups["test_faction"], "Reputation values should be reset")

func test_corruption_thresholds():
	"""Test corruption threshold constants"""
	test_assertions.assert_equals(25.0, GameStateManager.CORRUPTION_THRESHOLDS["stage_1"], "Stage 1 threshold should be 25%")
	test_assertions.assert_equals(50.0, GameStateManager.CORRUPTION_THRESHOLDS["stage_2"], "Stage 2 threshold should be 50%")
	test_assertions.assert_equals(75.0, GameStateManager.CORRUPTION_THRESHOLDS["stage_3"], "Stage 3 threshold should be 75%")
	test_assertions.assert_equals(100.0, GameStateManager.CORRUPTION_THRESHOLDS["stage_4"], "Stage 4 threshold should be 100%")

func test_max_corruption_constant():
	"""Test maximum corruption constant"""
	test_assertions.assert_equals(100.0, GameStateManager.MAX_CORRUPTION, "Maximum corruption should be 100.0")

func teardown():
	"""Clean up after tests"""
	if test_gsm:
		test_gsm.queue_free()
	if test_assertions:
		test_assertions.queue_free()
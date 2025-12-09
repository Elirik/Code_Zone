extends Node
class_name TestFramework

# Comprehensive Test Framework for Shadow Paths RPG
# Supports Unit, Integration, System, Performance, and E2E testing

signal test_started(test_name: String)
signal test_completed(test_name: String, result: TestResult)
signal test_suite_started(suite_name: String)
signal test_suite_completed(suite_name: String, results: Array)
signal all_tests_completed(results: Dictionary)

enum TestStatus {
	PENDING,
	RUNNING,
	PASSED,
	FAILED,
	SKIPPED,
	ERROR
}

enum TestType {
	UNIT,
	INTEGRATION,
	SYSTEM,
	PERFORMANCE,
	UI,
	E2E
}

var current_test_suite: String = ""
var test_results: Dictionary = {}
var test_config: TestConfiguration

# Test discovery and execution
var test_runner: TestRunner
var test_reporter: TestReporter
var test_assertions: TestAssertions

func _ready():
	setup_test_framework()

func setup_test_framework():
	"""Initialize the complete testing framework"""
	print("=== Shadow Paths Test Framework Initializing ===")

	test_config = TestConfiguration.new()
	test_runner = TestRunner.new()
	test_reporter = TestReporter.new()
	test_assertions = TestAssertions.new()

	add_child(test_runner)
	add_child(test_reporter)

	# Connect signals
	test_runner.test_started.connect(_on_test_started)
	test_runner.test_completed.connect(_on_test_completed)
	test_runner.suite_started.connect(_on_suite_started)
	test_runner.suite_completed.connect(_on_suite_completed)

	print("Test Framework initialized successfully")

# Test Execution Methods
func run_all_tests() -> Dictionary:
	"""Run all test suites"""
	print("🚀 Running all test suites...")

	var all_results = {}

	# Run unit tests first
	all_results["unit"] = run_test_suite("unit")

	# Run integration tests
	all_results["integration"] = run_test_suite("integration")

	# Run system tests
	all_results["system"] = run_test_suite("system")

	# Run performance tests
	all_results["performance"] = run_test_suite("performance")

	# Run UI tests
	all_results["ui"] = run_test_suite("ui")

	# Run E2E tests
	all_results["e2e"] = run_test_suite("e2e")

	generate_comprehensive_report(all_results)
	all_tests_completed.emit(all_results)

	return all_results

func run_test_suite(suite_name: String) -> Dictionary:
	"""Run a specific test suite"""
	print("📋 Running test suite: ", suite_name)

	current_test_suite = suite_name
	var suite_results = test_runner.run_suite(suite_name)

	test_results[suite_name] = suite_results
	return suite_results

func run_test_by_name(test_name: String) -> TestResult:
	"""Run a specific test by name"""
	print("🎯 Running specific test: ", test_name)
	return test_runner.run_single_test(test_name)

# Test Discovery and Registration
func discover_tests() -> Array[String]:
	"""Auto-discover all test files"""
	var test_files = []
	var test_dirs = ["unit", "integration", "system", "performance", "ui", "e2e"]

	for dir_name in test_dirs:
		var dir_path = "res://tests/" + dir_name
		if DirAccess.dir_exists_absolute(dir_path):
			test_files.append_array(_discover_tests_in_directory(dir_path, dir_name))

	return test_files

func _discover_tests_in_directory(dir_path: String, suite_type: String) -> Array[String]:
	"""Discover tests in a specific directory"""
	var test_files = []
	var dir = DirAccess.open(dir_path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			if file_name.ends_with("_test.gd") or file_name.ends_with("Test.gd"):
				var full_path = dir_path + "/" + file_name
				test_files.append(full_path)
			file_name = dir.get_next()

	return test_files

# Test Results and Reporting
func generate_comprehensive_report(results: Dictionary):
	"""Generate comprehensive test report"""
	test_reporter.generate_html_report(results)
	test_reporter.generate_json_report(results)
	test_reporter.generate_console_report(results)

	# Upload to CI if in pipeline
	if test_config.ci_environment:
		test_reporter.upload_to_ci(results)

# Test Configuration Management
func configure_for_ci():
	"""Configure test framework for CI/CD environment"""
	test_config.ci_environment = true
	test_config.headless_mode = true
	test_config.parallel_execution = true
	test_config.generate_coverage = true

func configure_for_development():
	"""Configure test framework for development"""
	test_config.ci_environment = false
	test_config.headless_mode = false
	test_config.parallel_execution = false
	test_config.generate_coverage = false
	test_config.verbose_output = true

# Signal Handlers
func _on_test_started(test_name: String):
	test_started.emit(test_name)

func _on_test_completed(test_name: String, result: TestResult):
	test_completed.emit(test_name, result)

func _on_suite_started(suite_name: String):
	current_test_suite = suite_name
	test_suite_started.emit(suite_name)

func _on_suite_completed(suite_name: String, results: Array):
	test_suite_completed.emit(suite_name, results)

# Utility Methods
func get_test_statistics() -> Dictionary:
	"""Get comprehensive test statistics"""
	var stats = {
		"total_tests": 0,
		"passed": 0,
		"failed": 0,
		"skipped": 0,
		"errors": 0,
		"execution_time": 0.0,
		"coverage_percentage": 0.0
	}

	for suite_name in test_results:
		var suite_results = test_results[suite_name]
		stats.total_tests += suite_results.size()

		for result in suite_results:
			match result.status:
				TestStatus.PASSED:
					stats.passed += 1
				TestStatus.FAILED:
					stats.failed += 1
				TestStatus.SKIPPED:
					stats.skipped += 1
				TestStatus.ERROR:
					stats.errors += 1
				_:
					pass

	stats.success_rate = float(stats.passed) / float(stats.total_tests) * 100.0 if stats.total_tests > 0 else 0.0

	return stats

func cleanup_test_environment():
	"""Clean up test environment after execution"""
	print("🧹 Cleaning up test environment...")

	# Clean up temporary files
	var temp_dir = "user://temp_tests/"
	if DirAccess.dir_exists_absolute(temp_dir):
		# Remove temp directory and contents
		var dir = DirAccess.open(temp_dir)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				dir.remove(file_name)
				file_name = dir.get_next()
			dir.list_dir_end()
			DirAccess.remove_absolute(temp_dir)

	print("Test environment cleaned up")

# Mock and Fixture Management
func load_test_fixture(fixture_name: String) -> Dictionary:
	"""Load test fixture data"""
	var fixture_path = "res://tests/fixtures/" + fixture_name + ".json"
	var file = FileAccess.open(fixture_path, FileAccess.READ)

	if file:
		var json_text = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_text)

		if parse_result == OK:
			return json.data

	return {}

func create_mock_game_state() -> GameStateManager:
	"""Create a mock game state for testing"""
	var mock_gsm = GameStateManager.new()
	mock_gsm.corruption_level = 25.0
	mock_gsm.discovered_secrets = ["test_secret_1", "test_secret_2"]
	mock_gsm.moral_alignment = 10.0

	return mock_gsm

func create_mock_player() -> Player:
	"""Create a mock player for testing"""
	var mock_player = Player.new()
	mock_player.health = 75
	mock_player.max_health = 100
	mock_player.mana = 30
	mock_player.max_mana = 50
	mock_player.attack = 15
	mock_player.defense = 10
	mock_player.speed = 12

	return mock_player
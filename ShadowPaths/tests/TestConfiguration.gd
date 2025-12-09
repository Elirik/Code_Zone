extends Resource
class_name TestConfiguration

# Configuration for the test framework

# General Settings
var ci_environment: bool = false
var headless_mode: bool = false
var parallel_execution: bool = false
var verbose_output: bool = false
var generate_coverage: bool = false

# Performance Settings
var performance_test_iterations: int = 100
var memory_leak_threshold: int = 1024 * 1024  # 1MB
var frame_rate_threshold: float = 30.0  # Minimum FPS

# UI Test Settings
var ui_test_timeout: float = 5.0  # Seconds
var ui_test_screenshot: bool = true
var ui_accessibility_checks: bool = true

# E2E Test Settings
var e2e_test_timeout: float = 60.0  # Seconds
var e2e_save_state_management: bool = true
var e2e_network_simulation: bool = false

# Coverage Settings
var coverage_minimum_threshold: float = 80.0  # Percentage
var coverage_excluded_paths: Array[String] = ["tests/", "addons/"]

# Reporting Settings
var report_formats: Array[String] = ["console", "json", "html"]
var report_output_directory: String = "user://test_reports/"
var upload_to_ci: bool = true

# Test Environment
var test_database_path: String = "user://test_database.db"
var test_save_directory: String = "user://test_saves/"
var mock_data_directory: String = "res://tests/fixtures/"

# Quality Gates
var maximum_test_failures: int = 0
var maximum_test_skips: int = 10
var maximum_coverage_regression: float = 2.0  # Percentage

func _init():
	# Load configuration from environment or file
	load_configuration()

func load_configuration():
	"""Load test configuration from environment variables or config file"""
	# Check for CI environment
	if OS.has_environment("CI"):
		ci_environment = true
		headless_mode = true
		parallel_execution = true
		generate_coverage = true

	# Load from config file if exists
	var config_path = "res://tests/test_config.json"
	if FileAccess.file_exists(config_path):
		var file = FileAccess.open(config_path, FileAccess.READ)
		if file:
			var json_text = file.get_as_text()
			file.close()

			var json = JSON.new()
			var parse_result = json.parse(json_text)

			if parse_result == OK:
				_apply_configuration(json.data)

func _apply_configuration(config_data: Dictionary):
	"""Apply configuration from loaded data"""
	if config_data.has("ci_environment"):
		ci_environment = config_data.ci_environment

	if config_data.has("headless_mode"):
		headless_mode = config_data.headless_mode

	if config_data.has("parallel_execution"):
		parallel_execution = config_data.parallel_execution

	if config_data.has("verbose_output"):
		verbose_output = config_data.verbose_output

	if config_data.has("generate_coverage"):
		generate_coverage = config_data.generate_coverage

	# Apply performance settings
	if config_data.has("performance"):
		var perf_config = config_data.performance
		if perf_config.has("iterations"):
			performance_test_iterations = perf_config.iterations
		if perf_config.has("memory_threshold"):
			memory_leak_threshold = perf_config.memory_threshold
		if perf_config.has("frame_rate_threshold"):
			frame_rate_threshold = perf_config.frame_rate_threshold

	# Apply coverage settings
	if config_data.has("coverage"):
		var coverage_config = config_data.coverage
		if coverage_config.has("minimum_threshold"):
			coverage_minimum_threshold = coverage_config.minimum_threshold
		if coverage_config.has("excluded_paths"):
			coverage_excluded_paths = coverage_config.excluded_paths

func save_configuration():
	"""Save current configuration to file"""
	var config_data = {
		"ci_environment": ci_environment,
		"headless_mode": headless_mode,
		"parallel_execution": parallel_execution,
		"verbose_output": verbose_output,
		"generate_coverage": generate_coverage,
		"performance": {
			"iterations": performance_test_iterations,
			"memory_threshold": memory_leak_threshold,
			"frame_rate_threshold": frame_rate_threshold
		},
		"coverage": {
			"minimum_threshold": coverage_minimum_threshold,
			"excluded_paths": coverage_excluded_paths
		}
	}

	var config_path = "res://tests/test_config.json"
	var file = FileAccess.open(config_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(config_data, "\t")
		file.store_string(json_string)
		file.close()

func validate_configuration() -> bool:
	"""Validate configuration settings"""
	# Check critical settings
	if performance_test_iterations <= 0:
		push_error("Performance test iterations must be greater than 0")
		return false

	if coverage_minimum_threshold < 0 or coverage_minimum_threshold > 100:
		push_error("Coverage threshold must be between 0 and 100")
		return false

	if memory_leak_threshold <= 0:
		push_error("Memory leak threshold must be greater than 0")
		return false

	if frame_rate_threshold <= 0:
		push_error("Frame rate threshold must be greater than 0")
		return false

	return true

func get_test_environment_info() -> Dictionary:
	"""Get information about the current test environment"""
	return {
		"operating_system": OS.get_name(),
		"godot_version": Engine.get_version_info(),
		"ci_environment": ci_environment,
		"headless_mode": headless_mode,
		"timestamp": Time.get_unix_time_from_system(),
		"memory_usage": OS.get_static_memory_usage_by_type(),
		"processor_count": OS.get_processor_count()
	}

func print_configuration():
	"""Print current configuration"""
	print("=== Test Configuration ===")
	print("CI Environment: ", ci_environment)
	print("Headless Mode: ", headless_mode)
	print("Parallel Execution: ", parallel_execution)
	print("Verbose Output: ", verbose_output)
	print("Generate Coverage: ", generate_coverage)
	print("Performance Iterations: ", performance_test_iterations)
	print("Memory Leak Threshold: ", memory_leak_threshold, " bytes")
	print("Frame Rate Threshold: ", frame_rate_threshold, " FPS")
	print("Coverage Threshold: ", coverage_minimum_threshold, "%")
	print("===========================")
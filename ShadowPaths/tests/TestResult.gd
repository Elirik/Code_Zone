extends Resource
class_name TestResult

# Comprehensive test result data structure

var test_name: String
var test_suite: String
var test_type: int = TestFramework.TestType.UNIT
var status: int = TestFramework.TestStatus.PENDING
var execution_time: float = 0.0
var start_time: float = 0.0
var end_time: float = 0.0

# Test details
var description: String = ""
var assertions_count: int = 0
var passed_assertions: int = 0
var failed_assertions: int = 0

# Error information
var error_message: String = ""
var stack_trace: Array[String] = []
var failure_reason: String = ""

# Performance metrics
var memory_usage_before: int = 0
var memory_usage_after: int = 0
var cpu_usage: float = 0.0
var frame_drops: int = 0

# Coverage information
var lines_covered: int = 0
var lines_total: int = 0
var functions_covered: int = 0
var functions_total: int = 0
var branches_covered: int = 0
var branches_total: int = 0

# Test data
var test_data: Dictionary = {}
var fixtures_used: Array[String] = []
var mocks_created: Array[String] = []

# Flaky test detection
var execution_history: Array[float] = []
var is_flaky: bool = false
var flaky_threshold: float = 0.3  # 30% failure rate considered flaky

func _init():
	pass

func start():
	"""Start test execution"""
	status = TestFramework.TestStatus.RUNNING
	start_time = Time.get_unix_time_from_system()
	memory_usage_before = OS.get_static_memory_usage_by_type()[OS.MEMORY_TYPE_STATIC]

func end():
	"""End test execution"""
	end_time = Time.get_unix_time_from_system()
	execution_time = end_time - start_time
	memory_usage_after = OS.get_static_memory_usage_by_type()[OS.MEMORY_TYPE_STATIC]

	# Determine final status
	if status == TestFramework.TestStatus.RUNNING:
		status = TestFramework.TestStatus.PASSED

	# Check for flaky test
	_check_flaky_status()

func pass():
	"""Mark test as passed"""
	if status == TestFramework.TestStatus.RUNNING:
		status = TestFramework.TestStatus.PASSED
	passed_assertions += 1

func fail(reason: String = ""):
	"""Mark test as failed"""
	status = TestFramework.TestStatus.FAILED
	failed_assertions += 1
	failure_reason = reason

func skip(reason: String = ""):
	"""Mark test as skipped"""
	status = TestFramework.TestStatus.SKIPPED
	failure_reason = reason

func error(message: String, stack: Array[String] = []):
	"""Mark test as error"""
	status = TestFramework.TestStatus.ERROR
	error_message = message
	stack_trace = stack

func add_assertion(passed: bool):
	"""Add an assertion result"""
	assertions_count += 1
	if passed:
		passed_assertions += 1
	else:
		failed_assertions += 1

func get_success_rate() -> float:
	"""Get test success rate percentage"""
	if assertions_count == 0:
		return 100.0
	return (float(passed_assertions) / float(assertions_count)) * 100.0

func get_memory_delta() -> int:
	"""Get memory usage change during test"""
	return memory_usage_after - memory_usage_before

func get_coverage_percentage() -> float:
	"""Get overall coverage percentage"""
	if lines_total == 0:
		return 0.0
	return (float(lines_covered) / float(lines_total)) * 100.0

func is_performance_issue() -> bool:
	"""Check if test has performance issues"""
	# Check memory usage
	if get_memory_delta() > 1024 * 1024:  # 1MB threshold
		return true

	# Check execution time
	if execution_time > 10.0:  # 10 seconds threshold
		return true

	# Check CPU usage
	if cpu_usage > 80.0:  # 80% CPU threshold
		return true

	return false

func _check_flaky_status():
	"""Check if test is flaky based on execution history"""
	if execution_history.size() >= 10:  # Need at least 10 executions
		var failures = 0
		for exec_time in execution_history:
			# This would be populated with actual failure/success data
			# For now, simulate based on execution time variance
			if exec_time > execution_time * 1.5:  # Significant variance
				failures += 1

		var failure_rate = float(failures) / float(execution_history.size())
		is_flaky = failure_rate >= flaky_threshold

func add_execution_time(time: float):
	"""Add execution time to history for flaky detection"""
	execution_history.append(time)

	# Keep only last 20 executions
	if execution_history.size() > 20:
		execution_history.pop_front()

func to_dictionary() -> Dictionary:
	"""Convert test result to dictionary for serialization"""
	return {
		"test_name": test_name,
		"test_suite": test_suite,
		"test_type": test_type,
		"status": status,
		"execution_time": execution_time,
		"start_time": start_time,
		"end_time": end_time,
		"description": description,
		"assertions_count": assertions_count,
		"passed_assertions": passed_assertions,
		"failed_assertions": failed_assertions,
		"error_message": error_message,
		"stack_trace": stack_trace,
		"failure_reason": failure_reason,
		"memory_usage_before": memory_usage_before,
		"memory_usage_after": memory_usage_after,
		"cpu_usage": cpu_usage,
		"frame_drops": frame_drops,
		"lines_covered": lines_covered,
		"lines_total": lines_total,
		"functions_covered": functions_covered,
		"functions_total": functions_total,
		"branches_covered": branches_covered,
		"branches_total": branches_total,
		"test_data": test_data,
		"fixtures_used": fixtures_used,
		"mocks_created": mocks_created,
		"is_flaky": is_flaky,
		"flaky_threshold": flaky_threshold
	}

func from_dictionary(data: Dictionary):
	"""Load test result from dictionary"""
	test_name = data.get("test_name", "")
	test_suite = data.get("test_suite", "")
	test_type = data.get("test_type", TestFramework.TestType.UNIT)
	status = data.get("status", TestFramework.TestStatus.PENDING)
	execution_time = data.get("execution_time", 0.0)
	start_time = data.get("start_time", 0.0)
	end_time = data.get("end_time", 0.0)
	description = data.get("description", "")
	assertions_count = data.get("assertions_count", 0)
	passed_assertions = data.get("passed_assertions", 0)
	failed_assertions = data.get("failed_assertions", 0)
	error_message = data.get("error_message", "")
	stack_trace = data.get("stack_trace", [])
	failure_reason = data.get("failure_reason", "")
	memory_usage_before = data.get("memory_usage_before", 0)
	memory_usage_after = data.get("memory_usage_after", 0)
	cpu_usage = data.get("cpu_usage", 0.0)
	frame_drops = data.get("frame_drops", 0)
	lines_covered = data.get("lines_covered", 0)
	lines_total = data.get("lines_total", 0)
	functions_covered = data.get("functions_covered", 0)
	functions_total = data.get("functions_total", 0)
	branches_covered = data.get("branches_covered", 0)
	branches_total = data.get("branches_total", 0)
	test_data = data.get("test_data", {})
	fixtures_used = data.get("fixtures_used", [])
	mocks_created = data.get("mocks_created", [])
	is_flaky = data.get("is_flaky", false)
	flaky_threshold = data.get("flaky_threshold", 0.3)

func get_status_string() -> String:
	"""Get human-readable status string"""
	match status:
		TestFramework.TestStatus.PENDING:
			return "PENDING"
		TestFramework.TestStatus.RUNNING:
			return "RUNNING"
		TestFramework.TestStatus.PASSED:
			return "PASSED"
		TestFramework.TestStatus.FAILED:
			return "FAILED"
		TestFramework.TestStatus.SKIPPED:
			return "SKIPPED"
		TestFramework.TestStatus.ERROR:
			return "ERROR"
		_:
			return "UNKNOWN"

func get_test_type_string() -> String:
	"""Get human-readable test type string"""
	match test_type:
		TestFramework.TestType.UNIT:
			return "UNIT"
		TestFramework.TestType.INTEGRATION:
			return "INTEGRATION"
		TestFramework.TestType.SYSTEM:
			return "SYSTEM"
		TestFramework.TestType.PERFORMANCE:
			return "PERFORMANCE"
		TestFramework.TestType.UI:
			return "UI"
		TestFramework.TestType.E2E:
			return "E2E"
		_:
			return "UNKNOWN"
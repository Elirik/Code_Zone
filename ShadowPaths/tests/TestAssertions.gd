extends Node
class_name TestAssertions

# Comprehensive assertion library for testing

var current_test: TestResult
var assertion_count: int = 0
var failed_assertions: int = 0

signal assertion_passed(message: String)
signal assertion_failed(message: String, expected: Variant, actual: Variant)

func set_test_result(test_result: TestResult):
	"""Set the current test result for assertion tracking"""
	current_test = test_result

func reset():
	"""Reset assertion counters"""
	assertion_count = 0
	failed_assertions = 0

# Basic Assertions
func assert_true(condition: bool, message: String = "") -> bool:
	"""Assert that condition is true"""
	assertion_count += 1
	var assertion_message = message if message != "" else "Expected true"

	if condition:
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, true, condition)
		return false

func assert_false(condition: bool, message: String = "") -> bool:
	"""Assert that condition is false"""
	assertion_count += 1
	var assertion_message = message if message != "" else "Expected false"

	if not condition:
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, false, condition)
		return false

func assert_equals(expected: Variant, actual: Variant, message: String = "") -> bool:
	"""Assert that expected equals actual"""
	assertion_count += 1
	var assertion_message = message if message != "" else "Expected %s but got %s" % [str(expected), str(actual)]

	if expected == actual:
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, expected, actual)
		return false

func assert_not_equals(expected: Variant, actual: Variant, message: String = "") -> bool:
	"""Assert that expected does not equal actual"""
	assertion_count += 1
	var assertion_message = message if message != "" else "Expected not %s but got %s" % [str(expected), str(actual)]

	if expected != actual:
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, "not " + str(expected), actual)
		return false

# Numeric Assertions
func assert_greater_than(expected: float, actual: float, message: String = "") -> bool:
	"""Assert that actual > expected"""
	assertion_count += 1
	var assertion_message = message if message != "" else "Expected %s > %s" % [str(actual), str(expected)]

	if actual > expected:
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, "greater than " + str(expected), actual)
		return false

func assert_less_than(expected: float, actual: float, message: String = "") -> bool:
	"""Assert that actual < expected"""
	assertion_count += 1
	var assertion_message = message if message != "" else "Expected %s < %s" % [str(actual), str(expected)]

	if actual < expected:
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, "less than " + str(expected), actual)
		return false

func assert_in_range(value: float, min_range: float, max_range: float, message: String = "") -> bool:
	"""Assert that value is within range [min_range, max_range]"""
	assertion_count += 1
	var assertion_message = message if message != "" else "Expected %s to be in range [%s, %s]" % [str(value), str(min_range), str(max_range)]

	if value >= min_range and value <= max_range:
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, "value in range [" + str(min_range) + ", " + str(max_range) + "]", value)
		return false

func assert_approximately_equal(expected: float, actual: float, tolerance: float = 0.001, message: String = "") -> bool:
	"""Assert that actual is approximately equal to expected within tolerance"""
	assertion_count += 1
	var difference = abs(expected - actual)
	var assertion_message = message if message != "" else "Expected %s ≈ %s (±%s)" % [str(actual), str(expected), str(tolerance)]

	if difference <= tolerance:
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, "≈ " + str(expected) + " ±" + str(tolerance), actual)
		return false

# String Assertions
func assert_contains(haystack: String, needle: String, message: String = "") -> bool:
	"""Assert that haystack contains needle"""
	assertion_count += 1
	var assertion_message = message if message != "" else "Expected '%s' to contain '%s'" % [haystack, needle]

	if needle in haystack:
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, "string containing '" + needle + "'", haystack)
		return false

func assert_starts_with(prefix: String, string: String, message: String = "") -> bool:
	"""Assert that string starts with prefix"""
	assertion_count += 1
	var assertion_message = message if message != "" else "Expected '%s' to start with '%s'" % [string, prefix]

	if string.begins_with(prefix):
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, "string starting with '" + prefix + "'", string)
		return false

func assert_ends_with(suffix: String, string: String, message: String = "") -> bool:
	"""Assert that string ends with suffix"""
	assertion_count += 1
	var assertion_message = message if message != "" else "Expected '%s' to end with '%s'" % [string, suffix]

	if string.ends_with(suffix):
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, "string ending with '" + suffix + "'", string)
		return false

# Array/Collection Assertions
func assert_array_contains(array: Array, element: Variant, message: String = "") -> bool:
	"""Assert that array contains element"""
	assertion_count += 1
	var assertion_message = message if message != "" else "Expected array to contain %s" % str(element)

	if element in array:
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, "array containing " + str(element), array)
		return false

func assert_array_length(expected: int, array: Array, message: String = "") -> bool:
	"""Assert that array has expected length"""
	assertion_count += 1
	var actual_length = array.size()
	var assertion_message = message if message != "" else "Expected array length %s but got %s" % [str(expected), str(actual_length)]

	if actual_length == expected:
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, "array length " + str(expected), actual_length)
		return false

func assert_array_empty(array: Array, message: String = "") -> bool:
	"""Assert that array is empty"""
	return assert_array_length(0, array, message)

func assert_array_not_empty(array: Array, message: String = "") -> bool:
	"""Assert that array is not empty"""
	assertion_count += 1
	var assertion_message = message if message != "" else "Expected array to not be empty"

	if array.size() > 0:
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, "non-empty array", "empty array")
		return false

# Dictionary/Map Assertions
func assert_dict_has_key(dict: Dictionary, key: Variant, message: String = "") -> bool:
	"""Assert that dictionary has key"""
	assertion_count += 1
	var assertion_message = message if message != "" else "Expected dictionary to have key %s" % str(key)

	if dict.has(key):
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, "dictionary with key " + str(key), dict.keys())
		return false

func assert_dict_has_value(dict: Dictionary, value: Variant, message: String = "") -> bool:
	"""Assert that dictionary contains value"""
	assertion_count += 1
	var assertion_message = message if message != "" else "Expected dictionary to contain value %s" % str(value)

	if value in dict.values():
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, "dictionary containing " + str(value), dict.values())
		return false

# Type Assertions
func assert_is_type(value: Variant, expected_type: Variant.Type, message: String = "") -> bool:
	"""Assert that value is of expected type"""
	assertion_count += 1
	var actual_type = typeof(value)
	var assertion_message = message if message != "" else "Expected type %s but got %s" % [type_to_string(expected_type), type_to_string(actual_type)]

	if actual_type == expected_type:
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, type_to_string(expected_type), type_to_string(actual_type))
		return false

func assert_is_null(value: Variant, message: String = "") -> bool:
	"""Assert that value is null"""
	assertion_count += 1
	var assertion_message = message if message != "" else "Expected null but got %s" % str(value)

	if value == null:
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, "null", value)
		return false

func assert_is_not_null(value: Variant, message: String = "") -> bool:
	"""Assert that value is not null"""
	assertion_count += 1
	var assertion_message = message if message != "" else "Expected not null but got null"

	if value != null:
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, "not null", "null")
		return false

# Function/Method Assertions
func assert_method_exists(object: Object, method_name: String, message: String = "") -> bool:
	"""Assert that object has method"""
	assertion_count += 1
	var has_method = object.has_method(method_name)
	var assertion_message = message if message != "" else "Expected object to have method %s" % method_name

	if has_method:
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, "object with method " + method_name, object.get_method_list())
		return false

func assert_signal_exists(object: Object, signal_name: String, message: String = "") -> bool:
	"""Assert that object has signal"""
	assertion_count += 1
	var signal_list = object.get_signal_list()
	var has_signal = false

	for signal_info in signal_list:
		if signal_info.name == signal_name:
			has_signal = true
			break

	var assertion_message = message if message != "" else "Expected object to have signal %s" % signal_name

	if has_signal:
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, "object with signal " + signal_name, signal_list)
		return false

# Performance Assertions
func assert_execution_time_below(max_time: float, callable: Callable, message: String = "") -> bool:
	"""Assert that callable executes within max_time seconds"""
	assertion_count += 1
	var start_time = Time.get_unix_time_from_system()

	# Execute the callable
	callable.call()

	var execution_time = Time.get_unix_time_from_system() - start_time
	var assertion_message = message if message != "" else "Expected execution time < %s seconds but got %s" % [str(max_time), str(execution_time)]

	if execution_time <= max_time:
		_record_passed_assertion(assertion_message)
		return true
	else:
		_record_failed_assertion(assertion_message, "execution time < " + str(max_time), execution_time)
		return false

# Game-Specific Assertions
func assert_corruption_level(expected: float, game_state: GameStateManager, message: String = "") -> bool:
	"""Assert corruption level"""
	return assert_approximately_equal(expected, game_state.corruption_level, 0.01, message)

func assert_player_health(expected: int, player: Player, message: String = "") -> bool:
	"""Assert player health"""
	return assert_equals(expected, player.health, message)

func assert_inventory_contains_item(item_id: String, inventory: InventorySystem, message: String = "") -> bool:
	"""Assert inventory contains item"""
	for slot in inventory.slots:
		if slot.item and slot.item.item_id == item_id:
			_record_passed_assertion(message if message != "" else "Inventory contains item: " + item_id)
			return true

	_record_failed_assertion(message if message != "" else "Inventory should contain item: " + item_id, item_id, "not found")
	return false

# Private Helper Methods
func _record_passed_assertion(message: String):
	"""Record a passed assertion"""
	if current_test:
		current_test.add_assertion(true)

	assertion_passed.emit(message)
	print("✓ ", message)

func _record_failed_assertion(message: String, expected: Variant, actual: Variant):
	"""Record a failed assertion"""
	if current_test:
		current_test.add_assertion(false)
		current_test.fail(message)

	failed_assertions += 1
	var failure_msg = "✗ %s\n  Expected: %s\n  Actual: %s" % [message, str(expected), str(actual)]

	assertion_failed.emit(message, expected, actual)
	print(failure_msg)

func type_to_string(type: Variant.Type) -> String:
	"""Convert Variant.Type to readable string"""
	match type:
		Variant.Type.NIL:
			return "null"
		Variant.Type.BOOL:
			return "bool"
		Variant.Type.INT:
			return "int"
		Variant.Type.FLOAT:
			return "float"
		Variant.Type.STRING:
			return "string"
		Variant.Type.ARRAY:
			return "array"
		Variant.Type.DICTIONARY:
			return "dictionary"
		Variant.Type.OBJECT:
			return "object"
		_:
			return "unknown_type_" + str(type)